extends CanvasLayer

@onready var btn_reiniciar: Button = $Control/BtnReiniciar


func _ready() -> void:
	btn_reiniciar.pressed.connect(_on_reiniciar)
	# Garante que o botão funciona mesmo com jogo pausado
	btn_reiniciar.process_mode = Node.PROCESS_MODE_ALWAYS
	hide()


func mostrar() -> void:
	show()
	get_tree().paused = true


func _on_reiniciar() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()
