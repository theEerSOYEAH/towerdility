extends Node

var endless_mode = false
var health = 100
var smiles = 0


func add_smiles(amount):
	smiles += amount
	print("smiles", smiles)

func spend_smiles(amount):
	if smiles >= amount:
		smiles -= amount
		return true
	return false

func reset():
	smiles = 0
	health = 100

func lose_health(amount):
	health -= amount
	print("base health: ", health)
	
	if health <= 0:
		print("Game over")
