extends Control

@onready var play_button: Button = $VBoxContainer/PlayButton
@onready var new_game_button: Button = $VBoxContainer/NewGameButton
@onready var settings_button: Button = $VBoxContainer/SettingsButton
@onready var quit_button: Button = $VBoxContainer/QuitButton


func _ready() -> void:
	play_button.pressed.connect(_on_play)
	new_game_button.pressed.connect(_on_new_game)
	settings_button.pressed.connect(_on_settings)
	quit_button.pressed.connect(_on_quit)

	var has_save := FileAccess.file_exists("user://save_data.json")
	play_button.visible = has_save
	new_game_button.text = "Novo Jogo" if has_save else "Jogar"
	play_button.grab_focus() if has_save else new_game_button.grab_focus()


func _on_play() -> void:
	SceneManager.change_scene("res://scenes/main/main.tscn")


func _on_new_game() -> void:
	GameManager.reset_game()
	SceneManager.change_scene("res://scenes/main/main.tscn")


func _on_settings() -> void:
	var settings := preload("res://scenes/menus/settings_menu.tscn").instantiate()
	add_child(settings)


func _on_quit() -> void:
	get_tree().quit()
