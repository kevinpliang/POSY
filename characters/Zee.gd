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

# ratchet state machine
var states = [
	"idle",
	"walk",
	"jump",
	"falling",
	"crouch",
	"punch"
]
var current_state = "idle"
var can_walk_states = ["idle", "walk", "crouch"]
var can_jump_states = ["idle", "walk", "crouch"]
var can_crouch_states = ["idle", "walk"]
var can_punch_states = ["idle", "walk"]

func _ready():
	Global.player = self

func get_input():
	left_pressed = Input.is_action_pressed("ui_left")
	right_pressed = Input.is_action_pressed("ui_right")
	
	# calculates horizontal acceleration/velocity
	if current_state in can_walk_states and abs(vel.x) < MAX_HORIZONTAL_VELOCITY and (left_pressed or right_pressed):
		current_state = "walk"
		vel.x += run_accel * (int(right_pressed) - int(left_pressed))
	elif vel.x > 0:		
		vel.x -= stop_accel
	elif vel.x < 0:
		vel.x += stop_accel
	
	# refresh jumps if on floor
	if is_on_floor():
		jumps = max_jumps
		
	# if you can jump and a jump is input, jump
	if current_state in can_jump_states and jumps > 0 and Input.is_action_just_pressed("ui_up"):
		jump()
		
	# fast fall if you press down and are in the air
	# crouch if on ground
	if Input.is_action_pressed("ui_down"):
		if !is_on_floor(): 
			fastfall()
		if current_state in can_crouch_states and is_on_floor():
			current_state = "crouch"
			vel.x = 0
	
	if Input.is_action_just_released("ui_down"):
		current_state = "idle"
		
	# punch
	if current_state in can_punch_states and is_on_floor() and !punch_cooldown and Input.is_action_just_pressed("a"):
		punch()

func show_sprite() -> void:
	# flip sprite depending on which way facing
	if vel.x > 0:
		sprite.flip_h = false
	elif vel.x < 0:
		sprite.flip_h = true
		
	# if in the air
	if !is_on_floor():
		# jumping -- straight
		if vel.y <= 0 and vel.x == 0 and jumps == 1: 
			sprite.play("straight_jump")
		elif vel.y <= 0 and vel.x != 0 and jumps == 1:
			sprite.play("straight_jump")
		elif vel.y <= 0 and jumps == 0:
			sprite.play("double_jump")
		# falling
		elif vel.y > 0 and jumps == 1: 
			sprite.play("fall")
	# if on the floor
	elif is_on_floor():
		# crouching
		if current_state == "crouch":
			sprite.play("crouch")
		elif current_state == "punch":
			sprite.play("punch")
		# standing still
		elif vel.x == 0: 
			sprite.play("idle") 
		# moving horizontally
		else:
			sprite.play("walk")

func _physics_process(delta):
	if !is_on_floor() and vel.y < MAX_VERTICAL_VELOCITY:
		vel.y += GRAVITY;
	# calculate motion (normalized)
	get_input()
	show_sprite()
	# warning-ignore:return_value_discarded
	move_and_slide(vel * delta * 60, UP)	

func _process(_delta):
	pass
	
func jump():
	jumps -= 1
	vel.y = jump_speed

func fastfall():
	if vel.y < MAX_VERTICAL_VELOCITY:
		vel.y += fastfall_speed

func punch():
	current_state = "punch"
	punch_cooldown = true
	$punch_hitbox/shape.disabled = false
	yield(get_tree().create_timer(0.2), "timeout")
	$punch_hitbox/shape.disabled = true
	current_state = "idle"
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
