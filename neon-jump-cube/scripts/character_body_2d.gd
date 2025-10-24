extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -400.0

@onready var animated_sprite = $AnimatedSprite2D

var in_speed_zone = false
var zone_direction = Vector2.ZERO
var zone_boost = 0.0

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("UP") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var direction := Input.get_axis("LEFT", "RIGHT")

	if in_speed_zone:
		if direction == 0:
			velocity.x = zone_direction.x * (SPEED + zone_boost)
		else:
			velocity.x = direction * (SPEED + zone_boost)
	else:
		if direction != 0:
			velocity.x = direction * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()

	if not is_on_floor() and velocity.y > 0:
		animated_sprite.play("Falling")
	elif direction != 0 or in_speed_zone:
		animated_sprite.play("Runing")
		animated_sprite.flip_h = velocity.x < 0
	else:
		animated_sprite.play("Idle")
