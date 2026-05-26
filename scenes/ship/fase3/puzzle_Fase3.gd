extends Node2D

# ── Sinais ────────────────────────────────────────────────────────────────────
signal puzzle_completo(sucesso: bool)

# ── Referências ───────────────────────────────────────────────────────────────
@onready var instrucao: Label = $Instrucao
@onready var feedback: Label = $Feedback
@onready var dica: Label = $Dica
@onready var rota1: Button = $Rotas/Rota1
@onready var rota2: Button = $Rotas/Rota2
@onready var rota3: Button = $Rotas/Rota3
@onready var rota4: Button = $Rotas/Rota4
@onready var rota5: Button = $Rotas/Rota5

# ── Rotas corretas (1 e 3 são corretas, resto erradas) ───────────────────────
var rotas_corretas: Array = [1, 3]
var tentativas: int = 0

# ── Textos de feedback por rota ───────────────────────────────────────────────
var feedbacks = {
	1: {"correto": true,  "texto": "✓ Excelente! Você seguiu as correntes favoráveis e contornou o Cabo!"},
	2: {"correto": false, "texto": "✗ As correntes te puxaram de volta! As ondas bloquearam a passagem."},
	3: {"correto": true,  "texto": "✓ Boa escolha! Rota arriscada mas válida — você conseguiu passar!"},
	4: {"correto": false, "texto": "✗ Ventos contrários! A caravela não conseguiu avançar por esse caminho."},
	5: {"correto": false, "texto": "✗ Correntes traiçoeiras! O navio foi empurrado para as rochas."},
}


func _ready() -> void:
	rota1.pressed.connect(func(): _escolher_rota(1))
	rota2.pressed.connect(func(): _escolher_rota(2))
	rota3.pressed.connect(func(): _escolher_rota(3))
	rota4.pressed.connect(func(): _escolher_rota(4))
	rota5.pressed.connect(func(): _escolher_rota(5))
	feedback.text = ""
	instrucao.text = "Escolha a rota correta para escapar do Cabo das Tormentas!"
	dica.text = "Observe a direção dos ventos e das correntes antes de escolher!"


func _escolher_rota(numero: int) -> void:
	tentativas += 1
	var info = feedbacks[numero]
	feedback.text = info["texto"]

	if info["correto"]:
		feedback.modulate = Color(0, 1, 0)
		# Desativa todos os botões
		_desativar_rotas()
		await get_tree().create_timer(2.0).timeout
		emit_signal("puzzle_completo", true)
	else:
		feedback.modulate = Color(1, 0, 0)
		# Mostra dica após erro
		dica.text = "Dica: siga sempre o caminho onde o vento sopra a favor e as correntes fluem para o sul!"
		# Destaca a rota errada
		_destacar_rota_errada(numero)


func _desativar_rotas() -> void:
	rota1.disabled = true
	rota2.disabled = true
	rota3.disabled = true
	rota4.disabled = true
	rota5.disabled = true


func _destacar_rota_errada(numero: int) -> void:
	match numero:
		1: rota1.modulate = Color(1, 0, 0)
		2: rota2.modulate = Color(1, 0, 0)
		3: rota3.modulate = Color(1, 0, 0)
		4: rota4.modulate = Color(1, 0, 0)
		5: rota5.modulate = Color(1, 0, 0)
