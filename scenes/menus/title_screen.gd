extends Control

@onready var play_button: Button = $Opcoes/VBoxContainer/Start
@onready var new_game_button: Button = $Opcoes/VBoxContainer/NewGame
@onready var settings_button: Button = $Opcoes/VBoxContainer/Ajustes
@onready var quit_button: Button = $Opcoes/VBoxContainer/Exit


func _ready() -> void:
	play_button.pressed.connect(_on_play)
	new_game_button.pressed.connect(_on_new_game)
	settings_button.pressed.connect(_on_settings)
	quit_button.pressed.connect(_on_quit)

	var has_save := FileAccess.file_exists("user://save_data.json")
	play_button.visible = has_save
	new_game_button.text = "Novo Jogo" if has_save else "Iniciar Expedição"
	if has_save:
		play_button.grab_focus()
	else:
		new_game_button.grab_focus()


func _on_play() -> void:
	var anim = play_button.get_node_or_null("uiAnimationComponent")
	if anim:
		anim.cleanup()
	SceneManager.change_scene("res://scenes/main/main.tscn")


func _on_new_game() -> void:
	var anim = new_game_button.get_node_or_null("uiAnimationComponent")
	if anim:
		anim.cleanup()
	GameManager.reset_game()
	SceneManager.change_scene("res://scenes/main/main.tscn")


func _on_settings() -> void:
	var anim = settings_button.get_node_or_null("uiAnimationComponent")
	if anim:
		anim.cleanup()
	var settings := preload("res://scenes/menus/settings_menu.tscn").instantiate()
	add_child(settings)


func _on_quit() -> void:
	var anim = quit_button.get_node_or_null("uiAnimationComponent")
	if anim:
		anim.cleanup()
	get_tree().quit()
