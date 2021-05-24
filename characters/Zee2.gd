extends KinematicBody2D

onready var hit_effect = preload("res://objects/effects/Hit_effects.tscn")

onready var sprite = $sprite;

# physics constants
const run_accel = 160
const stop_accel = 160
const jump_speed = -1350
const fastfall_speed = 200
const max_jumps = 2

const MAX_HORIZONTAL_VELOCITY = 600
const MAX_VERTICAL_VELOCITY = 2000
const GRAVITY = 100
const UP = Vector2(0, -1)

# other constants
const ATTACK_SPEED = 0.2

# properties
var vel = Vector2()
var x_accel = 0
var jumps = max_jumps
var left_pressed
var right_pressed

var punch_cooldown = false

func _ready():
	Global.player = self

func _get_input():
	left_pressed = Input.is_action_pressed("ui_left")
	right_pressed = Input.is_action_pressed("ui_right")
	# calculates horizontal acceleration/velocity
	vel.x += run_accel * (int(right_pressed) - int(left_pressed))
	if vel.x > 0:		
		vel.x -= stop_accel
	elif vel.x < 0:
		vel.x += stop_accel

func _apply_gravity(delta):
	if !is_on_floor() and vel.y < MAX_VERTICAL_VELOCITY:
		vel.y += GRAVITY;

func _apply_movement(delta):
	# warning-ignore:return_value_discarded
	move_and_slide(vel * delta * 60, UP)

func _process(_delta):
	pass
	
func fastfall():
	if vel.y < MAX_VERTICAL_VELOCITY:
		vel.y += fastfall_speed

func punch():
	punch_cooldown = true
	$punch_hitbox/shape.disabled = false
	yield(get_tree().create_timer(0.2), "timeout")
	$punch_hitbox/shape.disabled = true
	# attack speed timer
	yield(get_tree().create_timer(ATTACK_SPEED), "timeout")
	punch_cooldown = false

func _on_hurtbox_area_entered(area):
	if area.is_in_group("player_damager"):
		get_tree().reload_current_scene()

func _on_punch_hitbox_area_entered(area):
	if area.is_in_group("enemy"):
		var impact_point = $punch_hitbox.global_position + Vector2(50, 0)
		var hit_circles = Global.instance_node_at(hit_effect, impact_point, Global.main)
		hit_circles.emitting = true
