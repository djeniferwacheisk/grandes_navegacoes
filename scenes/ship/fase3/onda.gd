extends Area2D

# ── Configurações ─────────────────────────────────────────────────────────────
@export var velocidade: float = 150.0   # pixels por segundo (da direita para esquerda)
@export var dano: float = 20.0          # dano causado à caravela
@export var tipo: String = "pequena"    # "pequena", "media" ou "grande"

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D


func _ready() -> void:
	# Toca a animação do tipo correto e conecta o sinal de colisão
	sprite.play(tipo)
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)


func _process(delta: float) -> void:
	# Move da direita para a esquerda
	position.x -= velocidade * delta

	# Remove quando sair da tela pela esquerda
	if position.x < -700:
		queue_free()


func _on_body_entered(body: Node) -> void:
	if body.has_method("take_damage"):
		body.take_damage(dano)


func _on_area_entered(area: Area2D) -> void:
	var parent := area.get_parent()
	if parent and parent.has_method("take_damage"):
		parent.take_damage(dano)
