extends Node
class_name uiAnimationComponent 

@export var animate_from_center: bool = true
@export var animate_scale: Vector2 = Vector2(1.1, 1.1) # Aumenta 10% no hover
@export var animation_duration : float = 0.1
@export var transition_type : Tween.TransitionType = Tween.TRANS_SINE
@export var button_sound : AudioStream
@export var audio_player := AudioStreamPlayer.new()

var target : Control 
var default_scale : Vector2

func _ready() -> void:
	target = get_parent()
	# Aguarda o frame para garantir que o tamanho do botão foi calculado
	call_deferred("setup")

func setup() -> void:
	if not target is Control: return
	
	target.mouse_entered.connect(_on_mouse_over)
	target.mouse_exited.connect(_on_mouse_out)
	
	if animate_from_center:
		target.pivot_offset = target.size / 2 
		default_scale = target.scale 
		
	if button_sound:
		audio_player.stream = button_sound
		add_child(audio_player)

func _on_mouse_over() -> void:
	init_tween("scale", animate_scale, animation_duration)
	if button_sound: audio_player.play()
	
func _on_mouse_out() -> void:
	init_tween("scale", default_scale, animation_duration)

func init_tween(property: String, value, duration: float) -> void:
	var tween = get_tree().create_tween()
	tween.tween_property(target, property, value, duration).set_trans(transition_type)
		
func cleanup() -> void:
	if target:
		# Desconecta os sinais usando a referência da função (mais seguro)
		if target.mouse_entered.is_connected(_on_mouse_over):
			target.mouse_entered.disconnect(_on_mouse_over)
		if target.mouse_exited.is_connected(_on_mouse_out):
			target.mouse_exited.disconnect(_on_mouse_out)
