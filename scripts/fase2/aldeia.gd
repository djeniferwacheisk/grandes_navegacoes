extends Area2D

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if not body is CharacterBody2D:
		return
	var escambo = get_tree().get_first_node_in_group("escambo")
	if escambo:
		escambo.visible = true
