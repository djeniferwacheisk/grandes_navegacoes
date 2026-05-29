extends Node2D

var _pause_menu_scene := preload("res://scenes/menus/pause_menu.tscn")

signal objetivo_concluido()
signal carta_coletada()
signal aviso(texto: String)

var _concluido      := false
var _carta_coletada := false

@onready var barco:       CharacterBody2D = $Barco
@onready var zona_chegada: Area2D         = $ZonaChegada
@onready var carta_area:   Area2D         = $CartaNavegacao


func _ready() -> void:
	add_to_group("area_fase4")

	await get_tree().process_frame
	var cam := get_node_or_null("Barco/Camera2D")
	if cam:
		cam.zoom = Vector2(2, 2)
	if barco:
		barco.motor_max_speed = 60.0
	_setup_camera()

	zona_chegada.body_entered.connect(_on_chegada)
	carta_area.body_entered.connect(_on_carta)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		var pause := _pause_menu_scene.instantiate()
		add_child(pause)


func _on_carta(body: Node) -> void:
	if _carta_coletada or not body.is_in_group("barco"):
		return
	_carta_coletada = true
	carta_area.queue_free()
	GameManager.add_item("Carta de Navegação Árabe", "Revela detalhes dos ventos e rotas do Índico.")
	carta_coletada.emit()


func _on_chegada(body: Node) -> void:
	if _concluido or not body.is_in_group("barco"):
		return
	var navio_ok: bool = not is_instance_valid(barco) or barco.health > 0
	if navio_ok:
		_concluir()
	else:
		aviso.emit("O navio precisa estar funcional para continuar.")


func _concluir() -> void:
	_concluido = true
	aviso.emit("Dominando os ventos do Índico, a expedição avança!")
	await get_tree().create_timer(1.5).timeout
	objetivo_concluido.emit()


func _setup_camera() -> void:
	await get_tree().process_frame
	var cam := get_node_or_null("Barco/Camera2D")
	if cam:
		cam.limit_left   = -600
		cam.limit_top    = -600
		cam.limit_right  = 2000
		cam.limit_bottom = 600