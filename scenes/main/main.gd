extends Node

const SCENES := {
	1: "res://scenes/levels/fase1/fase1_sagres.tscn",
	4: "res://scenes/levels/fase4/Level4_RumoAsIndias.tscn",
}

func _ready() -> void:
	var phase: int = GameManager.current_phase
	var path: String = SCENES.get(phase, SCENES[1])
	add_child(load(path).instantiate())
