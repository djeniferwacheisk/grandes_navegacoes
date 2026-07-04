extends CharacterBody2D

signal interacted_with(body: Node2D)

enum State { EXPLORING, IN_PUZZLE, IN_DIALOG, IN_SHIP }

const SPEED := 80.0

var state: State = State.EXPLORING
var facing_right := true
var nearby_interactable: Node2D = null

# Escala base do personagem (calibrada para as imagens de caminhar).
# O "idle" (parado) foi desenhado numa proporcao diferente das imagens
# de caminhar, entao precisa de uma escala propria pra nao ficar maior
# que o personagem andando.
const ESCALA_ANDANDO := 0.11624
const ESCALA_PARADO := 0.04822

var _default_sprite_frames: SpriteFrames = null

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var interaction_area: Area2D = $InteractionArea
@onready var interaction_label: Label = $InteractionLabel
@onready var camera: Camera2D = $Camera2D


func _ready() -> void:
	_default_sprite_frames = sprite.sprite_frames
	interaction_label.visible = false
	interaction_area.body_entered.connect(_on_interaction_area_entered)
	interaction_area.body_exited.connect(_on_interaction_area_exited)
	interaction_area.area_entered.connect(_on_interaction_area_area_entered)
	interaction_area.area_exited.connect(_on_interaction_area_area_exited)
	if get_tree().current_scene.name == "Fase2":
		_reset_camera_limits()
	else:
		# Se for Fase 2 ou qualquer outra, deixa a câmera livre para seguir o player
		_setup_camera_limits()


func _setup_camera_limits() -> void:
	# fundo.png: position=(-130,-127), scale=(0.5,0.5), tamanho=2580x1536
	camera.limit_left   = -130
	camera.limit_top    = -127
	camera.limit_right  = -130 + int(2580 * 0.5)  # 1160
	camera.limit_bottom = -127 + int(1536 * 0.5)  # 641

func _reset_camera_limits() -> void:
	 # Remove as travas rígidas da câmera redefinindo para os valores padrão do Godot
	camera.limit_left   = -10000000
	camera.limit_top    = -10000000
	camera.limit_right  = 10000000
	camera.limit_bottom = 10000000

func _physics_process(_delta: float) -> void:
	if state != State.EXPLORING:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	var input_direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = input_direction * SPEED
	move_and_slide()
	_update_animation(input_direction)


func _update_animation(dir: Vector2) -> void:
	if dir == Vector2.ZERO:
		sprite.play("idle")
		_ajustar_escala("idle")
		return

	if abs(dir.x) >= abs(dir.y):
		facing_right = dir.x > 0
		sprite.flip_h = not facing_right
		sprite.play("walk_side")
	elif dir.y > 0:
		sprite.play("walk_down")
	else:
		sprite.play("walk_up")
	_ajustar_escala("walk")


func _ajustar_escala(tipo: String) -> void:
	# So mexe na escala se o sprite_frames atual for o padrao do jogo -
	# se outro sistema (ex: carregar presentes na fase Primeiro Contato)
	# trocou o sprite_frames por um proprio, aquele sistema e quem
	# controla a escala, e a gente nao interfere aqui.
	if sprite.sprite_frames != _default_sprite_frames:
		return
	var escala: float = ESCALA_PARADO if tipo == "idle" else ESCALA_ANDANDO
	sprite.scale = Vector2(escala, escala)


func _unhandled_input(event: InputEvent) -> void:
	if state != State.EXPLORING:
		return
	if event.is_action_pressed("interact") and nearby_interactable:
		interacted_with.emit(nearby_interactable)
		if nearby_interactable.has_method("interact"):
			nearby_interactable.interact()


func set_state(new_state: State) -> void:
	state = new_state
	if state != State.EXPLORING:
		velocity = Vector2.ZERO


func _on_interaction_area_entered(body: Node2D) -> void:
	if body.is_in_group("interactable"):
		nearby_interactable = body
		interaction_label.visible = true


func _on_interaction_area_exited(body: Node2D) -> void:
	if body == nearby_interactable:
		nearby_interactable = null
		interaction_label.visible = false


func _on_interaction_area_area_entered(area: Area2D) -> void:
	if area.is_in_group("interactable"):
		nearby_interactable = area
		interaction_label.visible = true


func _on_interaction_area_area_exited(area: Area2D) -> void:
	if area == nearby_interactable:
		nearby_interactable = null
		interaction_label.visible = false
