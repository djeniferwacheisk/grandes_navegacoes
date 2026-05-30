extends Area2D

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if not body is CharacterBody2D:
		return
	GameManager.coletar_fragmento("vegetation", "Vegetação Tropical")
	queue_free()
