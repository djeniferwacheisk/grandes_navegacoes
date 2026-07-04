extends Node2D

var _intro_shown := false
var _pause_menu_scene := preload("res://scenes/menus/pause_menu.tscn")

@onready var player: CharacterBody2D = $Player
@onready var dialog_box = $DialogBox
@onready var hud = $HUD

func _ready() -> void:
	dialog_box.add_to_group("dialog_box")
	GameManager.objective_completed.connect(_on_objective_completed)
	_setup_camera()

	await get_tree().create_timer(0.5).timeout
	if not _intro_shown and not GameManager.is_objective_complete(5, "explorar_costa"):
		_intro_shown = true
		player.set_state(player.State.IN_DIALOG)
		dialog_box.start_dialog_direct([
			{"speaker": "Narrador", "text": "22 de abril de 1500. Após desviar-se da rota rumo às Índias, a frota de Cabral avista terras desconhecidas.", "portrait": ""},
			{"speaker": "Narrador", "text": "Veremos o que nos aguarda do outro lado do oceano...", "portrait": ""}
		])
		await dialog_box.dialog_finished
		player.set_state(player.State.EXPLORING)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		var pause := _pause_menu_scene.instantiate()
		add_child(pause)
		get_viewport().set_input_as_handled()

func _setup_camera() -> void:
	await get_tree().process_frame
	var cam := player.get_node_or_null("Camera2D")
	if not cam:
		return

	# Calcula os limites da camera com base no tamanho/posicao REAIS do
	# sprite de fundo (em vez de numeros fixos) - assim, se a imagem for
	# reposicionada ou redimensionada no editor, a camera nunca mostra
	# alem da area realmente desenhada.
	var background: Sprite2D = get_node_or_null("Fundo/Background")
	if background and background.texture:
		var tex_size: Vector2 = background.texture.get_size()
		var half_size: Vector2 = (tex_size * background.scale) / 2.0
		var center: Vector2 = background.global_position
		cam.limit_left   = int(center.x - half_size.x)
		cam.limit_top    = int(center.y - half_size.y)
		cam.limit_right  = int(center.x + half_size.x)
		cam.limit_bottom = int(center.y + half_size.y)
	else:
		cam.limit_left   = 0
		cam.limit_top    = 0
		cam.limit_right  = 1152
		cam.limit_bottom = 510

	cam.position_smoothing_enabled = true

func _on_explorar_interact() -> void:
	if GameManager.is_objective_complete(5, "explorar_costa"):
		return
	SceneManager.change_scene("res://scenes/puzzles/fase5/explorar_costa/explorar_costa.tscn")

func _on_contato_interact() -> void:
	if GameManager.is_objective_complete(5, "primeiro_contato"):
		return
	if not GameManager.is_objective_complete(5, "explorar_costa"):
		dialog_box.start_dialog_direct([
			{"speaker": "Narrador", "text": "Primeiro explore o litoral antes de desembarcar.", "portrait": ""}
		])
		return
	SceneManager.change_scene("res://scenes/puzzles/fase5/primeiro_contato/primeiro_contato.tscn")

func _on_cruz_interact() -> void:
	if GameManager.is_objective_complete(5, "puzzle_cruz"):
		return
	if not GameManager.is_objective_complete(5, "primeiro_contato"):
		dialog_box.start_dialog_direct([
			{"speaker": "Narrador", "text": "Estabeleça o contato com os Tupiniquins antes de erguer a cruz.", "portrait": ""}
		])
		return
	SceneManager.change_scene("res://scenes/puzzles/fase5/puzzle_cruz/puzzle_cruz.tscn")

func _on_objective_completed(phase: int, objective: String) -> void:
	if phase != 5:
		return
	match objective:
		"explorar_costa":
			player.set_state(player.State.IN_DIALOG)
			dialog_box.start_dialog_direct([
				{"speaker": "Narrador", "text": "O litoral foi registrado no diário de bordo! Agora desembarque e encontre os habitantes desta terra.", "portrait": ""}
			])
			await dialog_box.dialog_finished
			player.set_state(player.State.EXPLORING)
		"primeiro_contato":
			player.set_state(player.State.IN_DIALOG)
			dialog_box.start_dialog_direct([
				{"speaker": "Narrador", "text": "O encontro foi pacífico! Os Tupiniquins sorriram e acenaram. Agora ajude a erguer a cruz.", "portrait": ""}
			])
			await dialog_box.dialog_finished
			player.set_state(player.State.EXPLORING)
		"puzzle_cruz":
			player.set_state(player.State.IN_DIALOG)
			dialog_box.start_dialog_direct([
				{"speaker": "Narrador", "text": "A cruz foi erguida voltada ao sol nascente, como descrito por Pero Vaz de Caminha.", "portrait": ""}
			])
			await dialog_box.dialog_finished
			await get_tree().create_timer(0.5).timeout
			_show_phase_complete()

func _show_phase_complete() -> void:
	player.set_state(player.State.IN_DIALOG)
	dialog_box.start_dialog_direct([
		{"speaker": "Narrador", "text": "A nova terra despertou curiosidade e maravilhamento. O encontro entre portugueses e povos originários marcaria para sempre a história do continente.", "portrait": ""}
	])
	await dialog_box.dialog_finished
	GameManager.finish_phase(5)
	SceneManager.change_scene("res://scenes/main/phase_complete.tscn")
