extends Node2D

onready var vel = Vector2(1,0)
onready var speed = 0

func _process(delta):
	# rotated so bullet follows velocity direction not axis
	global_position += vel.rotated(rotation) * speed * delta

func _on_VisibilityNotifier2D_screen_exited():
	queue_free()
