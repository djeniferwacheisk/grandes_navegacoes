extends CanvasLayer

## HUD generico (bussola, minimapa, objetivos). Usado por mais de uma fase
## (ex: Fase 1 e Fase 5) — por isso os objetivos exibidos dependem da
## propriedade "phase", em vez de estarem fixos na Fase 1.

@export var phase: int = 1

@onready var compass: Control = $Compass
@onready var minimap: Control = $Minimap
@onready var objectives: Control = $Objectives
@onready var objective_list: VBoxContainer = $Objectives/Panel/VBoxContainer

var _objective_labels: Dictionary = {}

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

	for key in objectives_data:
		var label := Label.new()
		label.add_theme_font_size_override("font_size", 4)
		var completed: bool = GameManager.is_objective_complete(phase, key)
		label.text = ("[X] " if completed else "[ ] ") + objectives_data[key]
		objective_list.add_child(label)
		_objective_labels[key] = label


func _on_objective_completed(completed_phase: int, objective: String) -> void:
	if completed_phase != phase:
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
