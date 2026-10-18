extends Label

func _process(delta: float) -> void:
	text = "SMILES: " + str(GameManager.smiles)
