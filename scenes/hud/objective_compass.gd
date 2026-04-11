extends Control

@onready var needle_pivot: Control = $NeedlePivot
@onready var objective_label: Label = $ObjectiveLabel

var player: Node2D
var current_objective: String = ""
var _all_complete := false

const OBJECTIVE_POSITIONS := {
	"bussola_ventos": Vector2(262, 438),
	"caravela": Vector2(955, 85),
	"astrolabio": Vector2(214, -47),
}

const OBJECTIVE_NAMES := {
	"bussola_ventos": "Bússola",
	"caravela": "Caravela",
	"astrolabio": "Astrolábio",
}

const OBJECTIVE_ORDER := ["bussola_ventos", "caravela", "astrolabio"]


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

	var target: Vector2 = OBJECTIVE_POSITIONS[current_objective]

	var direction := target - player.global_position
	var angle := direction.angle()
	needle_pivot.rotation = angle + PI / 2.0


func _update_current_objective() -> void:
	current_objective = ""
	for obj in OBJECTIVE_ORDER:
		if not GameManager.is_objective_complete(1, obj):
			current_objective = obj
			break

	if current_objective == "":
		_all_complete = true
		objective_label.text = "Completo!"
		if needle_pivot:
			needle_pivot.visible = false
	else:
		objective_label.text = OBJECTIVE_NAMES[current_objective]


func _on_objective_completed(_phase: int, _objective: String) -> void:
	_update_current_objective()
