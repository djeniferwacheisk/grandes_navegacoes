extends CanvasLayer

var pecas_no_lugar: int = 0
var total_pecas: int = 3

@onready var label_status: Label = $Panel/LabelStatus

func _ready() -> void:
	pass

func peca_encaixada() -> void:
	pecas_no_lugar += 1
	label_status.text = "Peças: %d/%d" % [pecas_no_lugar, total_pecas]
	if pecas_no_lugar >= total_pecas:
		await get_tree().create_timer(1.0).timeout
		_puzzle_completo()

func _puzzle_completo() -> void:
	GameManager.puzzle_completo()
	print("Puzzle do mapa concluído!")
	queue_free()
