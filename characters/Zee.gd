extends KinematicBody2D

onready var hit_effect = preload("res://objects/effects/Hit_effects.tscn")

onready var sprite = $sprite;

# physics constants
const run_accel = 300
const stop_accel = 160
const jump_speed = -1300
const air_x_accel = 250
const fastfall_speed = 200
const MAX_JUMPS = 2

const MAX_HORIZONTAL_VELOCITY = 600
const MAX_VERTICAL_VELOCITY = 2000
const GRAVITY = 100
const UP = Vector2(0, -1)

# other constants
const ATTACK_SPEED = 0.2

# properties
var vel = Vector2()
var jumps = MAX_JUMPS
var left_pressed
var right_pressed
var horizontal_pressed

# timer variables
var punch_cooldown = false

# ratchet state machine 2.0
var current_state; 
enum STATES { IDLE, WALK, JUMP, DJUMP, FALL, FFALL, CROUCH, PUNCH };
var can_go_from = {
	# from.........to.................................................................................
	STATES.IDLE  : [STATES.WALK, STATES.JUMP, STATES.DJUMP, STATES.FALL, STATES.CROUCH, STATES.PUNCH],
	STATES.WALK  : [STATES.IDLE, STATES.JUMP, STATES.CROUCH, STATES.PUNCH],
	STATES.JUMP  : [STATES.DJUMP, STATES.FALL],
	STATES.DJUMP : [STATES.FALL],
	STATES.FALL  : [STATES.IDLE, STATES.JUMP, STATES.DJUMP, STATES.FFALL],
	STATES.FFALL : [STATES.IDLE, STATES.JUMP, STATES.DJUMP],
	STATES.CROUCH: [STATES.IDLE, STATES.WALK, STATES.JUMP],
	STATES.PUNCH : []
}

func _ready() -> void:
	Global.player = self
	current_state = STATES.IDLE

func get_state_from_input():
	left_pressed = Input.is_action_pressed("ui_left")
	right_pressed = Input.is_action_pressed("ui_right")

	# involuntary states (nothing pressed)	
	if is_on_floor():
		if current_state != STATES.PUNCH:
			current_state = STATES.IDLE
	else:
		if vel.y > 0: # this sucks but idk how else to do it
			current_state = STATES.FALL

	# left or right 
	if left_pressed or right_pressed:
		if STATES.WALK in can_go_from[current_state]:
			current_state = STATES.WALK

	# up
	if Input.is_action_just_pressed("ui_up"):
		if STATES.JUMP in can_go_from[current_state] and jumps == 2:
			current_state = STATES.JUMP
		elif STATES.DJUMP in can_go_from[current_state] and jumps == 1:
			current_state = STATES.DJUMP

	# down
	if Input.is_action_pressed("ui_down"):
		if STATES.FFALL in can_go_from[current_state]:
			current_state = STATES.FFALL
		elif STATES.CROUCH in can_go_from[current_state]:
			current_state = STATES.CROUCH
		
	# "a" (default key: p)
	if Input.is_action_just_pressed("a"):
		if !punch_cooldown and STATES.PUNCH in can_go_from[current_state]:
			current_state = STATES.PUNCH

func get_physics_from_state() -> void:
	# you can always control his horizontal movement
	horizontal_pressed = int(right_pressed) - int(left_pressed)
	if horizontal_pressed:
		if is_on_floor():
			vel.x += run_accel * horizontal_pressed
		else:
			vel.x += air_x_accel * horizontal_pressed
	else: 
		if abs(vel.x) < 160:
			 vel.x = 0
		elif vel.x > 0:		
			vel.x -= stop_accel
		elif vel.x < 0:
			vel.x += stop_accel
	
	vel.x = clamp(vel.x, -MAX_HORIZONTAL_VELOCITY, MAX_HORIZONTAL_VELOCITY)

	match current_state:
		STATES.IDLE:
			pass
		STATES.WALK:
			pass
		STATES.JUMP:
			if jumps == 2:
				vel.y = jump_speed
				jumps -= 1
		STATES.DJUMP:
			if jumps == 1:
				vel.y = jump_speed
				jumps -= 1
		STATES.FALL:
			pass
		STATES.FFALL:
			if vel.y < MAX_VERTICAL_VELOCITY:
				vel.y += fastfall_speed
		STATES.CROUCH:
			vel.x = 0
		STATES.PUNCH:
			vel.x = 0
			punch()

	# refresh jumps
	if is_on_floor():
		jumps = MAX_JUMPS

func apply_gravity() -> void:
	if !is_on_floor() and vel.y < MAX_VERTICAL_VELOCITY:
		vel.y += GRAVITY

func get_sprite_from_state() -> void:
	# flip sprite depending on which way facing
	if vel.x > 0:
		sprite.flip_h = false
	elif vel.x < 0:
		sprite.flip_h = true

	match current_state:
		STATES.IDLE:
			sprite.play("idle")
		STATES.WALK:
			sprite.play("walk")
		STATES.JUMP:
			sprite.play("straight_jump")
		STATES.DJUMP:
			sprite.play("double_jump")
		STATES.FALL:
			sprite.play("fall")
		STATES.FFALL:
			sprite.play("fall")
		STATES.CROUCH:
			sprite.play("crouch")
		STATES.PUNCH:
			sprite.play("punch")

func _physics_process(delta) -> void:
	get_state_from_input()
	apply_gravity()
	get_physics_from_state()
	get_sprite_from_state()
	# warning-ignore:return_value_discarded
	move_and_slide(vel * delta * 60, UP)	

func _process(_delta) -> void:
	match current_state:
		STATES.IDLE:
			$state_label.text = "IDLE"
		STATES.WALK:
			$state_label.text = "WALK"
		STATES.JUMP:
			$state_label.text = "JUMP"
		STATES.DJUMP:
			$state_label.text = "DJUMP"
		STATES.FALL:
			$state_label.text = "FALL"
		STATES.FFALL:
			$state_label.text = "FFALL"
		STATES.CROUCH:
			$state_label.text = "CROUCH"
		STATES.PUNCH:
			$state_label.text = "PUNCH"

func punch() -> void:
	punch_cooldown = true
	$punch_hitbox/shape.disabled = false
	yield(get_tree().create_timer(0.2), "timeout")
	$punch_hitbox/shape.disabled = true
	current_state = STATES.IDLE
	# attack speed timer
	yield(get_tree().create_timer(ATTACK_SPEED), "timeout")
	punch_cooldown = false

func _on_hurtbox_area_entered(area) -> void:
	if area.is_in_group("player_damager"):
		get_tree().reload_current_scene()

func _on_punch_hitbox_area_entered(area) -> void:
	if area.is_in_group("enemy"):
		var impact_point = $punch_hitbox.global_position + Vector2(50, 0)
		var hit_circles = Global.instance_node_at(hit_effect, impact_point, Global.main)
		hit_circles.emitting = true
