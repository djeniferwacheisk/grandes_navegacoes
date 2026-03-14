extends Node2D

var _intro_shown := false
var _pause_menu_scene := preload("res://scenes/menus/pause_menu.tscn")

@onready var player: CharacterBody2D = $Player
@onready var dialog_box = $DialogBox
@onready var hud = $HUD


func _ready() -> void:
	dialog_box.add_to_group("dialog_box")

	GameManager.objective_completed.connect(_on_objective_completed)

	await get_tree().create_timer(0.5).timeout
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


func _open_pause_menu() -> void:
	var pause := _pause_menu_scene.instantiate()
	add_child(pause)


func _on_compass_interact() -> void:
	if GameManager.is_objective_complete(1, "bussola_ventos"):
		return
	SceneManager.change_scene("res://scenes/puzzles/compass_puzzle.tscn")


func _on_ship_interact() -> void:
	if GameManager.is_objective_complete(1, "caravela"):
		return
	if not GameManager.is_objective_complete(1, "bussola_ventos"):
		var lines := [{"speaker": "Mestre Navegador", "text": "Primeiro domine a bussola antes de partir ao mar!", "portrait": "mestre"}]
		dialog_box.start_dialog_direct(lines)
		return
	SceneManager.change_scene("res://scenes/puzzles/ship_navigation.tscn")


func _on_astrolabe_interact() -> void:
	if GameManager.is_objective_complete(1, "astrolabio"):
		return
	if not GameManager.is_objective_complete(1, "caravela"):
		var lines := [{"speaker": "Mestre Navegador", "text": "Antes das estrelas, prove-se no mar!", "portrait": "mestre"}]
		dialog_box.start_dialog_direct(lines)
		return
	SceneManager.change_scene("res://scenes/puzzles/astrolabe_puzzle.tscn")


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
			await get_tree().create_timer(0.5).timeout
			_show_phase_complete()


func _show_phase_complete() -> void:
	player.set_state(player.State.IN_DIALOG)
	dialog_box.start_dialog("conclusao")
	await dialog_box.dialog_finished
	SceneManager.change_scene("res://scenes/main/phase_complete.tscn")
