extends KinematicBody2D

const GRAVITY = 100
const UP = Vector2(0, -1)

var vel = Vector2(0,0)
var health = 100

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _physics_process(delta):
	while vel.x > 0:
		vel.x -= 10
	if !is_on_floor():
		vel.y += GRAVITY;
	# warning-ignore:return_value_discarded
	move_and_slide(vel * delta * 60, UP)	

func knockback() -> void:
	vel.y += 1000
	vel.x += 100

func _on_hurtbox_area_entered(area):
	health -= 10
	if health <= 0:
		queue_free()
	if area.is_in_group("enemy_damager"):
		knockback()
		print("ouch!")
