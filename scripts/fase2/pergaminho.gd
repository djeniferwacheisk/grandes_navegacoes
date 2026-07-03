extends Area2D

var player_por_perto := false

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	add_to_group("interactable")

func _process(_delta: float) -> void:
	if not player_por_perto:
		return
	if Input.is_action_just_pressed("interact"):
		_abrir_puzzle()

func _on_body_entered(body: Node2D) -> void:
	print("entrou no pergaminho: ", body.name, " é player? ", body.is_in_group("player"))
	if body.is_in_group("player"):
		player_por_perto = true

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_por_perto = false

func _abrir_puzzle() -> void:
	print("tentando abrir puzzle, fragmentos: ", GameManager.fragmentos_coletados)
	if GameManager.fragmentos_coletados < 3:
		print("Colete os 3 fragmentos primeiro!")
		return
	var puzzle_scene = preload("res://scenes/levels/fase2/puzzle_mapa.tscn")
	var puzzle = puzzle_scene.instantiate()
	get_tree().root.add_child(puzzle)
