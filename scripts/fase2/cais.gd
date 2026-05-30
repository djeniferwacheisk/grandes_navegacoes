extends Area2D

@onready var label: Label = $Label

var barco_por_perto := false
var player_por_perto := false

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	label.visible = false

func _process(_delta: float) -> void:
	print("barco_por_perto: ", barco_por_perto)
	if Input.is_action_just_pressed("interact"):
		print("E pressionado no cais")
		if barco_por_perto:
			_desembarcar()
		elif player_por_perto:
			_embarcar()

func _on_body_entered(body: Node2D) -> void:
	print("entrou no cais: ", body.name, " é player? ", body.is_in_group("player"))
	if body.is_in_group("ship"):
		barco_por_perto = true
		label.text = "[E] Desembarcar"
		label.visible = true
	elif body.is_in_group("player") and not body.is_in_group("ship"):
		player_por_perto = true
		label.text = "[E] Embarcar"
		label.visible = true

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("ship"):
		barco_por_perto = false
		label.visible = false
	elif body.is_in_group("player"):
		player_por_perto = false
		label.visible = false

func _desembarcar() -> void:
	var ship = get_tree().get_first_node_in_group("ship")
	var player = get_tree().get_first_node_in_group("player")
	if ship and player:
		ship.anchor_down = true
		player.global_position = $SpawnPoint.global_position
		player.visible = true
		barco_por_perto = false
		label.visible = false
		ship.get_node("Camera2D").enabled = false
		player.get_node("Camera2D").enabled = true

func _embarcar() -> void:
	var ship = get_tree().get_first_node_in_group("ship")
	var player = get_tree().get_first_node_in_group("player")
	if ship and player:
		player.visible = false
		ship.anchor_down = false
		player.get_node("Camera2D").enabled = false
		ship.get_node("Camera2D").enabled = true
