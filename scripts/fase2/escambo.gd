extends CanvasLayer

# Itens portugueses com os caminhos das texturas novas (AtlasTexture)
var itens_portugueses = [
	{"nome": "Pente", "valor": 2, "texture": preload("res://assets/fase2/pente.tres")},
	{"nome": "Tecido", "valor": 3, "texture": preload("res://assets/fase2/tecido.tres")},
	{"nome": "Espelho", "valor": 4, "texture": preload("res://assets/fase2/espelho.tres")},
]

# Itens locais com os caminhos das texturas novas (AtlasTexture)
var itens_locais = [
	{"nome": "Amuleto", "valor": 2, "texture": preload("res://assets/fase2/amuleto.tres")},
	{"nome": "Cerâmica", "valor": 3, "texture": preload("res://assets/fase2/ceramica.tres")},
	{"nome": "Especiaria", "valor": 4, "texture": preload("res://assets/fase2/especiaria.tres")},
]

var selecionado_portugues: Dictionary = {}
var selecionado_local: Dictionary = {}

@onready var botoes_portugueses: VBoxContainer = $Panel/Layout/HBox/LadoPortugues/Botoes
@onready var botoes_locais: VBoxContainer = $Panel/Layout/HBox/LadoLocal/Botoes
@onready var label_status: Label = $Panel/Layout/LabelStatus
@onready var btn_confirmar: Button = $Panel/Layout/BtnConfirmar

func _ready() -> void:
	btn_confirmar.pressed.connect(_on_confirmar)
	_criar_botoes()

func _criar_botoes() -> void:
	# Criação dos botões de textura para os itens portugueses
	for item in itens_portugueses:
		var btn = TextureButton.new()
		btn.texture_normal = item["texture"]
		btn.ignore_texture_size = true
		btn.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
		btn.custom_minimum_size = Vector2(64, 64) # Tamanho proporcional à tela de 640x360
		
		# Texto flutuante que aparece ao passar o mouse por cima do item
		btn.tooltip_text = "%s (Valor: %d)" % [item["nome"], item["valor"]]
		
		btn.pressed.connect(_selecionar_portugues.bind(item, btn))
		botoes_portugueses.add_child(btn)

	# Criação dos botões de textura para os itens locais
	for item in itens_locais:
		var btn = TextureButton.new()
		btn.texture_normal = item["texture"]
		btn.ignore_texture_size = true
		btn.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
		btn.custom_minimum_size = Vector2(64, 64)
		
		btn.tooltip_text = "%s (Valor: %d)" % [item["nome"], item["valor"]]
		
		btn.pressed.connect(_selecionar_local.bind(item, btn))
		botoes_locais.add_child(btn)

func _selecionar_portugues(item: Dictionary, btn: TextureButton) -> void:
	selecionado_portugues = item
	# Destaca o botão selecionado aplicando modulação visual
	for b in botoes_portugueses.get_children():
		b.modulate = Color(1, 1, 1)
	btn.modulate = Color(0.5, 1.0, 0.5) # Fica esverdeado ao selecionar
	_atualizar_status()

func _selecionar_local(item: Dictionary, btn: TextureButton) -> void:
	selecionado_local = item
	for b in botoes_locais.get_children():
		b.modulate = Color(1, 1, 1)
	btn.modulate = Color(0.5, 1.0, 0.5)
	_atualizar_status()

func _atualizar_status() -> void:
	if selecionado_portugues.is_empty() or selecionado_local.is_empty():
		label_status.text = "Selecione um item de cada lado"
		return
	var diff = selecionado_portugues["valor"] - selecionado_local["valor"]
	if diff == 0:
		label_status.text = "✓ Troca equilibrada!"
	elif diff > 0:
		label_status.text = "Seu item vale mais. O local ficará feliz!"
	else:
		label_status.text = "Seu item vale menos. Tente outro."

func _on_confirmar() -> void:
	if selecionado_portugues.is_empty() or selecionado_local.is_empty():
		label_status.text = "Selecione um item de cada lado primeiro!"
		return
	var diff = selecionado_portugues["valor"] - selecionado_local["valor"]
	if diff < 0:
		label_status.text = "Troca injusta! Escolha um item de maior valor."
		return
	# Troca aceita
	label_status.text = "Troca realizada! Os locais sorriem."
	btn_confirmar.disabled = true
	await get_tree().create_timer(1.5).timeout
	GameManager.escambo_completo()
	queue_free()
