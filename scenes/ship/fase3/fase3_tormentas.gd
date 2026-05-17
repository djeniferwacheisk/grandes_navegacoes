extends Node2D

@onready var carvela = $Carvela
@onready var barra_vida = $HUD/BarraVida


func _ready() -> void:
	# Conecta o sinal da caravela à barra de vida
	carvela.health_changed.connect(_on_health_changed)
	# Inicia a barra com vida cheia
	barra_vida.max_value = carvela.max_health
	barra_vida.value = carvela.health


func _on_health_changed(current: float, maximum: float) -> void:
	barra_vida.value = current
	# Muda a cor conforme a vida
	if current / maximum <= 0.3:
		barra_vida.modulate = Color(1, 0, 0)  # vermelho
	elif current / maximum <= 0.6:
		barra_vida.modulate = Color(1, 0.6, 0)  # laranja
	else:
		barra_vida.modulate = Color(1, 1, 1)  # normal
