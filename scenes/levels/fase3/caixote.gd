extends Area2D

@export var cura: float = 20.0
@export var velocidade_flutuacao: float = 2.0
@export var amplitude_flutuacao: float = 8.0
@export var velocidade_scroll: float = 80.0
@export var velocidade_rotacao: float = 50.0  # graus por segundo

var _tempo: float = 0.0
var _origem_y: float = 0.0

@onready var sprite: Sprite2D = $Sprite2D


func _ready() -> void:
	_origem_y = position.y
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)


func _process(delta: float) -> void:
	_tempo += delta
	# Flutuação suave
	position.y = _origem_y + sin(_tempo * velocidade_flutuacao) * amplitude_flutuacao
	# Rotação
	sprite.rotation_degrees += velocidade_rotacao * delta
	# Move da direita para esquerda
	position.x -= velocidade_scroll * delta
	# Remove quando sair da tela
	if position.x < -100:
		queue_free()


func _on_body_entered(body: Node) -> void:
	if body.has_method("heal"):
		body.heal(cura)
		queue_free()


func _on_area_entered(area: Area2D) -> void:
	var parent := area.get_parent()
	if parent and parent.has_method("heal"):
		parent.heal(cura)
		queue_free()
