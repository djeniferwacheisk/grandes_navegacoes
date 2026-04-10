extends Node2D

const SHIP_SPEED := 80.0
const WIND_FORCE := 30.0
const MAP_COUNT := 3

var maps_collected := 0
var _active := true
var _wind_velocity := Vector2.ZERO

@onready var ship: CharacterBody2D = $Ship
@onready var camera: Camera2D = $Ship/Camera2D
@onready var maps_label: Label = $CanvasLayer/MapsLabel
@onready var hint_label: Label = $CanvasLayer/HintLabel
@onready var back_button: Button = $CanvasLayer/BackButton


func _ready() -> void:
	maps_label.text = "Mapas: 0/" + str(MAP_COUNT)
	hint_label.text = "Use WASD para navegar. Colete os 3 mapas!"
	back_button.pressed.connect(_on_back)
	for area in get_tree().get_nodes_in_group("map_collectible"):
		area.body_entered.connect(_on_map_collected.bind(area))
	for wind in get_tree().get_nodes_in_group("wind_zone"):
		wind.body_entered.connect(_on_wind_enter.bind(wind))
		wind.body_exited.connect(_on_wind_exit.bind(wind))
	var finish := get_tree().get_first_node_in_group("finish_zone")
	if finish:
		finish.body_entered.connect(_on_finish)
	await get_tree().create_timer(1.0).timeout
	hint_label.text = ""

func _on_map_collecte(_body: Node2D, area: Area2D) -> void:
	print("Colidiu com:", _body.name)

func _on_wind_enter(_body: Node2D, wind: Area2D) -> void:
	var dir: Vector2 = wind.get_meta("wind_direction", Vector2.RIGHT)
	ship.external_wind = dir * WIND_FORCE


func _on_wind_exit(_body: Node2D, _wind: Area2D) -> void:
	ship.external_wind = Vector2.ZERO


func _on_map_collected(_body: Node2D, area: Area2D) -> void:
	maps_collected += 1
	maps_label.text = "Mapas: " + str(maps_collected) + "/" + str(MAP_COUNT)
	area.queue_free()
	if maps_collected >= MAP_COUNT:
		hint_label.text = "Todos os mapas coletados! Va para a saida!"
		GameManager.add_item("Mapas de Navegacao", "Mapas das rotas maritimas")


func _on_finish(_body: Node2D) -> void:
	if maps_collected < MAP_COUNT:
		hint_label.text = "Colete todos os mapas primeiro!"
		return
	_active = false
	hint_label.text = "Navegacao concluida!"
	GameManager.complete_objective(1, "caravela")
	GameManager.save_game()
	await get_tree().create_timer(1.5).timeout
	SceneManager.change_scene("res://scenes/levels/fase1_sagres.tscn")


func _on_back() -> void:
	SceneManager.change_scene("res://scenes/levels/fase1_sagres.tscn")


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		_on_back()
