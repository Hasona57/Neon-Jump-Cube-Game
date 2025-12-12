extends Label

func _process(_delta):
	self.text = str(GameState.get_score()) + " $"
