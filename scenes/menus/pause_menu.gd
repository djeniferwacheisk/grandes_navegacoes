extends CanvasLayer

@onready var resume_button: Button = $BookBG/PaginaDireita/BtnContinuar/ResumeButton
@onready var save_button: Button = $BookBG/PaginaDireita/BtnSalvar/SaveButton
@onready var menu_button: Button = $BookBG/PaginaDireita/BtnSair/MenuButton

# Referências para hover
@onready var btn_continuar: Control = $BookBG/PaginaDireita/BtnContinuar
@onready var btn_salvar: Control = $BookBG/PaginaDireita/BtnSalvar
@onready var btn_sair: Control = $BookBG/PaginaDireita/BtnSair


func _ready() -> void:
	get_tree().paused = true

	# Conecta botões
	resume_button.pressed.connect(_on_resume)
	save_button.pressed.connect(_on_save)
	menu_button.pressed.connect(_on_menu)

	# Hover — escala sutil
	_setup_hover(resume_button, btn_continuar)
	_setup_hover(save_button, btn_salvar)
	_setup_hover(menu_button, btn_sair)

	# Remove borda branca de foco
	_clear_focus_style(resume_button)
	_clear_focus_style(save_button)
	_clear_focus_style(menu_button)

	# Pivot central para escala correta
	btn_continuar.pivot_offset = btn_continuar.size / 2
	btn_salvar.pivot_offset = btn_salvar.size / 2
	btn_sair.pivot_offset = btn_sair.size / 2

	# Animação de abertura
	$BookBG.pivot_offset = $BookBG.size / 2
	$BookBG.scale = Vector2(0.9, 0.9)
	$BookBG.modulate.a = 0.0
	var tween := create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween.set_parallel(true)
	tween.tween_property($BookBG, "scale", Vector2(1.0, 1.0), 0.3)
	tween.tween_property($BookBG, "modulate:a", 1.0, 0.2)

	resume_button.grab_focus()


func _setup_hover(button: Button, visual: Control) -> void:
	button.mouse_entered.connect(func():
		var tw := create_tween().set_ease(Tween.EASE_OUT)
		tw.tween_property(visual, "scale", Vector2(1.05, 1.05), 0.1)
	)
	button.mouse_exited.connect(func():
		var tw := create_tween().set_ease(Tween.EASE_OUT)
		tw.tween_property(visual, "scale", Vector2(1.0, 1.0), 0.1)
	)


func _clear_focus_style(button: Button) -> void:
	var empty := StyleBoxEmpty.new()
	button.add_theme_stylebox_override("focus", empty)


func _on_resume() -> void:
	var tween := create_tween().set_ease(Tween.EASE_IN)
	tween.set_parallel(true)
	tween.tween_property($BookBG, "scale", Vector2(0.9, 0.9), 0.2)
	tween.tween_property($BookBG, "modulate:a", 0.0, 0.15)
	await tween.finished
	get_tree().paused = false
	queue_free()


func _on_save() -> void:
	GameManager.save_game()


func _on_menu() -> void:
	get_tree().paused = false
	SceneManager.change_scene("res://scenes/menus/title_screen.tscn")
	queue_free()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		_on_resume()
		get_viewport().set_input_as_handled()
