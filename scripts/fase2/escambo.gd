extends CanvasLayer

# Itens portugueses e seus valores
var itens_portugueses = [
	{"nome": "Pente", "valor": 2},
	{"nome": "Tecido", "valor": 3},
	{"nome": "Espelho", "valor": 4},
]

# Itens locais e seus valores
var itens_locais = [
	{"nome": "Amuleto", "valor": 2},
	{"nome": "Cerâmica", "valor": 3},
	{"nome": "Especiaria", "valor": 4},
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
	for item in itens_portugueses:
		var btn = Button.new()
		btn.text = "%s (valor: %d)" % [item["nome"], item["valor"]]
		btn.pressed.connect(_selecionar_portugues.bind(item, btn))
		botoes_portugueses.add_child(btn)

	for item in itens_locais:
		var btn = Button.new()
		btn.text = "%s (valor: %d)" % [item["nome"], item["valor"]]
		btn.pressed.connect(_selecionar_local.bind(item, btn))
		botoes_locais.add_child(btn)

func _selecionar_portugues(item: Dictionary, btn: Button) -> void:
	selecionado_portugues = item
	# Destaca o botão selecionado
	for b in botoes_portugueses.get_children():
		b.modulate = Color(1, 1, 1)
	btn.modulate = Color(0.5, 1.0, 0.5)
	_atualizar_status()

func _selecionar_local(item: Dictionary, btn: Button) -> void:
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
