extends Area2D


func _on_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D and body.name == "CharacterBody2D":
		if body.has_method("take_damage_from_enemy"):
			body.take_damage_from_enemy()
