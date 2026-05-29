extends Node2D

var _pause_menu_scene := preload("res://scenes/menus/pause_menu.tscn")

signal objetivo_concluido()
signal recurso_changed(recurso: String, valor: float)
signal aviso(texto: String)

var water:  float = 100.0
var food:   float = 100.0
var morale: float = 100.0

const MAX_VAL := 100.0
const MIN_OK  := 20.0
const DECAY_W := 0.8
const DECAY_F := 0.8
const DECAY_M := 0.5

var _concluido   := false
var _aviso_timer := 5.0
var _coletaveis: Array[Area2D] = []

@onready var barco:         CharacterBody2D = $Barco
@onready var zona_saida:    Area2D          = $ZonaSaida
@onready var compass_pivot: Control         = $CanvasLayer/ShipCompass/NeedlePivot
@onready var target_label:  Label           = $CanvasLayer/ShipCompass/TargetLabel
@onready var barra_agua:    ProgressBar     = $CanvasLayer/PainelRecursos/VBox/BarraAgua
@onready var barra_comida:  ProgressBar     = $CanvasLayer/PainelRecursos/VBox/BarraComida
@onready var barra_moral:   ProgressBar     = $CanvasLayer/PainelRecursos/VBox/BarraMoral
@onready var label_aviso:   Label           = $CanvasLayer/LabelAviso


func _ready() -> void:
	add_to_group("area_fase4")

	await get_tree().process_frame
	var cam := get_node_or_null("Barco/Camera2D")
	if cam:
		cam.zoom = Vector2(2, 2)
	if barco:
		barco.motor_max_speed = 60.0
	_setup_camera()

	if zona_saida:
		zona_saida.body_entered.connect(_on_zona_saida)

	for col in get_tree().get_nodes_in_group("coletavel_recurso"):
		if col.has_method("set_resource_manager"):
			col.set_resource_manager(self)
		if col is Area2D:
			_coletaveis.append(col)

	label_aviso.visible = false


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		var pause := _pause_menu_scene.instantiate()
		add_child(pause)


func _process(delta: float) -> void:
	if _concluido:
		return

	water  = clamp(water  - DECAY_W * delta, 0.0, MAX_VAL)
	food   = clamp(food   - DECAY_F * delta, 0.0, MAX_VAL)
	morale = clamp(morale - DECAY_M * delta, 0.0, MAX_VAL)

	barra_agua.value      = water
	barra_comida.value    = food
	barra_moral.value     = morale
	barra_agua.modulate   = _cor(water)
	barra_comida.modulate = _cor(food)
	barra_moral.modulate  = _cor(morale)

	recurso_changed.emit("water",  water)
	recurso_changed.emit("food",   food)
	recurso_changed.emit("morale", morale)

	if barco and barco.has_method("set_speed_multiplier"):
		barco.set_speed_multiplier(0.5 if (water < MIN_OK or food < MIN_OK) else 1.0)

	_update_compass()

	_aviso_timer -= delta
	if morale < MIN_OK and _aviso_timer <= 0.0:
		var msgs: Array[String] = [
			"A tripulação está cansada.",
			"Os homens começam a duvidar da jornada.",
			"A moral baixa torna a navegação mais difícil.",
		]
		var msg: String = msgs[randi() % msgs.size()]
		_mostrar_aviso(msg)
		aviso.emit(msg)
		_aviso_timer = 8.0

	if water <= 0.0 or food <= 0.0 or morale <= 0.0:
		_falha()


func _update_compass() -> void:
	if not is_instance_valid(barco):
		return

	var vivos: Array[Area2D] = []
	for c in _coletaveis:
		if is_instance_valid(c) and c.is_inside_tree():
			vivos.append(c)
	_coletaveis = vivos

	var target: Vector2
	var label_text: String

	if _coletaveis.is_empty():
		target     = zona_saida.global_position
		label_text = "Ancore o Navio no Cais!!"
	else:
		var closest_dist := INF
		target = barco.global_position
		for col in _coletaveis:
			var dist: float = barco.global_position.distance_to(col.global_position)
			if dist < closest_dist:
				closest_dist = dist
				target = col.global_position
		label_text = "Colete suprimentos (%d)" % _coletaveis.size()

	compass_pivot.rotation = (target - barco.global_position).angle() + PI / 2.0
	target_label.text      = label_text


func _cor(val: float) -> Color:
	if val < MIN_OK: return Color.RED
	if val < 40.0:   return Color.YELLOW
	return Color.WHITE


func _mostrar_aviso(texto: String, duracao: float = 3.5) -> void:
	aviso.emit(texto)
	label_aviso.text    = texto
	label_aviso.visible = true
	await get_tree().create_timer(duracao).timeout
	if is_instance_valid(label_aviso):
		label_aviso.visible = false


func add_water(amount: float) -> void:
	water = clamp(water + amount, 0.0, MAX_VAL)

func add_food(amount: float) -> void:
	food = clamp(food + amount, 0.0, MAX_VAL)

func add_morale(amount: float) -> void:
	morale = clamp(morale + amount, 0.0, MAX_VAL)


func _on_zona_saida(body: Node) -> void:
	if _concluido or not body.is_in_group("barco"):
		return

	var vivos2: Array[Area2D] = []
	for c in _coletaveis:
		if is_instance_valid(c) and c.is_inside_tree():
			vivos2.append(c)
	_coletaveis = vivos2

	if not _coletaveis.is_empty():
		_mostrar_aviso("Colete todos os suprimentos antes de avançar!")
		return

	if water > MIN_OK and food > MIN_OK and morale > MIN_OK:
		_concluir()
	else:
		_mostrar_aviso("Os recursos estão muito baixos para continuar!")


func _concluir() -> void:
	_concluido = true
	objetivo_concluido.emit()
	_mostrar_aviso("Tripulação a salvo! Rumo aos Ventos do Índico.", 2.0)
	await get_tree().create_timer(2.0).timeout
	GameManager.complete_objective(4, "tripulacao_viva")
	GameManager.save_game()
	SceneManager.change_scene("res://scenes/levels/fase4/Level4_RumoAsIndias.tscn")


func _falha() -> void:
	_concluido = true
	_mostrar_aviso("Sem recursos — a expedição fracassou!")
	aviso.emit("Sem recursos, nenhuma expedição sobreviveria às longas travessias marítimas.")
	await get_tree().create_timer(3.0).timeout
	get_tree().reload_current_scene()


func _setup_camera() -> void:
	await get_tree().process_frame
	var cam := get_node_or_null("Barco/Camera2D")
	if cam:
		cam.limit_left   = -1000
		cam.limit_top    = -600
		cam.limit_right  = 1500
		cam.limit_bottom = 600
