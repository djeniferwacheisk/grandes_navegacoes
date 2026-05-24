extends Node2D

@onready var carvela = $Carvela
@onready var barra_vida: TextureProgressBar = $HUD/BarraVida
@onready var spawn_timer: Timer = $swapnTimer
@onready var game_over = $GameOver
@onready var vitoria = $Vitoria
@onready var barra_progresso: TextureProgressBar = $HUD/BarraProgresso
@onready var mini_navio = $HUD/MiniNavio

var onda_cena = preload("res://scenes/ship/fase3/onda.tscn")
var caixote_cena = preload("res://scenes/ship/fase3/caixote.tscn")
var faixas: Array[float] = [60.0, 120.0, 180.0]
var _timer_caixote: float = 0.0
var intervalo_caixote: float = 8.0
var tempo_fase: float = 0.0
var duracao_fase: float = 10.0
var fase_completa: bool = false


func _ready() -> void:
	spawn_timer.timeout.connect(_spawnar_onda)
	carvela.health_changed.connect(_on_health_changed)
	carvela.ship_destroyed.connect(_on_ship_destroyed)
	barra_vida.max_value = carvela.max_health
	barra_vida.value = carvela.health
	barra_progresso.max_value = duracao_fase
	barra_progresso.value = 0


func _process(delta: float) -> void:
	if fase_completa:
		return

	# Caixote
	_timer_caixote += delta
	if _timer_caixote >= intervalo_caixote:
		_timer_caixote = 0.0
		_spawnar_caixote()

	# Progresso da fase
	tempo_fase += delta
	barra_progresso.value = tempo_fase

	var progresso = tempo_fase / duracao_fase
	var largura_barra = barra_progresso.size.x
	mini_navio.position.x = barra_progresso.position.x + (progresso * largura_barra)
	mini_navio.position.y = barra_progresso.position.y

	if progresso > 0.75:
		spawn_timer.wait_time = 1.0
	elif progresso > 0.5:
		spawn_timer.wait_time = 1.5
	elif progresso > 0.25:
		spawn_timer.wait_time = 2.0

	if tempo_fase >= duracao_fase:
		fase_completa = true
		spawn_timer.stop()
		vitoria.mostrar()


func _spawnar_onda() -> void:
	var onda = onda_cena.instantiate()
	onda.position = Vector2(800, faixas[randi() % faixas.size()])
	add_child(onda)


func _spawnar_caixote() -> void:
	var caixote = caixote_cena.instantiate()
	caixote.position = Vector2(800, faixas[randi() % faixas.size()])
	add_child(caixote)


func _on_health_changed(current: float, maximum: float) -> void:
	barra_vida.value = current
	var ratio := current / maximum
	if ratio > 0.75:
		barra_vida.modulate = Color(1, 1, 1)
	elif ratio > 0.5:
		barra_vida.modulate = Color(1, 1, 0)
	elif ratio > 0.25:
		barra_vida.modulate = Color(1, 0.5, 0)
	else:
		barra_vida.modulate = Color(1, 0, 0)


func _on_ship_destroyed() -> void:
	fase_completa = true
	spawn_timer.stop()
	game_over.mostrar()
