extends Node2D

@onready var progresso_label: Label = $HUD/Progresso

func _ready() -> void:
	GameManager.fragmento_coletado.connect(_on_fragmento_coletado)
	GameManager.todos_fragmentos_coletados.connect(_on_fase_completa)

func _on_fragmento_coletado(id: String, nome: String) -> void:
	var total = GameManager.fragmentos_coletados
	progresso_label.text = "Pontos: %d/3" % total

func _on_fase_completa() -> void:
	progresso_label.text = "Pontos: 3/3 
Completo!"
