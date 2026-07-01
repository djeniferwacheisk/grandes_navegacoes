extends Area2D

signal triggered

func _ready() -> void:
	add_to_group("interactable")

func interact() -> void:
	triggered.emit()
