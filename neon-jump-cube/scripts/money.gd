extends Area2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _on_body_entered(body: Node2D) -> void:
	GameState.add_point()
	GameState.coins_this_run += 1
	animation_player.play("PickUp Animation")
