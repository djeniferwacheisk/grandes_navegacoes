extends Node2D

var _pause_menu_scene := preload("res://scenes/menus/pause_menu.tscn")

@onready var progresso_label: Label = $HUD/Progresso

func _ready() -> void:
	GameManager.fragmento_coletado.connect(_on_fragmento_coletado)
	GameManager.todos_fragmentos_coletados.connect(_on_fase_completa)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		var pause := _pause_menu_scene.instantiate()
		add_child(pause)
		get_viewport().set_input_as_handled()

func _on_fragmento_coletado(id: String, nome: String) -> void:
	var total = GameManager.fragmentos_coletados
	progresso_label.text = "Pontos: %d/3" % total

func _on_fase_completa() -> void:
	progresso_label.text = "Pontos: 3/3 
Completo!"
