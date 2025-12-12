extends Camera2D

var target:Node2D = null
var look_ahead_x:float = 0.0
var smoothing: float = 0.1

func _ready() -> void:
	target = get_parent()
	
func _process(delta: float) -> void:
	if not target:
		return
	
	var direction = 0.0
	if target is CharacterBody2D:
		var vel = target.velocity
		if abs(vel.x) > 10.0:
			direction = 1.0 if vel.x > 0.0 else -1.0
	var target_look_ahead = direction * 80.0
	look_ahead_x = lerp(look_ahead_x, target_look_ahead, delta * 5.0)
	
	var desired_pos = target.global_position + Vector2(look_ahead_x, 0)
	global_position = global_position.lerp(desired_pos, smoothing)
	
	var target_y = target.global_position.y + 50.0
	if global_position.y > target_y:
		global_position.y = target_y
