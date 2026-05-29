extends Control

@export var peca_id: int = 0
@export var slot_correto: Vector2 = Vector2.ZERO
@export var tolerancia: float = 40.0

var arrastando := false
var posicao_inicial: Vector2
var encaixada := false

func _ready() -> void:
	posicao_inicial = position
	size = Vector2(80, 80)

func _gui_input(event: InputEvent) -> void:
	if encaixada:
		return
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				arrastando = true
			else:
				arrastando = false
				_verificar_encaixe()
	if event is InputEventMouseMotion and arrastando:
		position += event.relative

func _verificar_encaixe() -> void:
	print("posicao da peca: ", position)
	print("slot correto: ", slot_correto)
	print("distancia: ", position.distance_to(slot_correto))
	var dist = position.distance_to(slot_correto)
	if dist <= tolerancia:
		position = slot_correto
		encaixada = true
		modulate = Color(0.5, 1.0, 0.5)
		get_parent().get_parent().peca_encaixada()
	else:
		position = posicao_inicial
