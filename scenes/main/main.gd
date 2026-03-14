extends Node

func _ready() -> void:
	# Load Fase 1
	var fase1 := preload("res://scenes/levels/fase1_sagres.tscn").instantiate()
	add_child(fase1)
