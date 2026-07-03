extends Node2D

var etapa_atual: String = ""
var etapas_completas: Array[String] = []
var mashing_ativo: bool = false
var progresso_atual: float = 0.0
const PROGRESSO_MAX: float = 20.0

@onready var player: CharacterBody2D = $Player
@onready var dialog_box = $DialogBox
@onready var painel_mash: Panel = $HUD/PainelMash
@onready var label_acao: Label = $HUD/PainelMash/LabelAcao
@onready var barra_progresso: ProgressBar = $HUD/PainelMash/BarraProgresso
@onready var label_dica: Label = $HUD/PainelMash/LabelDica
@onready var sprite_arvore: AnimatedSprite2D = $SpriteArvore
@onready var sprite_cortar: AnimatedSprite2D = $SpriteCortar
@onready var sprite_cavar: AnimatedSprite2D = $SpriteCavar
@onready var sprite_buraco: AnimatedSprite2D = $SpriteBuraco
@onready var sprite_cruz: AnimatedSprite2D = $SpriteCruz
@onready var sprite_cruz_final: AnimatedSprite2D = $SpriteCruzFinal

func _ready() -> void:
	dialog_box.add_to_group("dialog_box")
	painel_mash.visible = false
	sprite_buraco.visible = false
	sprite_cruz.visible = false
	sprite_cruz_final.visible = false

	await get_tree().create_timer(0.5).timeout
	player.set_state(player.State.IN_DIALOG)
	dialog_box.start_dialog_direct([
		{"speaker": "Narrador", "text": "Era necessário erguer uma cruz para marcar a posse da terra em nome de Portugal.", "portrait": ""},
		{"speaker": "Cartógrafo", "text": "Precisamos cortar a madeira, cavar o buraco e erguer a cruz. Mãos à obra!", "portrait": ""}
	])
	await dialog_box.dialog_finished
	player.set_state(player.State.EXPLORING)

func _input(event: InputEvent) -> void:
	if not mashing_ativo:
		return
	if event.is_action_pressed("interact"):
		_avancar_progresso()

func _avancar_progresso() -> void:
	progresso_atual += 1.0
	barra_progresso.value = progresso_atual

	if etapa_atual == "tronco":
		var frame_idx: int = int((progresso_atual / PROGRESSO_MAX) * 7)
		sprite_arvore.frame = frame_idx

	if etapa_atual == "alinhar":
		var frame_idx: int = int((progresso_atual / PROGRESSO_MAX) * 6)
		sprite_cruz.frame = frame_idx

	if progresso_atual >= PROGRESSO_MAX:
		_concluir_etapa()

func _on_tronco_interact() -> void:
	if "tronco" in etapas_completas:
		player.set_state(player.State.IN_DIALOG)
		dialog_box.start_dialog_direct([{"speaker": "Cartógrafo", "text": "Madeira já cortada!", "portrait": ""}])
		await dialog_box.dialog_finished
		player.set_state(player.State.EXPLORING)
		return

	player.set_state(player.State.IN_DIALOG)
	dialog_box.start_dialog_direct([
		{"speaker": "Cartógrafo", "text": "Precisamos cortar troncos para fazer a cruz. Aperte E repetidamente para cortar!", "portrait": ""}
	])
	await dialog_box.dialog_finished
	_iniciar_mash("tronco", "🪓  Cortando madeira...", "Aperte E repetidamente!")

func _on_corda_interact() -> void:
	if not "tronco" in etapas_completas:
		player.set_state(player.State.IN_DIALOG)
		dialog_box.start_dialog_direct([{"speaker": "Cartógrafo", "text": "Primeiro precisamos cortar os troncos.", "portrait": ""}])
		await dialog_box.dialog_finished
		player.set_state(player.State.EXPLORING)
		return

	if "corda" in etapas_completas:
		player.set_state(player.State.IN_DIALOG)
		dialog_box.start_dialog_direct([{"speaker": "Cartógrafo", "text": "O buraco já está cavado!", "portrait": ""}])
		await dialog_box.dialog_finished
		player.set_state(player.State.EXPLORING)
		return

	player.set_state(player.State.IN_DIALOG)
	dialog_box.start_dialog_direct([
		{"speaker": "Cartógrafo", "text": "Agora precisamos cavar o buraco para firmar a cruz na areia. Aperte E repetidamente!", "portrait": ""}
	])
	await dialog_box.dialog_finished
	_iniciar_mash("corda", "⛏  Cavando o buraco...", "Aperte E repetidamente!")

func _on_alinhar_interact() -> void:
	if not "corda" in etapas_completas:
		player.set_state(player.State.IN_DIALOG)
		dialog_box.start_dialog_direct([{"speaker": "Cartógrafo", "text": "Precisamos cavar o buraco primeiro.", "portrait": ""}])
		await dialog_box.dialog_finished
		player.set_state(player.State.EXPLORING)
		return

	if "alinhar" in etapas_completas:
		return

	player.set_state(player.State.IN_DIALOG)
	dialog_box.start_dialog_direct([
		{"speaker": "Cartógrafo", "text": "Agora erguemos a cruz! Todos juntos — aperte E repetidamente para erguer!", "portrait": ""}
	])
	await dialog_box.dialog_finished
	_iniciar_mash("alinhar", "✝  Erguendo a cruz...", "Aperte E repetidamente!")

func _iniciar_mash(etapa: String, texto_acao: String, dica: String) -> void:
	etapa_atual = etapa
	progresso_atual = 0.0
	mashing_ativo = true

	barra_progresso.max_value = PROGRESSO_MAX
	barra_progresso.value = 0.0
	label_acao.text = texto_acao
	label_dica.text = dica
	painel_mash.visible = true

	if etapa == "tronco":
		player.visible = false
		sprite_cortar.visible = true
		sprite_cortar.play("cortar")
		sprite_arvore.frame = 0
		sprite_arvore.stop()
	elif etapa == "corda":
		player.visible = false
		sprite_cavar.visible = true
		sprite_cavar.frame = 0
		sprite_cavar.play("cavar")
	elif etapa == "alinhar":
		player.visible = false
		sprite_cruz.visible = true
		sprite_cruz.frame = 0
		sprite_cruz.stop()
	else:
		sprite_cortar.visible = false
		sprite_cavar.visible = false
		sprite_cruz.visible = false
		player.visible = true

func _concluir_etapa() -> void:
	mashing_ativo = false
	painel_mash.visible = false
	player.visible = true
	etapas_completas.append(etapa_atual)

	if etapa_atual == "tronco":
		sprite_cortar.visible = false
		sprite_arvore.play("caindo")
		await sprite_arvore.animation_finished
	elif etapa_atual == "corda":
		sprite_cavar.stop()
		sprite_cavar.visible = false
		sprite_buraco.visible = true
	elif etapa_atual == "alinhar":
		sprite_cruz.visible = false
		sprite_cruz_final.visible = true
		sprite_cruz_final.play("idle")

	var msgs := {
		"tronco": [
			{"speaker": "Narrador", "text": "✓ Troncos cortados! A madeira é do Pau-brasil, árvore que daria nome ao país.", "portrait": ""}
		],
		"corda": [
			{"speaker": "Narrador", "text": "✓ Buraco cavado! A cruz precisa ficar firme para resistir ao vento do litoral.", "portrait": ""}
		],
		"alinhar": [
			{"speaker": "Narrador", "text": "✓ Cruz erguida e voltada ao sol nascente — direção leste, símbolo cristão da esperança.", "portrait": ""},
			{"speaker": "Narrador", "text": "Pero Vaz de Caminha escreveu ao Rei Dom Manuel I descrevendo cada detalhe. Esta carta é o primeiro documento escrito sobre o Brasil.", "portrait": ""}
		]
	}

	player.set_state(player.State.IN_DIALOG)
	dialog_box.start_dialog_direct(msgs[etapa_atual])
	await dialog_box.dialog_finished
	player.set_state(player.State.EXPLORING)

	if etapas_completas.size() >= 3:
		await get_tree().create_timer(0.5).timeout
		_completar()

func _completar() -> void:
	player.set_state(player.State.IN_DIALOG)
	dialog_box.start_dialog_direct([
		{"speaker": "Narrador", "text": "A cruz foi erguida na praia. Toda a tripulação se ajoelhou diante dela.", "portrait": ""},
		{"speaker": "Narrador", "text": "Este momento marcou oficialmente o início da história do Brasil.", "portrait": ""}
	])
	await dialog_box.dialog_finished
	GameManager.complete_objective(5, "puzzle_cruz")
	SceneManager.change_scene("res://scenes/levels/fase5/fase5_brasil.tscn")
