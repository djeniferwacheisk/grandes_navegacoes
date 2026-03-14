extends CanvasLayer

@onready var resume_button: Button = $Panel/VBoxContainer/ResumeButton
@onready var settings_button: Button = $Panel/VBoxContainer/SettingsButton
@onready var menu_button: Button = $Panel/VBoxContainer/MenuButton


func _ready() -> void:
	resume_button.pressed.connect(_on_resume)
	settings_button.pressed.connect(_on_settings)
	menu_button.pressed.connect(_on_menu)
	get_tree().paused = true
	resume_button.grab_focus()


func _on_resume() -> void:
	get_tree().paused = false
	queue_free()


func _on_settings() -> void:
	var settings := preload("res://scenes/menus/settings_menu.tscn").instantiate()
	add_child(settings)


func _on_menu() -> void:
	get_tree().paused = false
	SceneManager.change_scene("res://scenes/menus/title_screen.tscn")
	queue_free()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		_on_resume()
		get_viewport().set_input_as_handled()
