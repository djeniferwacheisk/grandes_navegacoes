extends Control

const STAR_COUNT := 3
const TOLERANCE := 15.0

var stars_aligned := 0
var _current_star := 0
var _crosshair_pos := Vector2(320, 136)
var _star_positions: Array[Vector2] = []
var _star_targets: Array[Vector2] = []
var _completed := false

var _bg_star_nodes: Array[Label] = []

@onready var crosshair: Sprite2D = $SkyArea/Crosshair
@onready var result_label: Label = $ResultLabel
@onready var hint_label: Label = $HintLabel
@onready var back_button: Button = $BackButton
@onready var sky_area: Control = $SkyArea
@onready var star_counter: Label = $StarCounter


func _ready() -> void:
	back_button.pressed.connect(_on_back)
	result_label.text = ""

	_star_positions = [
		Vector2(240, 100),
		Vector2(320, 115),
		Vector2(400, 130),
	]

	_star_targets = _star_positions.duplicate()
	crosshair.position = _crosshair_pos

	_draw_background_stars()
	_draw_stars()
	_start_twinkle()
	_start_pulse()

	_update_hint()
	_update_counter()


func _draw_background_stars() -> void:
	var rng := RandomNumberGenerator.new()
	rng.randomize()

	for i in 120:
		var label := Label.new()
		label.text = "•"

		var sz := rng.randi_range(6, 10)
		label.add_theme_font_size_override("font_size", sz)

		var pos := Vector2(
			rng.randf_range(10, 630),
			rng.randf_range(10, 260)
		)

		label.position = pos - Vector2(sz * 0.3, sz * 0.5)
		label.modulate = Color(0.85, 0.9, 1.0, rng.randf_range(0.5, 0.9))

		sky_area.add_child(label)
		_bg_star_nodes.append(label)


func _draw_stars() -> void:
	for i in STAR_COUNT:
		var halo := Label.new()
		halo.text = "✦"
		halo.add_theme_font_size_override("font_size", 9)
		halo.position = _star_positions[i] - Vector2(6, 8)
		halo.modulate = Color(0.8, 0.9, 1.0, 0.35)
		halo.name = "Halo" + str(i)
		sky_area.add_child(halo)

		var label := Label.new()
		label.text = "✦"
		label.add_theme_font_size_override("font_size", 8)
		label.position = _star_positions[i] - Vector2(6, 8)
		label.modulate = Color(1.0, 1.0, 1.0, 1.0)
		label.name = "StarLabel" + str(i)
		sky_area.add_child(label)


func _start_twinkle() -> void:
	for star in _bg_star_nodes:
		_twinkle_star(star)


func _twinkle_star(star: Label) -> void:
	var tween := create_tween().set_loops()

	var min_alpha := randf_range(0.3, 0.6)
	var max_alpha := randf_range(0.7, 1.0)
	var duration := randf_range(1.0, 4.0)

	tween.tween_property(star, "modulate:a", max_alpha, duration)
	tween.tween_property(star, "modulate:a", min_alpha, duration)


func _start_pulse() -> void:
	for i in STAR_COUNT:
		var star = sky_area.get_node("StarLabel" + str(i))
		var halo = sky_area.get_node("Halo" + str(i))

		_pulse_star(star)
		_pulse_halo(halo)


func _pulse_star(star: Label) -> void:
	var tween := create_tween().set_loops()

	tween.tween_property(star, "scale", Vector2(1.05, 1.05), 1.2)
	tween.tween_property(star, "scale", Vector2(1.0, 1.0), 1.2)

	tween.parallel().tween_property(star, "modulate:a", 1.0, 1.2)
	tween.tween_property(star, "modulate:a", 0.7, 1.2)


func _pulse_halo(halo: Label) -> void:
	var tween := create_tween().set_loops()

	tween.tween_property(halo, "modulate:a", 0.5, 1.2)
	tween.tween_property(halo, "modulate:a", 0.2, 1.2)


func _process(_delta: float) -> void:
	if _completed:
		return

	var input := Vector2.ZERO
	input.x = Input.get_axis("move_left", "move_right")
	input.y = Input.get_axis("move_up", "move_down")

	if input != Vector2.ZERO:
		_crosshair_pos += input * 2.0
		_crosshair_pos.x = clampf(_crosshair_pos.x, 10, 630)
		_crosshair_pos.y = clampf(_crosshair_pos.y, 10, 260)
		crosshair.position = _crosshair_pos


func _input(event: InputEvent) -> void:
	if _completed:
		return

	if event is InputEventMouseMotion:
		var local_pos := sky_area.get_local_mouse_position()
		_crosshair_pos = local_pos
		_crosshair_pos.x = clampf(_crosshair_pos.x, 10, 630)
		_crosshair_pos.y = clampf(_crosshair_pos.y, 10, 260)
		crosshair.position = _crosshair_pos

	if event.is_action_pressed("interact") or (event is InputEventMouseButton and event.pressed):
		_try_align()

	if event.is_action_pressed("pause"):
		_on_back()


func _try_align() -> void:
	if _current_star >= STAR_COUNT:
		return

	var target: Vector2 = _star_targets[_current_star]
	var dist := _crosshair_pos.distance_to(target)

	if dist <= TOLERANCE:
		stars_aligned += 1
		_current_star += 1

		var star_label := sky_area.get_node_or_null("StarLabel" + str(_current_star - 1))
		if star_label:
			star_label.modulate = Color(0.7, 1.0, 0.8, 1.0)

		var halo := sky_area.get_node_or_null("Halo" + str(_current_star - 1))
		if halo:
			halo.modulate = Color(0.4, 1.0, 0.6, 0.5)

		result_label.text = "Estrela alinhada!"
		_update_counter()
		_update_hint()

		if stars_aligned >= STAR_COUNT:
			_complete_puzzle()
	else:
		result_label.text = "Tente novamente..."
		await get_tree().create_timer(0.5).timeout
		if not _completed:
			result_label.text = ""


func _update_hint() -> void:
	if _current_star < STAR_COUNT:
		hint_label.text = "Mova a mira ate a estrela " + str(_current_star + 1) + " e pressione [E]"
	else:
		hint_label.text = ""


func _update_counter() -> void:
	star_counter.text = "Estrelas: " + str(stars_aligned) + "/" + str(STAR_COUNT)


func _complete_puzzle() -> void:
	_completed = true
	result_label.text = "Latitude determinada! Rota calculada!"
	hint_label.text = ""

	var map_rect := ColorRect.new()
	map_rect.size = Vector2(0, 0)
	map_rect.position = Vector2(260, 120)
	map_rect.color = Color(0.8, 0.7, 0.4, 0.9)
	sky_area.add_child(map_rect)

	var map_label := Label.new()
	map_label.text = "ROTA MARITIMA"
	map_label.add_theme_font_size_override("font_size", 8)
	map_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	map_label.visible = false
	map_rect.add_child(map_label)

	var tween := create_tween()
	tween.tween_property(map_rect, "size", Vector2(120, 80), 1.0)
	tween.parallel().tween_property(map_rect, "position", Vector2(200, 80), 1.0)
	await tween.finished

	map_label.visible = true
	map_label.position = Vector2(10, 30)

	GameManager.complete_objective(1, "astrolabio")
	await get_tree().create_timer(2.0).timeout
	SceneManager.change_scene("res://scenes/levels/fase1_sagres.tscn")


func _on_back() -> void:
	SceneManager.change_scene("res://scenes/levels/fase1_sagres.tscn")
