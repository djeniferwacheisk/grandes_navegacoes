extends CanvasLayer

@onready var btn_continuar: Button = $Control/BtnContinuar


func _ready() -> void:
	btn_continuar.pressed.connect(_on_continuar)
	btn_continuar.process_mode = Node.PROCESS_MODE_ALWAYS
	hide()


func mostrar() -> void:
	show()
	get_tree().paused = true


func _on_continuar() -> void:
	get_tree().paused = false
	# Por enquanto volta ao menu principal
	get_tree().change_scene_to_file("res://scenes/main/main.tscn")
