extends Control

## Bussola que aponta para o proximo objetivo. Compartilhada entre fases
## (ex: Fase 1 e Fase 5) — por isso as posicoes/nomes dos objetivos e a
## fase verificada dependem da propriedade "phase", em vez de estarem
## fixas na Fase 1.

@export var phase: int = 1:
	set(value):
		phase = value
		if is_inside_tree():
			_update_current_objective()

@onready var needle_pivot: Control = $NeedlePivot
@onready var objective_label: Label = $ObjectiveLabel

var player: Node2D
var current_objective: String = ""
var _all_complete := false

## Posicao (no mundo da fase), nome exibido e ordem dos objetivos, por fase.
const OBJECTIVES_BY_PHASE := {
	1: {
		"order": ["bussola_ventos", "caravela", "astrolabio"],
		"positions": {
			"bussola_ventos": Vector2(262, 438),
			"caravela": Vector2(955, 85),
			"astrolabio": Vector2(214, -47),
		},
		"names": {
			"bussola_ventos": "Bússola",
			"caravela": "Caravela",
			"astrolabio": "Astrolábio",
		},
	},
	5: {
		"order": ["explorar_costa", "primeiro_contato", "puzzle_cruz"],
		"positions": {
			"explorar_costa": Vector2(200, 460),
			"primeiro_contato": Vector2(550, 460),
			"puzzle_cruz": Vector2(900, 460),
		},
		"names": {
			"explorar_costa": "Explorar Costa",
			"primeiro_contato": "Primeiro Contato",
			"puzzle_cruz": "A Cruz e a Posse",
		},
	},
}


func _ready() -> void:
	GameManager.objective_completed.connect(_on_objective_completed)
	_update_current_objective()
	_find_player.call_deferred()


func _find_player() -> void:
	var players := get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		player = players[0]
		return

	var scene := get_tree().current_scene
	if scene:
		player = scene.get_node_or_null("Player")

	if not player and scene:
		player = _find_character_body(scene)


func _find_character_body(node: Node) -> Node2D:
	if node is CharacterBody2D and node.name == "Player":
		return node
	for child in node.get_children():
		var found := _find_character_body(child)
		if found:
			return found
	return null


func _process(_delta: float) -> void:
	if not player and is_inside_tree():
		_find_player()

	if _all_complete or not player or current_objective == "":
		return

	var positions: Dictionary = OBJECTIVES_BY_PHASE.get(phase, {}).get("positions", {})
	if not positions.has(current_objective):
		return
	var target: Vector2 = positions[current_objective]

	var direction := target - player.global_position
	var angle := direction.angle()
	needle_pivot.rotation = angle + PI / 2.0


func _update_current_objective() -> void:
	var phase_data: Dictionary = OBJECTIVES_BY_PHASE.get(phase, {})
	var order: Array = phase_data.get("order", [])
	var names: Dictionary = phase_data.get("names", {})

	current_objective = ""
	_all_complete = false
	for obj in order:
		if not GameManager.is_objective_complete(phase, obj):
			current_objective = obj
			break

	if not is_inside_tree() or not objective_label:
		return

	if current_objective == "":
		_all_complete = true
		objective_label.text = "Completo!"
		if needle_pivot:
			needle_pivot.visible = false
	else:
		objective_label.text = names.get(current_objective, "")
		if needle_pivot:
			needle_pivot.visible = true


func _on_objective_completed(completed_phase: int, _objective: String) -> void:
	if completed_phase != phase:
		return
	_update_current_objective()
