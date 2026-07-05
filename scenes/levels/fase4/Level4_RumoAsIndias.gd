## Level4_RumoAsIndias.gd
## Mapa principal da Fase 4 — player anda e interage com os 3 puzzles

extends Node2D

var _pause_menu_scene := preload("res://scenes/menus/pause_menu.tscn")

const TRIGGER_POSITIONS := {
	"tripulacao_viva":  Vector2(-250, 500),
	"mercado_calecute": Vector2(874, 220),
}
const TRIGGER_NOMES := {
	"tripulacao_viva":  "Tripulação Viva",
	"mercado_calecute": "Mercado de Calecute",
}
const ORDEM := ["tripulacao_viva", "mercado_calecute"]

@onready var player:          CharacterBody2D = $Player
@onready var compass_pivot:   Control         = $HUD_Fase4/ShipCompass/NeedlePivot
@onready var target_label:    Label           = $HUD_Fase4/ShipCompass/TargetLabel
@onready var lista_objetivos: VBoxContainer   = $HUD_Fase4/Objetivos/VBox/Lista


func _ready() -> void:
	GameManager.objective_completed.connect(_on_objective_completed)
	_setup_camera()
	_montar_lista_objetivos()

	await get_tree().create_timer(0.5).timeout

	# Cobre o caso de voltar do Mercado de Calecute (ou da Tripulacao
	# Viva) ja com os 2 objetivos completos - o sinal de conclusao e
	# emitido pela cena do puzzle, que roda ANTES desta cena estar
	# carregada e escutando, entao ninguem reagia e a fase ficava presa
	# aqui, sem terminar.
	if GameManager.is_objective_complete(4, "tripulacao_viva") \
	and GameManager.is_objective_complete(4, "mercado_calecute") \
	and GameManager.current_phase <= 4:
		GameManager.finish_phase(4)
		SceneManager.change_scene("res://scenes/main/phase_complete.tscn")
		return

	if not GameManager.is_objective_complete(4, "tripulacao_viva"):
		player.set_state(player.State.IN_DIALOG)
		var dialog = _get_dialog()
		if dialog:
			dialog.start_dialog_direct([
				{"speaker": "Vasco da Gama",
				 "text": "O Cabo da Boa Esperança ficou para trás. Buscamos uma rota segura para as Índias.",
				 "portrait": ""},
				{"speaker": "Navegador",
				 "text": "Dois desafios nos aguardam: a tripulação e o mercado de Calecute.",
				 "portrait": ""},
			])
			await dialog.dialog_finished
		player.set_state(player.State.EXPLORING)


func _setup_camera() -> void:
	await get_tree().process_frame
	var cam := player.get_node_or_null("Camera2D")
	if cam:
		cam.limit_left   = -553
		cam.limit_top    = -278
		cam.limit_right  = 1089
		cam.limit_bottom = 611
		cam.position_smoothing_enabled = true


func _get_dialog() -> Node:
	return get_node_or_null("DialogBox")


func _process(_delta: float) -> void:
	_update_compass()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		var pause := _pause_menu_scene.instantiate()
		add_child(pause)
		get_viewport().set_input_as_handled()


func _update_compass() -> void:
	if not is_instance_valid(player):
		return

	var proximo: String = ""
	for obj in ORDEM:
		if not GameManager.is_objective_complete(4, obj):
			proximo = obj
			break

	if proximo == "":
		target_label.text = "Completo!"
		compass_pivot.visible = false
		return

	compass_pivot.visible = true
	var target: Vector2 = TRIGGER_POSITIONS[proximo]
	var direction := target - player.global_position
	compass_pivot.rotation = direction.angle() + PI / 2.0
	target_label.text = TRIGGER_NOMES[proximo]


func _montar_lista_objetivos() -> void:
	for c in lista_objetivos.get_children():
		c.queue_free()

	for obj in ORDEM:
		var feito := GameManager.is_objective_complete(4, obj)
		var lbl := Label.new()
		lbl.text = "%s %s" % ["✓" if feito else "○", TRIGGER_NOMES[obj]]
		lbl.add_theme_font_size_override("font_size", 9)
		if feito:
			lbl.add_theme_color_override("font_color", Color(0.45, 0.85, 0.45))
		lista_objetivos.add_child(lbl)


func _on_tripulacao_interact() -> void:
	if GameManager.is_objective_complete(4, "tripulacao_viva"):
		_falar("Tripulação", "A tripulação sobreviveu! Seguimos em frente.")
		return
	SceneManager.change_scene("res://scenes/puzzles/fase4/Area_TripulacaoViva.tscn")


func _on_mercado_interact() -> void:
	if not GameManager.is_objective_complete(4, "tripulacao_viva"):
		_falar("Navegador", "Primeiro precisamos garantir os suprimentos da tripulação!")
		return
	if GameManager.is_objective_complete(4, "mercado_calecute"):
		_falar("Comerciante", "As especiarias já foram negociadas. Boa viagem!")
		return
	SceneManager.change_scene("res://scenes/puzzles/fase4/Area_MercadoCalecute.tscn")


func _on_objective_completed(phase: int, objective: String) -> void:
	if phase != 4:
		return
	_montar_lista_objetivos()
	match objective:
		"tripulacao_viva":
			_falar("Tripulação", "Sobrevivemos! O mercado de Calecute nos aguarda.")
		"mercado_calecute":
			await _falar("Vasco da Gama", "Em 1498, chegamos às Índias! O caminho das especiarias está aberto.")
			await get_tree().create_timer(0.5).timeout
			GameManager.finish_phase(4)
			SceneManager.change_scene("res://scenes/main/phase_complete.tscn")


func _falar(personagem: String, texto: String) -> void:
	var dialog = _get_dialog()
	if not dialog:
		return
	player.set_state(player.State.IN_DIALOG)
	dialog.start_dialog_direct([{"speaker": personagem, "text": texto, "portrait": ""}])
	await dialog.dialog_finished
	player.set_state(player.State.EXPLORING)
