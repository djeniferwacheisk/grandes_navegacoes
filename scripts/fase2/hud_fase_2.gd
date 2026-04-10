extends Control

func atualizar_objetivo(numero):

	if numero == 1:
		$Label.text = "Explore a costa e encontre fragmentos"

	if numero == 2:
		$Label.text = "Realize o escambo"

	if numero == 3:
		$Label.text = "Reconstrua o mapa"
