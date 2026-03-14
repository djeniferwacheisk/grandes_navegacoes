extends CharacterBody2D

@export var npc_name: String = "NPC"
@export var dialog_id: String = ""
@export var one_shot: bool = false

var _has_talked := false


func _ready() -> void:
	add_to_group("interactable")


func interact() -> void:
	if one_shot and _has_talked:
		return

	_has_talked = true
	var dialog_box := get_tree().get_first_node_in_group("dialog_box")
	if dialog_box and dialog_box.has_method("start_dialog"):
		dialog_box.start_dialog(dialog_id)
