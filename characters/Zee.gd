extends KinematicBody2D

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

# boolean properties
var jumping = false
var falling = false
var crouching = false
var punching = false
var can_move = true
var can_jump = true
var can_punch = true

func _ready():
	Global.player = self

func get_input():
	left_pressed = Input.is_action_pressed("ui_left")
	right_pressed = Input.is_action_pressed("ui_right")
	
	# calculates horizontal acceleration/velocity
	if can_move and abs(vel.x) < MAX_HORIZONTAL_VELOCITY and (left_pressed or right_pressed):
		crouching = false
		vel.x += run_accel * (int(right_pressed) - int(left_pressed))
	elif vel.x > 0:		
		vel.x -= stop_accel
	elif vel.x < 0:
		vel.x += stop_accel
	
	# refresh jumps if on floor
	if is_on_floor():
		jumps = max_jumps
		
	# if you can jump and a jump is input, jump
	if jumps > 0 and can_jump and Input.is_action_just_pressed("ui_up"):
		jump()
		
	# fast fall if you press down and are in the air
	# crouch if on ground
	if Input.is_action_pressed("ui_down"):
		if !is_on_floor(): 
			fastfall()
		if is_on_floor():
			crouching = true
			vel.x = 0
	
	if Input.is_action_just_released("ui_down"):
		crouching = false
		
	# punch
	if can_punch and is_on_floor() and Input.is_action_just_pressed("a"):
		punch()
	
	# flip sprite depending on which way facing
	if vel.x > 0:
		sprite.flip_h = false
		$smoke.flip_h = false
		$punch.flip_h = false
	elif vel.x < 0:
		sprite.flip_h = true
		$smoke.flip_h = true
		$punch.flip_h = true
		
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
		if crouching:
			sprite.play("crouch")
		elif punching:
			$smoke.play("smoke")
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
	# warning-ignore:return_value_discarded
	move_and_slide(vel * delta * 60, UP)	

# warning-ignore:unused_argument
func _process(delta):
	pass
	
func jump():
	jumps -= 1
	vel.y = jump_speed

func fastfall():
	if vel.y < MAX_VERTICAL_VELOCITY:
		vel.y += fastfall_speed

func punch():
	punching = true
	can_jump = false
	can_move = false
	can_punch = false
	$punch.visible = true
	$punch/hitbox/shape.disabled = false
	yield(get_tree().create_timer(0.2), "timeout")
	$punch.visible = false
	$punch/hitbox/shape.disabled = true
	punching = false
	can_jump = true
	can_move = true
	# attack speed timer
	yield(get_tree().create_timer(ATTACK_SPEED), "timeout")	
	can_punch = true

func _on_hurtbox_area_entered(area):
	if area.is_in_group("player_damager"):
		get_tree().reload_current_scene()

func _on_smoke_animation_finished():
	$smoke.stop()
