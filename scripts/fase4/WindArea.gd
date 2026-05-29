## WindArea.gd
## Zona de vento na área dos ventos do Índico — Objetivo 2
## Aplica força ao navio ao entrar na área

class_name WindArea
extends Area2D

@export var direction: Vector2 = Vector2.RIGHT
@export var force: float = 80.0
@export var is_favorable: bool = true

var _ships_inside: Array[Node] = []


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	add_to_group("wind_area_fase4")

	# Cor visual: verde = favorável, laranja = perigoso
	modulate = Color(0.3, 1.0, 0.3, 0.3) if is_favorable else Color(1.0, 0.5, 0.1, 0.3)


func _physics_process(delta: float) -> void:
	for ship in _ships_inside:
		if is_instance_valid(ship) and ship.has_method("apply_external_force"):
			ship.apply_external_force(direction.normalized() * force * delta)


func _on_body_entered(body: Node) -> void:
	if body.is_in_group("barco"):
		_ships_inside.append(body)
		var msg := "Vento favorável!" if is_favorable else "Cuidado! O vento empurra o navio para os recifes."
		print("[VentoIndico] ", msg)


func _on_body_exited(body: Node) -> void:
	_ships_inside.erase(body)
