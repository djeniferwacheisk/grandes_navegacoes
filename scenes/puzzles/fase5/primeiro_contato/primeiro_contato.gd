extends Node2D

var presente_dado: bool = false
var contato_feito: bool = false

# Minigame de gestos
var gestos_sequencia: Array[String] = []
var gesto_atual: int = 0
var minigame_ativo: bool = false

const GESTOS := {
	"ui_left":  "←",
	"ui_right": "→",
	"ui_up":    "↑",
	"ui_down":  "↓"
}
const KEYS_GESTOS := ["ui_left", "ui_right", "ui_up", "ui_down"]

@onready var player: CharacterBody2D = $Player
@onready var dialog_box = $DialogBox
@onready var painel_gesto: Panel = $HUD/PainelGesto
@onready var label_gesto: Label = $HUD/PainelGesto/LabelGesto
@onready var label_instrucao: Label = $HUD/PainelGesto/LabelInstrucao
@onready var label_progresso: Label = $HUD/PainelGesto/LabelProgresso

func _ready() -> void:
	dialog_box.add_to_group("dialog_box")
	painel_gesto.visible = false

	await get_tree().create_timer(0.5).timeout
	player.set_state(player.State.IN_DIALOG)
	dialog_box.start_dialog_direct([
		{"speaker": "Narrador", "text": "Na praia, um grupo de Tupiniquins observa os visitantes com curiosidade.", "portrait": ""},
		{"speaker": "Narrador", "text": "Ofereça um presente e depois imite os gestos deles para demonstrar amizade.", "portrait": ""}
	])
	await dialog_box.dialog_finished
	player.set_state(player.State.EXPLORING)

func _input(event: InputEvent) -> void:
	if not minigame_ativo:
		return

	for action in KEYS_GESTOS:
		if event.is_action_pressed(action):
			_checar_gesto(action)
			return

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
		{"speaker": "Narrador", "text": "Um Tupiniquim faz gestos com as mãos. Imite-os para demonstrar amizade!", "portrait": ""},
		{"speaker": "Narrador", "text": "Use as setas do teclado para imitar os gestos. Acerte 5 seguidos!", "portrait": ""}
	])
	await dialog_box.dialog_finished
	_iniciar_minigame_gestos()

func _iniciar_minigame_gestos() -> void:
	# Gera sequência aleatória de 5 gestos
	gestos_sequencia.clear()
	gesto_atual = 0
	for i in range(5):
		gestos_sequencia.append(KEYS_GESTOS[randi() % 4])

	minigame_ativo = true
	painel_gesto.visible = true
	_mostrar_proximo_gesto()

func _mostrar_proximo_gesto() -> void:
	var gesto := gestos_sequencia[gesto_atual]
	label_gesto.text = GESTOS[gesto]
	label_instrucao.text = "Imite o gesto do Tupiniquim!"
	label_progresso.text = "Gesto %d / 5" % (gesto_atual + 1)

func _checar_gesto(action: String) -> void:
	if action == gestos_sequencia[gesto_atual]:
		gesto_atual += 1
		label_gesto.text = "✓"
		if gesto_atual >= gestos_sequencia.size():
			_minigame_sucesso()
		else:
			await get_tree().create_timer(0.3).timeout
			_mostrar_proximo_gesto()
	else:
		# Erro — reinicia a sequência
		label_gesto.text = "✗"
		label_instrucao.text = "Errou! Recomeçando..."
		await get_tree().create_timer(0.6).timeout
		gesto_atual = 0
		_mostrar_proximo_gesto()

func _minigame_sucesso() -> void:
	minigame_ativo = false
	painel_gesto.visible = false
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
