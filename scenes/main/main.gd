extends Node

const SCENES := {
	1: "res://scenes/levels/fase1/fase1_sagres.tscn",
	# Fase 2 removida do jogo - redireciona pra fase 3 (protecao para
	# saves antigos que ainda tenham current_phase = 2 salvo).
	2: "res://scenes/levels/fase3/fase3_tormentas.tscn",
	3: "res://scenes/levels/fase3/fase3_tormentas.tscn",
	4: "res://scenes/levels/fase4/Level4_RumoAsIndias.tscn",
	5: "res://scenes/levels/fase5/fase5_brasil.tscn",
}

func _ready() -> void:
	var phase: int = GameManager.current_phase
	var path: String = SCENES.get(phase, SCENES[1])
	add_child(load(path).instantiate())
