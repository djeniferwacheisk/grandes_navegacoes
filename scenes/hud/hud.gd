extends CanvasLayer

## HUD generico (bussola, objetivos). Usado por mais de uma fase
## (ex: Fase 1 e Fase 5) — por isso os objetivos exibidos dependem da
## propriedade "phase", em vez de estarem fixos na Fase 1.

@export var phase: int = 1

@onready var compass: Control = $Compass
@onready var objectives: Control = $Objectives
@onready var objective_list: VBoxContainer = $Objectives/Panel/VBoxContainer

var _objective_labels: Dictionary = {}
var _custom_mode: bool = false

## Rotulos exibidos para cada objetivo, por fase. A ordem de cada
## dicionario interno e a ordem em que os itens aparecem na lista.
const OBJECTIVES_BY_PHASE := {
	1: {
		"bussola_ventos": "A Bussola e os Ventos",
		"caravela": "Testando a Caravela",
		"astrolabio": "As Estrelas e o Rumo",
	},
	5: {
		"explorar_costa": "Explorar Costa",
		"primeiro_contato": "Primeiro Contato",
		"puzzle_cruz": "A Cruz e a Posse",
	},
	4: {
		"tripulacao_viva": "Tripulação Viva",
		"mercado_calecute": "Mercado de Calecute",
	},
}


func _ready() -> void:
	GameManager.objective_completed.connect(_on_objective_completed)
	_setup_objectives()
	if compass:
		compass.phase = phase


func _setup_objectives() -> void:
	for child in objective_list.get_children():
		child.queue_free()
	_objective_labels.clear()

	var objectives_data: Dictionary = OBJECTIVES_BY_PHASE.get(phase, {})

	if objectives_data.is_empty():
		var aviso := Label.new()
		aviso.add_theme_font_size_override("font_size", 4)
		aviso.text = "Em andamento..."
		objective_list.add_child(aviso)
		return

	for key in objectives_data:
		var label := Label.new()
		label.add_theme_font_size_override("font_size", 4)
		var completed: bool = GameManager.is_objective_complete(phase, key)
		label.text = ("[X] " if completed else "[ ] ") + objectives_data[key]
		objective_list.add_child(label)
		_objective_labels[key] = label


## Permite que a propria cena (ex: um puzzle com sub-objetivos internos,
## como Explorar Costa) substitua a lista padrao da fase por uma lista
## proprio. "items" e um dicionario { chave: "rotulo exibido" }, na ordem
## desejada. Depois de chamar isso, use update_custom_objective() pra
## marcar itens como concluidos.
func set_custom_objectives(items: Dictionary) -> void:
	_custom_mode = true
	for child in objective_list.get_children():
		child.queue_free()
	_objective_labels.clear()

	for key in items:
		var label := Label.new()
		label.add_theme_font_size_override("font_size", 4)
		label.text = "[ ] " + str(items[key])
		objective_list.add_child(label)
		_objective_labels[key] = label


## Marca um item da lista customizada (definida via set_custom_objectives)
## como concluido, com o mesmo efeito visual de "flash" usado nos
## objetivos normais da fase.
func update_custom_objective(key: String) -> void:
	if not _objective_labels.has(key):
		return
	var label: Label = _objective_labels[key]
	var text: String = label.text
	if text.begins_with("[ ] "):
		label.text = text.replace("[ ] ", "[X] ")
		_flash_objective(label)


func _on_objective_completed(completed_phase: int, objective: String) -> void:
	if _custom_mode or completed_phase != phase:
		return
	if _objective_labels.has(objective):
		var label: Label = _objective_labels[objective]
		var text: String = label.text
		label.text = text.replace("[ ] ", "[X] ")
		_flash_objective(label)


func _flash_objective(label: Label) -> void:
	var tween := create_tween()
	tween.tween_property(label, "modulate", Color.YELLOW, 0.2)
	tween.tween_property(label, "modulate", Color.WHITE, 0.3)
	tween.tween_property(label, "modulate", Color.YELLOW, 0.2)
	tween.tween_property(label, "modulate", Color.WHITE, 0.3)
