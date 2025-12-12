extends Node2D

var current_level_number: int = 1

func _ready() -> void:
	var previous_scene = get_tree().current_scene.scene_file_path
	if previous_scene:
		var level_name = previous_scene.get_file().get_basename()
		if "level" in level_name:
			var level_str = level_name.replace("Level","")
			current_level_number = int(level_str) if level_str.is_valid_int() else 1
		else:
			current_level_number = 1

func _on_button_2_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")


func _on_button_3_pressed() -> void:
	get_tree().quit()


func _on_button_4_pressed() -> void:
	var next_level = current_level_number + 1
	var next_level_path = "res://scenes/Level" + str(next_level) + ".tscn"
	if ResourceLoader.exists(next_level_path):
		GameState._Reset_Score()
		get_tree().change_scene_to_file(next_level_path) 
	else:
		get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
