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

	# Cobre o caso de quem ja completou os 3 objetivos antes (por
	# exemplo, numa ordem que nao disparou a tela de conclusao devido
	# ao bug antigo) e volta a carregar esta cena - mostra a tela de
	# conclusao direto, sem travar o jogo.
	if GameManager.is_objective_complete(1, "bussola_ventos") \
	and GameManager.is_objective_complete(1, "caravela") \
	and GameManager.is_objective_complete(1, "astrolabio") \
	and GameManager.current_phase <= 1:
		_show_phase_complete()
		return

	if not _intro_shown and not GameManager.is_objective_complete(1, "bussola_ventos"):
		_intro_shown = true
		player.set_state(player.State.IN_DIALOG)
		dialog_box.start_dialog("intro")
		await dialog_box.dialog_finished
		dialog_box.start_dialog("mestre_intro")
		await dialog_box.dialog_finished
		player.set_state(player.State.EXPLORING)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		_open_pause_menu()
		get_viewport().set_input_as_handled()


func _setup_camera() -> void:
	await get_tree().process_frame
	var cam := player.get_node_or_null("Camera2D")
	if not cam:
		return

	# Calcula os limites da camera com base no tamanho/posicao REAIS do
	# sprite de fundo (em vez de depender das paredes fisicas estarem
	# alinhadas manualmente com a arte) - evita a faixa cinza sempre
	# que a imagem de fundo for trocada ou redimensionada no editor.
	var background: Sprite2D = get_node_or_null("Sprite2D")
	if background and background.texture:
		var tex_size: Vector2 = background.texture.get_size()
		var scaled_size: Vector2 = tex_size * background.scale
		var top_left: Vector2 = background.global_position
		if background.centered:
			top_left -= scaled_size / 2.0
		cam.limit_left   = int(top_left.x)
		cam.limit_top    = int(top_left.y)
		cam.limit_right  = int(top_left.x + scaled_size.x)
		cam.limit_bottom = int(top_left.y + scaled_size.y)

	cam.position_smoothing_enabled = true


func _open_pause_menu() -> void:
	var pause := _pause_menu_scene.instantiate()
	add_child(pause)


func _on_compass_interact() -> void:
	if GameManager.is_objective_complete(1, "bussola_ventos"):
		return
	SceneManager.change_scene("res://scenes/puzzles/fase1/compass_puzzle.tscn")


func _on_ship_interact() -> void:
	if GameManager.is_objective_complete(1, "caravela"):
		return
	if not GameManager.is_objective_complete(1, "bussola_ventos"):
		var lines := [{"speaker": "Mestre Navegador", "text": "Primeiro domine a bussola antes de partir ao mar!", "portrait": "mestre"}]
		dialog_box.start_dialog_direct(lines)
		return
	SceneManager.change_scene("res://scenes/puzzles/fase1/ship_navigation.tscn")


func _on_astrolabe_interact() -> void:
	if GameManager.is_objective_complete(1, "astrolabio"):
		return
	if not GameManager.is_objective_complete(1, "caravela"):
		var lines := [{"speaker": "Mestre Navegador", "text": "Antes das estrelas, prove-se no mar!", "portrait": "mestre"}]
		dialog_box.start_dialog_direct(lines)
		return
	SceneManager.change_scene("res://scenes/puzzles/fase1/astrolabe_puzzle.tscn")


const ORDEM_OBJETIVOS := ["bussola_ventos", "caravela", "astrolabio"]

func _on_objective_completed(phase: int, objective: String) -> void:
	if phase != 1:
		return

	match objective:
		"bussola_ventos":
			player.set_state(player.State.IN_DIALOG)
			dialog_box.start_dialog("mestre_bussola_complete")
			await dialog_box.dialog_finished
			player.set_state(player.State.EXPLORING)
		"caravela":
			player.set_state(player.State.IN_DIALOG)
			dialog_box.start_dialog("mestre_caravela_complete")
			await dialog_box.dialog_finished
			player.set_state(player.State.EXPLORING)
		"astrolabio":
			player.set_state(player.State.IN_DIALOG)
			dialog_box.start_dialog("mestre_astrolabio_complete")
			await dialog_box.dialog_finished
			player.set_state(player.State.EXPLORING)

	# Verifica se TODOS os objetivos da fase ja foram concluidos,
	# independente da ordem em que o jogador os completou - antes,
	# so o astrolabio (por ser sempre o "ultimo" assumido) disparava
	# a tela de conclusao, entao terminar em outra ordem deixava o
	# jogo travado sem avancar.
	for obj in ORDEM_OBJETIVOS:
		if not GameManager.is_objective_complete(1, obj):
			return

	await get_tree().create_timer(0.5).timeout
	_show_phase_complete()


func _show_phase_complete() -> void:
	player.set_state(player.State.IN_DIALOG)
	dialog_box.start_dialog("conclusao")
	await dialog_box.dialog_finished
	GameManager.finish_phase(1)
	SceneManager.change_scene("res://scenes/main/phase_complete.tscn")
