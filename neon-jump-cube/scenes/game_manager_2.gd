extends Node


func _on_goal_area_body_entered(body: Node2D) -> void:
	GameState.unlock_level(3)
	GameState._Reset_Score()
	get_tree().change_scene_to_file("res://scenes/level_win.tscn")
