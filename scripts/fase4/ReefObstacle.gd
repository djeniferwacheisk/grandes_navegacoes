## ReefObstacle.gd
## Recife com colisão — causa dano ao navio na Fase 4 Objetivo 2

class_name ReefObstacle
extends StaticBody2D

@export var damage_amount: float = 25.0


func _ready() -> void:
	add_to_group("recife")
