extends CanvasLayer

@onready var compass: Control = $Compass
@onready var minimap: Control = $Minimap
@onready var objectives: Control = $Objectives
@onready var objective_list: VBoxContainer = $Objectives/Panel/VBoxContainer

var _objective_labels: Dictionary = {}


func _ready() -> void:
	GameManager.objective_completed.connect(_on_objective_completed)
	_setup_objectives()


func _setup_objectives() -> void:
	for child in objective_list.get_children():
		child.queue_free()

	var objectives_data := {
		"bussola_ventos": "A Bussola e os Ventos",
		"caravela": "Testando a Caravela",
		"astrolabio": "As Estrelas e o Rumo",
	}

	for key in objectives_data:
		var label := Label.new()
		label.add_theme_font_size_override("font_size", 4)
		var completed: bool = GameManager.is_objective_complete(1, key)
		label.text = ("[X] " if completed else "[ ] ") + objectives_data[key]
		objective_list.add_child(label)
		_objective_labels[key] = label


func _on_objective_completed(phase: int, objective: String) -> void:
	if phase != 1:
		return
	if _objective_labels.has(objective):
		var label: Label = _objective_labels[objective]
		var text: String = label.text
		label.text = text.replace("[ ] ", "[X] ")
		_flash_objective(label)


func _flash_objective(label: Label) -> void:
	var tween := create_tween()
	tween.tween_property(label, "modulate", Color.YELLOW, 0.2)
	tween.tween_property(label, "modulate", Color.WHITE, 0.3)
	tween.tween_property(label, "modulate", Color.YELLOW, 0.2)
	tween.tween_property(label, "modulate", Color.WHITE, 0.3)
