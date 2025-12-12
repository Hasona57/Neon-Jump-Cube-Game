extends CanvasLayer

func _ready() -> void:
	visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS
	print("Pause menu loaded and ready")
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Exit"):
		print("Exit action detected!")
		if get_tree().paused:
			print("Resuming game")
			resume()
		else:
			print("Pausing game")
			pause()
		get_viewport().set_input_as_handled()
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("Exit"):
		print("Exit action detected in unhandled!")
		if get_tree().paused:
			resume()
		else:
			pause()
		get_viewport().set_input_as_handled()
func pause() -> void:
	print("Pause function called")
	get_tree().paused = true
	visible = true
func resume() -> void:
	print("Resume function called")
	get_tree().paused = false
	visible = false

func _on_resume_button_pressed() -> void:
	resume()

func _on_restart_button_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()
	GameState._Reset_Score()


func _on_main_menu_button_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
	GameState._Reset_Score()
