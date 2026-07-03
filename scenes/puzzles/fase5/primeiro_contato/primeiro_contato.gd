extends Node2D

var _pause_menu_scene := preload("res://scenes/menus/pause_menu.tscn")

var presente_dado: bool = false
var contato_feito: bool = false

const TOTAL_GESTOS := 5
const ACOES: Array[String] = ["ui_left", "ui_right", "ui_up", "ui_down"]
const SIMBOLOS: Dictionary = {"ui_left": "←", "ui_right": "→", "ui_up": "↑", "ui_down": "↓"}

var sequencia: Array[int] = []
var acoes_sequencia: Array[String] = []
var gesto_atual: int = 0
var minigame_ativo: bool = false

@onready var player: CharacterBody2D = $Player
@onready var dialog_box = $DialogBox
@onready var painel_gesto: Panel = $HUD/PainelGesto
@onready var label_gesto: Label = $HUD/PainelGesto/LabelGesto
@onready var label_instrucao: Label = $HUD/PainelGesto/LabelInstrucao
@onready var label_progresso: Label = $HUD/PainelGesto/LabelProgresso
@onready var sprite_indio: AnimatedSprite2D = $SpriteIndio
@onready var sprite_portugues: AnimatedSprite2D = $SpritePortugues

func _ready() -> void:
	dialog_box.add_to_group("dialog_box")
	painel_gesto.visible = false
sprite_indio.visible = false
	sprite_portugues.visible = false
	_setup_camera()

	await get_tree().create_timer(0.5).timeout
	player.set_state(player.State.IN_DIALOG)
	dialog_box.start_dialog_direct([
		{"speaker": "Narrador", "text": "Na praia, um grupo de Tupiniquins observa os visitantes com curiosidade.", "portrait": ""},
		{"speaker": "Narrador", "text": "Ofereça um presente e depois imite os gestos deles para demonstrar amizade.", "portrait": ""}
	])
	await dialog_box.dialog_finished
	player.set_state(player.State.EXPLORING)

func _setup_camera() -> void:
	await get_tree().process_frame
	var cam := player.get_node_or_null("Camera2D")
	if cam:
		cam.limit_left   = 0
		cam.limit_top    = 0
		cam.limit_right  = 1152
		cam.limit_bottom = 510
		cam.position_smoothing_enabled = true

func _input(event: InputEvent) -> void:
	if not minigame_ativo:
		return
	for i in range(ACOES.size()):
		var acao: String = ACOES[i]
		if event.is_action_pressed(acao):
			_checar_gesto(acao)
			return

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		var pause := _pause_menu_scene.instantiate()
		add_child(pause)
		get_viewport().set_input_as_handled()

func _on_presente_interact() -> void:
	if presente_dado:
		player.set_state(player.State.IN_DIALOG)
		dialog_box.start_dialog_direct([{"speaker": "Cartógrafo", "text": "Já oferecemos os presentes.", "portrait": ""}])
		await dialog_box.dialog_finished
		player.set_state(player.State.EXPLORING)
		return

	presente_dado = true
	player.set_state(player.State.IN_DIALOG)
	dialog_box.start_dialog_direct([
		{"speaker": "Cartógrafo", "text": "Oferecemos espelhos e miçangas coloridas. Os Tupiniquins olham curiosos!", "portrait": ""},
		{"speaker": "Narrador", "text": "Oferecer presentes era a forma de demonstrar intenções pacíficas no primeiro contato entre povos.", "portrait": ""},
		{"speaker": "Narrador", "text": "✓ Presente oferecido! Agora aproxime-se e imite os gestos deles.", "portrait": ""}
	])
	await dialog_box.dialog_finished
	player.set_state(player.State.EXPLORING)

func _on_contato_interact() -> void:
	if not presente_dado:
		player.set_state(player.State.IN_DIALOG)
		dialog_box.start_dialog_direct([{"speaker": "Cartógrafo", "text": "Devemos primeiro oferecer presentes antes de nos aproximar.", "portrait": ""}])
		await dialog_box.dialog_finished
		player.set_state(player.State.EXPLORING)
		return

	if contato_feito:
		return

	player.set_state(player.State.IN_DIALOG)
	dialog_box.start_dialog_direct([
		{"speaker": "Tupiniquim", "text": "...", "portrait": ""},
		{"speaker": "Narrador", "text": "Um Tupiniquim faz gestos com as mãos. Imite-os usando as setas do teclado!", "portrait": ""},
		{"speaker": "Narrador", "text": "Acerte os 5 gestos para completar o contato!", "portrait": ""}
	])
	await dialog_box.dialog_finished
	_iniciar_minigame()

func _iniciar_minigame() -> void:
	sequencia.clear()
	acoes_sequencia.clear()
	gesto_atual = 0

	for i in range(TOTAL_GESTOS):
		var frame: int = randi() % 5
		var idx: int = randi() % 4
		var acao: String = ACOES[idx]
		sequencia.append(frame)
		acoes_sequencia.append(acao)

	minigame_ativo = true
	sprite_indio.visible = true
	sprite_portugues.visible = true
	painel_gesto.visible = true
	_mostrar_gesto()

func _mostrar_gesto() -> void:
	sprite_indio.frame = sequencia[gesto_atual]
	sprite_portugues.frame = 0
	var acao: String = acoes_sequencia[gesto_atual]
	label_gesto.text = "Imite: " + SIMBOLOS[acao]
	label_instrucao.text = "Use as setas do teclado!"
	label_progresso.text = "Gesto %d / %d" % [gesto_atual + 1, TOTAL_GESTOS]

func _checar_gesto(acao: String) -> void:
	var esperado: String = acoes_sequencia[gesto_atual]
	if acao == esperado:
		sprite_portugues.frame = sequencia[gesto_atual]
		label_gesto.text = "✓ Correto!"
		await get_tree().create_timer(0.6).timeout
		gesto_atual += 1
		if gesto_atual >= TOTAL_GESTOS:
			_minigame_sucesso()
		else:
			_mostrar_gesto()
	else:
		sprite_portugues.frame = 0
		label_gesto.text = "✗ Errou! Tente: " + SIMBOLOS[esperado]
		await get_tree().create_timer(0.8).timeout
		_mostrar_gesto()

func _minigame_sucesso() -> void:
	minigame_ativo = false
	painel_gesto.visible = false
	sprite_indio.visible = false
	sprite_portugues.visible = false
	contato_feito = true

	player.set_state(player.State.IN_DIALOG)
	dialog_box.start_dialog_direct([
		{"speaker": "Tupiniquim", "text": "...", "portrait": ""},
		{"speaker": "Cartógrafo", "text": "Eles sorriram! A imitação dos gestos foi um sinal de respeito e abertura.", "portrait": ""},
		{"speaker": "Narrador", "text": "Os Tupiniquins eram o povo que habitava o litoral do atual Brasil. Viviam da pesca, caça e agricultura.", "portrait": ""},
		{"speaker": "Cartógrafo", "text": "Um deles nos entrega um colar cerimonial — gesto de amizade e acolhimento.", "portrait": ""},
		{"speaker": "Narrador", "text": "✓ 'Colar Cerimonial Tupiniquim' recebido — registro cultural, não item de poder.", "portrait": ""}
	])
	await dialog_box.dialog_finished
	_completar()

func _completar() -> void:
	dialog_box.start_dialog_direct([
		{"speaker": "Narrador", "text": "O primeiro contato terminou em paz. Os Tupiniquins sorriram e acenaram ao partir.", "portrait": ""}
	])
	await dialog_box.dialog_finished
	player.set_state(player.State.EXPLORING)
	GameManager.complete_objective(5, "primeiro_contato")
	SceneManager.change_scene("res://scenes/levels/fase5/fase5_brasil.tscn")
