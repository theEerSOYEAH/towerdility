extends Node

var smiles = 0

func add_smiles(amount):
	smiles += amount
	print("smiles", smiles)
	var label = get_tree().current_scene.get_node_or_null("smilecounter")
	if label :
		label.text = str("smiles = ",smiles)

func extract_smiles(amount):
	smiles -= amount
	var label = get_tree().current_scene.get_node_or_null("smilecounter")
	if label :
		label.text = str("smiles = ", smiles)
