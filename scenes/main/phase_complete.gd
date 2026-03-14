extends Control

@onready var text_label: Label = $TextLabel
@onready var map_reveal: ColorRect = $MapReveal
@onready var continue_button: Button = $ContinueButton


func _ready() -> void:
	continue_button.visible = false
	continue_button.pressed.connect(_on_continue)
	map_reveal.modulate.a = 0.0

	text_label.text = ""
	var full_text := "Voce completou seu treinamento na Escola de Sagres!\n\nA proxima etapa aguarda..."

	# Typewriter effect
	for i in full_text.length():
		text_label.text = full_text.substr(0, i + 1)
		await get_tree().create_timer(0.03).timeout

	# Reveal map piece
	await get_tree().create_timer(0.5).timeout
	var tween := create_tween()
	tween.tween_property(map_reveal, "modulate:a", 1.0, 1.5)
	await tween.finished

	continue_button.visible = true
	continue_button.grab_focus()


func _on_continue() -> void:
	SceneManager.change_scene("res://scenes/menus/title_screen.tscn")
