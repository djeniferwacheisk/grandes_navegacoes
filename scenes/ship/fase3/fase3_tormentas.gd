extends Node2D

@onready var carvela = $Carvela
@onready var barra_vida: TextureProgressBar = $HUD/BarraVida
@onready var spawn_timer: Timer = $swapnTimer

var onda_cena = preload("res://scenes/ship/fase3/onda.tscn")
var faixas: Array[float] = [60, 120.0, 180.0]
var caixote_cena = preload("res://scenes/ship/fase3/caixote.tscn")
var _timer_caixote: float = 0.0
var intervalo_caixote: float = 8.0


func _ready() -> void:
	carvela.health_changed.connect(_on_health_changed)
	barra_vida.max_value = carvela.max_health
	barra_vida.value = carvela.health
	spawn_timer.timeout.connect(_spawnar_onda)

func _process(delta: float) -> void:
	_timer_caixote += delta
	
	if _timer_caixote >= intervalo_caixote:
		_timer_caixote = 0.0
		_spawnar_caixote()

func _spawnar_caixote() -> void:
	var caixote = caixote_cena.instantiate()
	caixote.position = Vector2(800, faixas[randi() % faixas.size()])
	add_child(caixote)

func _spawnar_onda() -> void:
	print("Spawnando onda!")
	var onda = onda_cena.instantiate()
	var faixa = faixas[randi() % faixas.size()]
	onda.position = Vector2(800, faixa)
	var tipos = ["pequena", "media", "grande"]
	onda.tipo = tipos[randi() % tipos.size()]
	add_child(onda)


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
