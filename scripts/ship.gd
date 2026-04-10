extends CharacterBody2D

@export var max_speed: float = 400.0

# ANCORA
var anchor_down: bool = false

# VIDA
@export var max_health: float = 100
var health: float = 100

# MOTOR
@export var motor_acceleration: float = 40.0
@export var motor_max_speed: float = 120.0
@export var friction: float = 60.0
@export var brake_force: float = 120.0

# VENTO
@export var wind_strength: float = 400.0
var wind_zone_multiplier: float = 1.0

# ROTAÇÃO
@export var rotation_speed: float = 1.5

# ONDAS
@export var wave_intensity: float = 2.0
@export var wave_speed: float = 2.0

var default_wave_intensity
var default_wave_speed

# VELAS
@export var sail_power: float = 1.0
@export var sail_adjust_speed: float = 0.5

var wave_time: float = 0.0

var motor_speed: float = 0.0
var current_speed: float = 0.0

@export var health_bar_path: NodePath
@onready var health_bar = get_node(health_bar_path)


func _ready():

	default_wave_intensity = wave_intensity
	default_wave_speed = wave_speed
	
	#health_bar.max_value = max_health
	#health_bar.value = health


func _physics_process(delta):

	# ANCORA
	if Input.is_action_just_pressed("toggle_anchor"):
		anchor_down = !anchor_down
		

	# VELAS
	if Input.is_action_pressed("raise_sail"):
		sail_power += sail_adjust_speed * delta

	if Input.is_action_pressed("lower_sail"):
		sail_power -= sail_adjust_speed * delta

	sail_power = clamp(sail_power,0.0,1.0)
	
	if sail_power < 0.3: 
		if $AnimatedSprite2D.animation != "closed": 
			$AnimatedSprite2D.play("closed") 
	else: 
		if $AnimatedSprite2D.animation != "open": 
			$AnimatedSprite2D.play("open")

	# MOTOR
	if Input.is_action_pressed("move_forward"):
		motor_speed += motor_acceleration * delta
	elif Input.is_action_pressed("move_backward"):
		motor_speed -= brake_force * delta
	else:
		motor_speed -= friction * delta

	motor_speed = clamp(motor_speed,0,motor_max_speed)

	# VENTO GLOBAL
	var wind_vector = GlobalWind.get_wind_vector() 

	var wind_effect = wind_vector.dot(transform.y)

	var wind_force = wind_effect * sail_power * wind_strength * wind_zone_multiplier

	# VELOCIDADE FINAL
	current_speed = motor_speed + wind_force * delta
	#print("Velocidade: ",current_speed)

	if anchor_down:
		current_speed = 0
		motor_speed = 0
		$AnimatedSprite2D.play("toggle")
	else:
		current_speed = clamp(current_speed,0,max_speed)

	# ROTAÇÃO
	if not anchor_down and current_speed > 10:

		if Input.is_action_pressed("turn_left"):
			rotation -= rotation_speed * delta

		if Input.is_action_pressed("turn_right"):
			rotation += rotation_speed * delta

	# MOVIMENTO
	var forward = transform.y * current_speed
	velocity = forward

	# ONDAS
	wave_time += delta
	rotation += sin(wave_time * wave_speed) * deg_to_rad(wave_intensity) * delta

	var previous_velocity = velocity

	move_and_slide()

	var collision = get_last_slide_collision()
	
	if collision:

		var impact_speed = previous_velocity.length()
		
		if impact_speed > 150:

			var damage = impact_speed * 0.1
			take_damage(damage)

func take_damage(amount):

	health -= amount
	health = clamp(health, 0, max_health)

	health_bar.value = health

	print("Vida:", health)
	
	if health < max_health * 0.3:
		health_bar.modulate = Color(1,0,0)
	else:
		health_bar.modulate = Color(1,1,1)

	if health <= 0:
		die()
		
func die():

	print("Barco destruído!")

	queue_free()

func _on_wind_detector_area_entered(area):

	if area is WindZone:
		print("Entrou na zona de vento")
		wind_zone_multiplier = area.wind_multiplier


func _on_wind_detector_area_exited(area):
	print("Saiu da zona de vento")
	if area is WindZone:
		wind_zone_multiplier = 1.0


func _on_wave_detector_area_entered(area):
	print("Entrou na zona de onda")
	if area is WaveZone:
		wave_intensity = area.wave_intensity
		wave_speed = area.wave_speed


func _on_wave_detector_area_exited(area):
	print("Saiu da zona de onda")
	if area is WaveZone:
		wave_intensity = default_wave_intensity
		wave_speed = default_wave_speed
