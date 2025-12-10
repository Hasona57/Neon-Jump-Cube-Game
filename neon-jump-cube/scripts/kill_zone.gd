extends Area2D

func _on_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D:
		var player = body
		if player.has_method("die"):
			player.die()
		else:
			print("you died")
			get_tree().reload_current_scene()
			GameState._Reset_Score()
