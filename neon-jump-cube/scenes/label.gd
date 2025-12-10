extends Label

func _process(_delta):
	if Input.is_action_just_pressed('Exit'):
		get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
	self.text = str(GameState.get_score()) + " $"
