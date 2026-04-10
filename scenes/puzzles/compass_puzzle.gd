extends Control

const STAR_COUNT := 3
const TOLERANCE := 30.0  # pixels — maior pois a tela é grande

var stars_aligned := 0
var _current_star := 0
var _crosshair_pos := Vector2(640, 316)
var _star_positions: Array[Vector2] = []
var _star_targets: Array[Vector2] = []
var _completed := false

@onready var crosshair: Sprite2D = $SkyArea/Crosshair
@onready var result_label: Label = $ResultLabel
@onready var hint_label: Label = $HintLabel
@onready var back_button: Button = $BackButton
@onready var sky_area: Control = $SkyArea
@onready var star_counter: Label = $StarCounter


func _ready() -> void:
	back_button.pressed.connect(_on_back)
	result_label.text = ""

	# As Três Marias — alinhadas em diagonal no centro da tela (1280x632)
	_star_positions = [
		Vector2(480, 220),   # estrela 1 — esquerda
		Vector2(640, 250),   # estrela 2 — centro
		Vector2(800, 280),   # estrela 3 — direita
	]

	_star_targets = _star_positions.duplicate()
	crosshair.position = _crosshair_pos

	_draw_background_stars()
	_draw_stars()
	_update_hint()
	_update_counter()


func _draw_background_stars() -> void:
	# Estrelas de fundo espalhadas pela tela 1280x600
	var bg_stars: Array[Vector2] = [
		# Região central ao redor das Três Marias
		Vector2(380, 180), Vector2(420, 290), Vector2(350, 250),
		Vector2(530, 160), Vector2(560, 310), Vector2(510, 340),
		Vector2(700, 180), Vector2(720, 320), Vector2(660, 170),
		Vector2(850, 200), Vector2(880, 310), Vector2(920, 240),
		Vector2(960, 180), Vector2(1000, 290), Vector2(1040, 210),
		# Região superior
		Vector2(150, 80),  Vector2(300, 100), Vector2(500, 70),
		Vector2(700, 90),  Vector2(900, 80),  Vector2(1100, 95),
		Vector2(1200, 70), Vector2(50, 120),  Vector2(1250, 150),
		# Região inferior
		Vector2(200, 420), Vector2(400, 460), Vector2(600, 430),
		Vector2(800, 450), Vector2(1000, 420),Vector2(1150, 460),
		Vector2(100, 500), Vector2(350, 520), Vector2(750, 510),
		# Estrelas esparsas
		Vector2(130, 200), Vector2(250, 350), Vector2(1100, 350),
		Vector2(1180, 280),Vector2(80, 380),  Vector2(440, 400),
		Vector2(760, 380), Vector2(1050, 480),Vector2(580, 500),
	]

	for pos in bg_stars:
		var label := Label.new()
		label.text = "✦"
		label.position = pos - Vector2(8, 10)
		var size := randi_range(10, 18)
		label.add_theme_font_size_override("font_size", size)
		var brightness := randf_range(0.5, 1.0)
		# Algumas estrelas com leve tom azulado/amarelado
		var r := brightness
		var g := brightness
		var b := randf_range(brightness * 0.8, brightness)
		label.modulate = Color(r, g, b, 1.0)
		sky_area.add_child(label)


func _draw_stars() -> void:
	for i in STAR_COUNT:
		# Estrela alvo — grande e bem visível
		var label := Label.new()
		label.text = "★"
		label.position = _star_positions[i] - Vector2(16, 20)
		label.add_theme_font_size_override("font_size", 28)
		label.modulate = Color(1.0, 0.95, 0.3, 1.0) if i >= stars_aligned else Color(0.3, 1.0, 0.3, 1.0)
		label.name = "StarLabel" + str(i)
		sky_area.add_child(label)

		# Brilho ao redor — efeito de halo
		var halo := Label.new()
		halo.text = "✦"
		halo.position = _star_positions[i] - Vector2(10, 12)
		halo.add_theme_font_size_override("font_size", 16)
		halo.modulate = Color(1.0, 0.9, 0.5, 0.4)
		halo.name = "Halo" + str(i)
		sky_area.add_child(halo)


func _process(_delta: float) -> void:
	if _completed:
		return

	var input := Vector2.ZERO
	input.x = Input.get_axis("move_left", "move_right")
	input.y = Input.get_axis("move_up", "move_down")

	if input != Vector2.ZERO:
		_crosshair_pos += input * 4.0
		_crosshair_pos.x = clampf(_crosshair_pos.x, 20, 1260)
		_crosshair_pos.y = clampf(_crosshair_pos.y, 20, 600)
		crosshair.position = _crosshair_pos


func _input(event: InputEvent) -> void:
	if _completed:
		return

	if event is InputEventMouseMotion:
		var local_pos := sky_area.get_local_mouse_position()
		_crosshair_pos = local_pos
		_crosshair_pos.x = clampf(_crosshair_pos.x, 20, 1260)
		_crosshair_pos.y = clampf(_crosshair_pos.y, 20, 600)
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
			star_label.modulate = Color(0.3, 1.0, 0.3, 1.0)
		var halo := sky_area.get_node_or_null("Halo" + str(_current_star - 1))
		if halo:
			halo.modulate = Color(0.3, 1.0, 0.3, 0.4)

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
	map_rect.position = Vector2(560, 250)
	map_rect.color = Color(0.8, 0.7, 0.4, 0.9)
	sky_area.add_child(map_rect)

	var map_label := Label.new()
	map_label.text = "ROTA MARITIMA"
	map_label.add_theme_font_size_override("font_size", 14)
	map_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	map_label.visible = false
	map_rect.add_child(map_label)

	var tween := create_tween()
	tween.tween_property(map_rect, "size", Vector2(200, 120), 1.0)
	tween.parallel().tween_property(map_rect, "position", Vector2(440, 190), 1.0)
	await tween.finished

	map_label.visible = true
	map_label.position = Vector2(20, 50)

	GameManager.complete_objective(1, "astrolabio")
	await get_tree().create_timer(2.0).timeout
	SceneManager.change_scene("res://scenes/levels/fase1_sagres.tscn")


func _on_back() -> void:
	SceneManager.change_scene("res://scenes/levels/fase1_sagres.tscn")
