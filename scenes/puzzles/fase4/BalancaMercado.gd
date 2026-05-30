## BalancaMercado.gd
## Cena BASE do puzzle de balança do Mercado de Calecute.

extends Control

# ── Configuração da troca ────────────────────────────────────────────────────
@export var nome_mercador:      String     = "Mercador"
@export var item_mercador:      String     = "Mercadoria"
@export var peso_alvo:          float      = 10.0
@export var chave_troca:        String     = "troca_generica"
@export var background_texture: Texture2D  = null
@export var item_texture:       Texture2D  = null
# Posição e tamanho do item no prato. Ajuste por cena no Inspector.
# position = (offset_left, offset_top), size = (largura, altura)
@export var item_offset: Rect2 = Rect2(-44.0, -14.0, 63.0, 84.0)
@export var item_rotation: float = -18.0

@export var itens_disponiveis: Dictionary = {
	"Pimenta":    {"peso": 2.0, "cor": Color(0.85, 0.15, 0.1),  "icone": "saco_pimenta"},
	"Cravo":      {"peso": 3.0, "cor": Color(0.5,  0.25, 0.05), "icone": "saco_cravo"},
	"Canela":     {"peso": 4.0, "cor": Color(0.75, 0.38, 0.08), "icone": "saco_canela"},
	"Cardamomo":  {"peso": 2.0, "cor": Color(0.7,  0.8,  0.3),  "icone": "saco_cardamomo"},
}

@export var cena_retorno: String = "res://scenes/puzzles/fase4/Area_MercadoCalecute.tscn"

const MARGEM     := 1.5
const ICONE_BASE := "res://assets/especiarias/%s.png"

var _tween:         Tween = null
var peso_atual:     float = 0.0
var _concluido:     bool  = false
var _sacos_sprites: Array = []   # sprites dos sacos no prato esquerdo

@onready var background:       TextureRect   = $Background
@onready var label_oferta:     Label         = $PratoDir/VBox/LabelOferta
@onready var label_alvo:       Label         = $LabelAlvo
@onready var label_atual:      Label         = $LabelAtual
@onready var braco_pivot:      Control       = $BalancaVisual/BracoPivot
@onready var hang_esq:         Control       = $BalancaVisual/BracoPivot/HangEsq
@onready var prato_esq_itens:  VBoxContainer = $PratoEsq/VBox/Itens
@onready var label_feedback:   Label         = $LabelFeedback
@onready var btn_confirmar:    Button        = $BotoesHBox/BtnConfirmar
@onready var btn_limpar:       Button        = $BotoesHBox/BtnLimpar
@onready var btn_voltar:       Button        = $BotoesHBox/BtnFechar
@onready var container_botoes: VBoxContainer = $ContainerEspeciarias


func _ready() -> void:
	btn_confirmar.pressed.connect(_on_confirmar)
	btn_limpar.pressed.connect(_on_limpar)
	btn_voltar.pressed.connect(_voltar_mercado)
	btn_voltar.text = "Voltar"

	if background and background_texture:
		background.texture = background_texture

	label_oferta.text = "%s\nPeso alvo: %.0f" % [item_mercador, peso_alvo]
	label_alvo.text   = "Necessário: %.0f" % peso_alvo
	label_atual.text  = "Sua oferta: 0"
	label_feedback.text = ""

	_adicionar_item_mercador()
	_criar_botoes()
	_inclinar_inicial()


func _inclinar_inicial() -> void:
	# Balança começa inclinada para o lado do mercador (prato direito mais pesado)
	var angulo: float = clamp(peso_alvo * 2.0, -18.0, 18.0)
	braco_pivot.rotation_degrees = angulo


func _adicionar_item_mercador() -> void:
	if not item_texture:
		return
	var hang_dir := $BalancaVisual/BracoPivot/HangDir
	var sprite := TextureRect.new()
	sprite.texture = item_texture
	sprite.expand_mode = 1
	sprite.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	sprite.layout_mode = 0
	sprite.offset_left   = item_offset.position.x
	sprite.offset_top    = item_offset.position.y
	sprite.offset_right  = item_offset.position.x + item_offset.size.x
	sprite.offset_bottom = item_offset.position.y + item_offset.size.y
	sprite.rotation_degrees = item_rotation
	hang_dir.add_child(sprite)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and not _concluido:
		_voltar_mercado()


func _criar_botoes() -> void:
	for nome in itens_disponiveis:
		var dados = itens_disponiveis[nome]
		var btn   := Button.new()
		btn.custom_minimum_size = Vector2(40, 40)
		btn.add_theme_font_size_override("font_size", 9)

		# Tenta carregar ícone do saco
		var icone_nome: String = dados.get("icone", "saco_%s" % nome.to_lower())
		var icone_path: String = ICONE_BASE % icone_nome
		if ResourceLoader.exists(icone_path):
			btn.icon = load(icone_path)
			btn.expand_icon = true
			btn.icon_alignment = HORIZONTAL_ALIGNMENT_LEFT
			btn.text = "%.0f" % dados["peso"]
		else:
			btn.text = "%s\n%.0f" % [nome, dados["peso"]]
			btn.modulate = dados["cor"]

		btn.pressed.connect(_adicionar_saco.bind(nome))
		container_botoes.add_child(btn)


func _adicionar_saco(nome: String) -> void:
	if _concluido:
		return
	peso_atual += itens_disponiveis[nome]["peso"]

	# Label na lista de itens (esquerda)
	var lbl := Label.new()
	lbl.text = "Saco de %s  (+%.0f)" % [nome, itens_disponiveis[nome]["peso"]]
	lbl.add_theme_font_size_override("font_size", 8)
	prato_esq_itens.add_child(lbl)

	# Sprite do saco empilhado no prato esquerdo — pirâmide: 3 embaixo, 2 no meio, 1 no topo
	var icone_nome: String = itens_disponiveis[nome].get("icone", "saco_%s" % nome.to_lower())
	var icone_path: String = ICONE_BASE % icone_nome
	if ResourceLoader.exists(icone_path):
		var sprite := TextureRect.new()
		sprite.texture = load(icone_path)
		sprite.expand_mode = 1
		sprite.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		sprite.layout_mode = 0

		var idx        := _sacos_sprites.size()
		var saco_w     := 16.0
		var saco_h     := 16.0
		var base_y     := 28.0

		# Pirâmide: linha 0 = base (3 sacos), linha 1 = meio (2), linha 2 = topo (1)
		# idx:  0,1,2 → linha 0   |   3,4 → linha 1   |   5 → linha 2
		var linha: int
		var pos_na_linha: int
		var sacos_por_linha := [3, 2, 1]
		var acumulado := 0
		linha = 0
		pos_na_linha = 0
		for l in range(sacos_por_linha.size()):
			if idx < acumulado + sacos_por_linha[l]:
				linha = l
				pos_na_linha = idx - acumulado
				break
			acumulado += sacos_por_linha[l]

		var total_na_linha: int = sacos_por_linha[linha]
		# Centra os sacos da linha horizontalmente
		var espacamento := saco_w - 6.0
		var largura_linha := total_na_linha * espacamento - 6.0
		var x_inicio := -largura_linha / 2.0 -4.0

		sprite.offset_left   = x_inicio + pos_na_linha * espacamento
		sprite.offset_right  = sprite.offset_left + saco_w
		sprite.offset_top    = base_y - saco_h - linha * (saco_h - 7.0)
		sprite.offset_bottom = sprite.offset_top + saco_h

		hang_esq.add_child(sprite)
		_sacos_sprites.append(sprite)

	_atualizar_balanca()


func _atualizar_balanca() -> void:
	label_atual.text = "Sua oferta: %.0f" % peso_atual

	var diff:       float = peso_atual - peso_alvo
	var angulo_alvo: float = clamp(-diff * 2.0, -18.0, 18.0)

	if _tween:
		_tween.kill()
	_tween = create_tween()
	_tween.set_trans(Tween.TRANS_ELASTIC)
	_tween.set_ease(Tween.EASE_OUT)
	_tween.tween_property(braco_pivot, "rotation_degrees", angulo_alvo, 1.2)

	var diff_abs := absf(diff)
	if diff_abs <= MARGEM:
		label_atual.modulate = Color.GREEN
	elif diff_abs <= MARGEM * 3.0:
		label_atual.modulate = Color.YELLOW
	else:
		label_atual.modulate = Color.RED


func _on_limpar() -> void:
	peso_atual = 0.0
	for c in prato_esq_itens.get_children():
		c.queue_free()
	# Remove sprites do prato
	for s in _sacos_sprites:
		if is_instance_valid(s):
			s.queue_free()
	_sacos_sprites.clear()
	label_feedback.text  = ""
	label_atual.text     = "Sua oferta: 0"
	label_atual.modulate = Color.WHITE

	# Volta a inclinar pro lado do mercador
	if _tween:
		_tween.kill()
	_tween = create_tween()
	_tween.set_trans(Tween.TRANS_ELASTIC)
	_tween.set_ease(Tween.EASE_OUT)
	_tween.tween_property(braco_pivot, "rotation_degrees",
		clamp(peso_alvo * 2.0, -18.0, 18.0), 1.2)


func _on_confirmar() -> void:
	if _concluido:
		return
	if peso_atual <= 0:
		label_feedback.text    = "Coloque especiarias na balança primeiro!"
		label_feedback.modulate = Color.WHITE
		return

	var diff_abs := absf(peso_atual - peso_alvo)
	if diff_abs <= MARGEM:
		_aceitar()
	elif peso_atual < peso_alvo - MARGEM:
		label_feedback.text    = "%s: \"A oferta está abaixo do valor justo.\"" % nome_mercador
		label_feedback.modulate = Color.RED
	else:
		label_feedback.text    = "Vasco: \"Estamos dando especiarias demais!\""
		label_feedback.modulate = Color.YELLOW


func _aceitar() -> void:
	_concluido             = true
	label_feedback.text    = "%s: \"Boas trocas criam boas amizades!\"" % nome_mercador
	label_feedback.modulate = Color.GREEN
	btn_confirmar.disabled = true
	btn_limpar.disabled    = true
	btn_voltar.disabled    = true
	GameManager.set_phase_flag(4, chave_troca, true)
	GameManager.save_game()
	await get_tree().create_timer(1.5).timeout
	_voltar_mercado()


func _voltar_mercado() -> void:
	SceneManager.change_scene(cena_retorno)
