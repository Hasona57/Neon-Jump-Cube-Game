extends Node

func _ready() -> void:
	var level_name = get_tree().current_scene.scene_file_path.get_file().get_basename()
	GameState.start_level(level_name)
	
	var pause_menu_scene = load("res://scenes/pause_menu.tscn")
	if pause_menu_scene:
		var pause_menu = pause_menu_scene.instantiate()
		get_tree().current_scene.add_child(pause_menu)
func _on_goal_area_body_entered(body: Node2D) -> void:
	GameState.finish_level()
	GameState.unlock_level(2)
	GameState._Reset_Score()
	get_tree().change_scene_to_file("res://scenes/level_win.tscn")
