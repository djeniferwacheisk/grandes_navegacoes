extends Area2D

@export var tipo = "fragmento"

func _on_body_entered(body):

	if body.name == "Barco":

		if tipo == "fragmento":
			GameManager.coletar_fragmento()
			mostrar_dialogo()

		queue_free()


func mostrar_dialogo():
	print("Esses símbolos antigos... dizem que os fenícios já navegaram por aqui.")
