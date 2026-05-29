## ResourceCollectable.gd
## Coletável de recurso no mapa (água, comida, moral)
## Conectar signal body_entered do Area2D ao _on_body_entered

class_name ResourceCollectable
extends Area2D

enum TipoRecurso { AGUA, COMIDA, MORAL }

@export var tipo: TipoRecurso = TipoRecurso.AGUA
@export var quantidade: float = 30.0
@export var mensagem: String = ""

# Referência ao ResourceManager da fase
var _resource_manager: Node = null


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	add_to_group("coletavel_recurso")

	# Visual por tipo
	var cores := {
		TipoRecurso.AGUA:   Color(0.2, 0.5, 1.0),
		TipoRecurso.COMIDA: Color(0.8, 0.6, 0.1),
		TipoRecurso.MORAL:  Color(1.0, 0.4, 0.7),
	}
	modulate = cores.get(tipo, Color.WHITE)


func set_resource_manager(rm: Node) -> void:
	_resource_manager = rm


func _on_body_entered(body: Node) -> void:
	if not body.is_in_group("barco") and not body.is_in_group("player"):
		return
	if not _resource_manager:
		return

	match tipo:
		TipoRecurso.AGUA:
			_resource_manager.add_water(quantidade)
		TipoRecurso.COMIDA:
			_resource_manager.add_food(quantidade)
		TipoRecurso.MORAL:
			_resource_manager.add_morale(quantidade)

	if mensagem != "":
		print("[Coletável] ", mensagem)

	queue_free()
