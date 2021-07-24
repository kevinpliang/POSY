extends KinematicBody2D

# physics constants
const WALK_SPEED = 300
const MAX_VERTICAL_VELOCITY = 2000
const GRAVITY = 100
const UP = Vector2(0, -1)

# properties
var vel = Vector2.ZERO

# other stuff
onready var visibilityNotifier = $VisibilityNotifier2D

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _physics_process(_delta) -> void:
	apply_gravity()
	move(_delta)
	get_sprite_from_physics()

func apply_gravity() -> void:
	if !is_on_floor() and vel.y < MAX_VERTICAL_VELOCITY:
		vel.y += GRAVITY

func move(delta) -> void:
	move_and_slide(vel * delta * 60, UP)

func get_sprite_from_physics():
	if (vel.x < 0):
		$sprite.flip_h = true
	elif (vel.x > 0):
		$sprite.flip_h = false
	
	if (vel.x == 0):
		$sprite.play("idle")
	else:
		$sprite.play("walk")

