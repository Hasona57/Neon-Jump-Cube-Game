extends CharacterBody2D

@export var point_a: Vector2 = Vector2(0, 0)
@export var point_b: Vector2 = Vector2(200, 0)
@export var speed: float = 50.0

var target_point: Vector2
var current_point: int = 0

func _ready() -> void:
	global_position = point_a
	target_point = point_b
func _physics_process(delta: float) -> void:
	var direction = (target_point - global_position).normalized()
	var distance = global_position.distance_to(target_point)
	if distance < 5.0:
		current_point = 1 - current_point
		target_point = point_b if current_point == 1 else point_a
	velocity = direction * speed
	move_and_slide()
