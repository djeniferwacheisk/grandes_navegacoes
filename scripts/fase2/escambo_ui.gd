extends Control

var valor_portugues = 0
var valor_local = 0


func adicionar_item_portugues(valor):
	valor_portugues += valor


func adicionar_item_local(valor):
	valor_local += valor


func confirmar_troca():

	if valor_portugues >= valor_local:
		troca_sucesso()
	else:
		troca_falha()


func troca_sucesso():

	print("Troca realizada")

	GameManager.escambo_completo()

	visible = false


func troca_falha():
	print("A troca não foi justa")
