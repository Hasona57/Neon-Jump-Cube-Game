extends Camera2D

var target: Node2D = null
var zoomed = false
var center = Vector2.ZERO

func _ready():
	center = get_viewport_rect().size / 2
	make_current()

func _process(_delta):
	if Input.is_action_just_pressed("zoom"):
		print("Z pressed!")
		if zoomed:
			target = null
			zoomed = false
		else:
			target = owner.get_node("Player")
			zoomed = true

	if zoomed and target:
		zoom = zoom.move_toward(Vector2(0.3, 0.3), 0.)
		position = position.move_toward(target.global_position, 500)
	else:
		zoom = zoom.move_toward(Vector2(1, 1), 0.2)
		position = position.move_toward(center, 500)
