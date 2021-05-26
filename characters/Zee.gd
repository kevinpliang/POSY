extends KinematicBody2D

# imports
onready var hit_effect = preload("res://objects/effects/Hit_effects.tscn")

# children
onready var sprite = $sprite;
onready var right_raycasts = $wall_raycasts/right
onready var left_raycasts = $wall_raycasts/left
onready var feetcast = $feetcast

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
const WDASH_COOLDOWN = 2

# properties
var vel = Vector2()
var jumps = MAX_JUMPS
var left_pressed
var right_pressed
var horizontal_pressed
var can_wavedash

# timer variables
var punch_cooldown = false
var aerial_cooldown = false

# ratchet state machine 2.0
var current_state;
var prev_state;
enum STATES { IDLE, WALK, JUMP, DJUMP, WJUMP, FALL, FFALL, CROUCH, PUNCH, AERIAL };
var can_go_from = {
	# from.........to.................................................................................................
	STATES.IDLE  : [STATES.WALK, STATES.JUMP, STATES.DJUMP, STATES.FALL, STATES.CROUCH, STATES.PUNCH],
	STATES.WALK  : [STATES.IDLE, STATES.JUMP, STATES.FALL, STATES.CROUCH, STATES.PUNCH],
	STATES.JUMP  : [STATES.DJUMP, STATES.FALL, STATES.AERIAL],
	STATES.DJUMP : [STATES.IDLE, STATES.AERIAL, ],
	STATES.WJUMP : [STATES.DJUMP, STATES.FALL, STATES.AERIAL],
	STATES.FALL  : [STATES.IDLE, STATES.JUMP, STATES.DJUMP, STATES.FFALL, STATES.AERIAL],
	STATES.FFALL : [STATES.IDLE, STATES.JUMP, STATES.DJUMP, STATES.AERIAL],
	STATES.CROUCH: [STATES.IDLE, STATES.WALK, STATES.JUMP],
	STATES.PUNCH : [],
	STATES.AERIAL: [],
}

func _ready() -> void:
	Global.player = self
	current_state = STATES.IDLE

func get_state_from_input():
	left_pressed = Input.is_action_pressed("ui_left")
	right_pressed = Input.is_action_pressed("ui_right")

	# involuntary states (nothing pressed)	
	if is_on_floor():
		if STATES.IDLE in can_go_from[current_state]:
			current_state = STATES.IDLE
	else:
		if STATES.FALL in can_go_from[current_state] and vel.y > 0: # this sucks but idk how else to do it
			current_state = STATES.FALL

	# left or right 
	if left_pressed or right_pressed:
		if STATES.WALK in can_go_from[current_state]:
			current_state = STATES.WALK

	# up
	if Input.is_action_just_pressed("ui_up"):
		if STATES.JUMP in can_go_from[current_state] and jumps == 2:
			current_state = STATES.JUMP
		#elif STATES.WJUMP in can_go_from[current_state] and jumps == 1 and check_wall():
			#current_state = STATES.WJUMP
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
		if !aerial_cooldown and STATES.AERIAL in can_go_from[current_state]:
			prev_state = current_state
			current_state = STATES.AERIAL

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
		STATES.WJUMP:
			pass
		STATES.FALL:
			pass
		STATES.FFALL:
			if vel.y < MAX_VERTICAL_VELOCITY:
				vel.y += fastfall_speed
		STATES.CROUCH:
			vel.x = 0
		STATES.PUNCH:
			vel.x = 0
			if !punch_cooldown:
				punch()
		STATES.AERIAL:
			if !aerial_cooldown:
				aerial()

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
		STATES.WJUMP:
			pass
		STATES.FALL:
			sprite.play("fall")
		STATES.FFALL:
			sprite.play("fall")
		STATES.CROUCH:
			sprite.play("crouch")
		STATES.PUNCH:
			sprite.play("punch")
		STATES.AERIAL:
			sprite.play("aerial")

func check_feet():
	if feetcast.is_colliding():
		var collider = feetcast.get_collider()
		var origin = feetcast.global_transform.origin
		var collision_point = feetcast.get_collision_point()
		var distance = origin.distance_to(collision_point)
		# gazebo stairs..
		if collider.is_in_group("lower_z"):
			self.z_index = -1
	else:
		self.z_index = 0

func _physics_process(delta) -> void:
	#checks
	check_feet()
	
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
		STATES.WJUMP:
			$state_label.text = "WJUMP"
		STATES.FALL:
			$state_label.text = "FALL"
		STATES.FFALL:
			$state_label.text = "FFALL"
		STATES.CROUCH:
			$state_label.text = "CROUCH"
		STATES.PUNCH:
			$state_label.text = "PUNCH"
		STATES.AERIAL:
			$state_label.text = "AERIAL"

func punch() -> void:
	punch_cooldown = true
	$punch_hitbox/shape.disabled = false
	$punch_timer.start()
	yield($punch_timer, "timeout")
	$punch_hitbox/shape.disabled = true
	# attack speed timer
	yield(get_tree().create_timer(ATTACK_SPEED), "timeout")
	punch_cooldown = false

func aerial() -> void:
	aerial_cooldown = true
	$aerial_hitbox/shape.disabled = false
	$aerial_timer.start()
	yield($aerial_timer, "timeout")
	$aerial_hitbox/shape.disabled = true
	# attack speed timer
	yield(get_tree().create_timer(ATTACK_SPEED), "timeout")
	aerial_cooldown = false

func check_wall(wall_raycasts):
	for raycast in wall_raycasts.get_children():
		if raycast.is_colliding():
			var dot = acos(Vector2.UP.dot(raycast.get_collision_normal()))
			if dot > PI * 0.45:
				return true
	return false

func _on_hurtbox_area_entered(area) -> void:
	if area.is_in_group("player_damager"):
		get_tree().reload_current_scene()

func _on_punch_hitbox_area_entered(area) -> void:
	if area.is_in_group("enemy"):
		var impact_point = $punch_hitbox.global_position + Vector2(50, 0)
		var hit_circles = Global.instance_node_at(hit_effect, impact_point, Global.main)
		hit_circles.emitting = true

func _on_aerial_hitbox_area_entered(area):
	if area.is_in_group("enemy"):
		var impact_point = $aerial_hitbox.global_position + Vector2(50, 0)
		var hit_circles = Global.instance_node_at(hit_effect, impact_point, Global.main)
		hit_circles.emitting = true

func _on_punch_timer_timeout():
	current_state = STATES.IDLE
	$punch_timer.stop()

func _on_aerial_timer_timeout():
	current_state = STATES.FALL
	$aerial_timer.stop()


