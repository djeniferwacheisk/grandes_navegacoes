## BalanceScale.gd
## Puzzle da balanca de negociacao - Mercado de Calecute - Objetivo 3
extends Control

signal trade_accepted()
signal trade_rejected(reason: String)

@export var margin: float = 2.0
@export var target_value: float = 10.0

var current_offer_value: float = 0.0

@onready var prato_europeu: Control = $Balanca/PratoEuropeu
@onready var prato_especiarias: Control = $Balanca/PratoEspeciarias
@onready var barra_balanca: Control = $Balanca/Barra
@onready var label_valor: Label = $LabelValor
@onready var label_alvo: Label = $LabelAlvo
@onready var btn_confirmar: Button = $BtnConfirmar

const ITENS_EUROPEUS := {
	"Tecidos":     3,
	"Metais":      5,
	"Vidro":       2,
	"Ferramentas": 4,
}

var itens_no_prato: Dictionary = {}


func _ready() -> void:
	btn_confirmar.pressed.connect(_on_confirmar)
	label_alvo.text = "Valor alvo: %.0f" % target_value
	_atualizar_balanca()


func adicionar_item(nome: String) -> void:
	if not ITENS_EUROPEUS.has(nome):
		return
	itens_no_prato[nome] = itens_no_prato.get(nome, 0) + 1
	current_offer_value += ITENS_EUROPEUS[nome]
	_atualizar_balanca()


func remover_item(nome: String) -> void:
	if not itens_no_prato.has(nome) or itens_no_prato[nome] <= 0:
		return
	itens_no_prato[nome] -= 1
	if itens_no_prato[nome] == 0:
		itens_no_prato.erase(nome)
	current_offer_value -= ITENS_EUROPEUS[nome]
	current_offer_value = max(0.0, current_offer_value)
	_atualizar_balanca()


func limpar_prato() -> void:
	itens_no_prato.clear()
	current_offer_value = 0.0
	_atualizar_balanca()


func _atualizar_balanca() -> void:
	label_valor.text = "Sua oferta: %.0f" % current_offer_value
	var diferenca := current_offer_value - target_value
	var angulo := clamp(diferenca * 3.0, -30.0, 30.0)
	if barra_balanca:
		barra_balanca.rotation_degrees = angulo
	var diff_abs := abs(diferenca)
	if diff_abs <= margin:
		label_valor.modulate = Color.GREEN
	elif diff_abs <= margin * 2.5:
		label_valor.modulate = Color.YELLOW
	else:
		label_valor.modulate = Color.RED


func _on_confirmar() -> void:
	if current_offer_value <= 0:
		trade_rejected.emit("Adicione itens a balanca primeiro.")
		return
	if current_offer_value < target_value - margin:
		trade_rejected.emit("Essa oferta nao honra o valor das especiarias.")
	elif current_offer_value > target_value + margin:
		trade_rejected.emit("Cuidado, estamos entregando mais do que podemos.")
	else:
		trade_accepted.emit()
