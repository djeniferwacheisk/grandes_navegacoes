## ─── Obstacle.gd ────────────────────────────────────────────────────────────
## Anexe em cada cena de obstáculo (onda, corrente, etc.)
extends Area2D

@export var damage: int = 1
@export var speed: float = 300.0   # velocidade de scroll (px/s, deve casar com o cenário)
@export var warning_time: float = 1.0  # segundos de aviso antes de chegar na tela

@onready var warning_sprite: Sprite2D = $WarningSprite  # seta/exclamação de aviso (opcional)

var _warned: bool = false


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)


func _process(delta: float) -> void:
	position.x -= speed * delta
	if position.x < -200:
		queue_free()


func _on_body_entered(body: Node) -> void:
	if body.has_method("take_damage"):
		body.take_damage(damage)


func _on_area_entered(area: Area2D) -> void:
	# Suporte para HurtBox como Area2D
	var parent := area.get_parent()
	if parent and parent.has_method("take_damage"):
		parent.take_damage(damage)


## ─── ObstacleSpawner.gd ──────────────────────────────────────────────────────
## Anexe em um Node2D dentro da cena do Objetivo 1.
class_name ObstacleSpawner
extends Node2D

@export var obstacle_scenes: Array[PackedScene]  # arraste as cenas de obstáculo
@export var lane_y_positions: Array[float] = [180.0, 320.0, 460.0]
@export var spawn_x: float = 900.0              # fora da tela à direita
@export var min_interval: float = 1.2
@export var max_interval: float = 3.0
@export var difficulty_ramp: float = 0.02       # reduz o intervalo por segundo de jogo

var _timer: float = 0.0
var _next_interval: float = 2.0
var _elapsed: float = 0.0
var _active: bool = false


func start() -> void:
	_active = true
	_schedule_next()


func stop() -> void:
	_active = false


func _process(delta: float) -> void:
	if not _active:
		return
	_elapsed += delta
	_timer += delta
	if _timer >= _next_interval:
		_spawn()
		_schedule_next()
		_timer = 0.0


func _spawn() -> void:
	if obstacle_scenes.is_empty():
		return
	var scene: PackedScene = obstacle_scenes[randi() % obstacle_scenes.size()]
	var obstacle: Node2D = scene.instantiate()
	var lane: int = randi() % lane_y_positions.size()
	obstacle.position = Vector2(spawn_x, lane_y_positions[lane])
	get_parent().add_child(obstacle)


func _schedule_next() -> void:
	var reduced := max_interval - _elapsed * difficulty_ramp
	_next_interval = randf_range(min_interval, max(min_interval + 0.2, reduced))


## ─── Collectible.gd ──────────────────────────────────────────────────────────
## Anexe nos caixotes de reparo flutuantes.
class_name Collectible
extends Area2D

enum Type { REPAIR_CRATE, ROPE }

@export var type: Type = Type.REPAIR_CRATE
@export var heal_amount: int = 1
@export var float_amplitude: float = 8.0
@export var float_speed: float = 2.0
@export var blink_start_time: float = 2.5   # começa a piscar N segundos antes de sumir
@export var lifetime: float = 5.0           # tempo de vida total

signal collected(collectible_type: int)

var _time: float = 0.0
var _origin_y: float = 0.0
var _blink_timer: float = 0.0
var _blink_visible: bool = true

@onready var sprite: Sprite2D = $Sprite2D


func _ready() -> void:
	_origin_y = position.y
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)


func _process(delta: float) -> void:
	_time += delta

	# Flutua suavemente
	position.y = _origin_y + sin(_time * float_speed) * float_amplitude

	# Pisca ao perto do fim
	var remaining := lifetime - _time
	if remaining <= blink_start_time:
		_blink_timer += delta
		if _blink_timer >= 0.12:
			_blink_visible = not _blink_visible
			sprite.visible = _blink_visible
			_blink_timer = 0.0

	if _time >= lifetime:
		queue_free()


func _on_body_entered(body: Node) -> void:
	_collect(body)


func _on_area_entered(area: Area2D) -> void:
	_collect(area.get_parent())


func _collect(target: Node) -> void:
	if not target.has_method("heal"):
		return
	if type == Type.REPAIR_CRATE:
		target.heal(heal_amount)
	emit_signal("collected", type)
	# Partícula de coleta pode ser instanciada aqui se desejar
	queue_free()
