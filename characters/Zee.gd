extends KinematicBody2D

# imports
onready var hit_effect = preload("res://objects/effects/Hit_effects.tscn")
onready var screen_shake = preload("res://objects/effects/Screen_shake.tscn")

# children
onready var sprite = $sprite;
onready var right_raycasts = $wall_raycasts/right
onready var left_raycasts = $wall_raycasts/left
onready var feetcast = $feetcast
var punch_shape

# physics constants
const RUN_ACCEL = 300
const STOP_ACCEL = 160
const JUMP_SPEED = -1300
const AIR_X_ACCEL = 250
const FASTFALL_SPEED = 200
const DASH_ACCEL = 1500
const MAX_JUMPS = 2
const MAX_HORIZONTAL_VELOCITY = 600
const MAX_VERTICAL_VELOCITY = 2000
const GRAVITY = 100
const UP = Vector2(0, -1)
const KNOCKBACK_R = Vector2(1500,-1500)
const KNOCKBACK_L = Vector2(-1500,-1500)
const KB_STOP_ACCEL = 40


# other constants
const ATTACK_SPEED = 0.2
const MAX_HEALTH = 6

# properties
var vel = Vector2()
var health = MAX_HEALTH
var jumps = MAX_JUMPS
var left_pressed
var right_pressed
var horizontal_pressed
var can_dash

# signals
signal health_changed(value)

# timer variables
var punch_cooldown = false
var aerial_cooldown = false

# ratchet state machine 2.0
var current_state;
var prev_state;
enum STATES { IDLE, WALK, HURT, JUMP, DJUMP, WJUMP, DASH, FALL, FFALL, CROUCH, PUNCH, AERIAL };
var can_go_from = {
	# from.........to.................................................................................................
	STATES.IDLE  : [STATES.WALK, STATES.JUMP, STATES.DJUMP, STATES.FALL, STATES.CROUCH, STATES.PUNCH],
	STATES.WALK  : [STATES.IDLE, STATES.JUMP, STATES.FALL, STATES.CROUCH, STATES.PUNCH],
	STATES.HURT  : [],
	STATES.JUMP  : [STATES.DJUMP, STATES.FALL, STATES.AERIAL, STATES.DASH],
	STATES.DJUMP : [STATES.IDLE, STATES.AERIAL, STATES.DASH],
	STATES.WJUMP : [STATES.DJUMP, STATES.FALL, STATES.AERIAL],
	STATES.DASH  : [],
	STATES.FALL  : [STATES.IDLE, STATES.JUMP, STATES.DJUMP, STATES.FFALL, STATES.AERIAL, STATES.DASH],
	STATES.FFALL : [STATES.IDLE, STATES.JUMP, STATES.DJUMP, STATES.AERIAL, STATES.DASH],
	STATES.CROUCH: [STATES.IDLE, STATES.WALK, STATES.JUMP],
	STATES.PUNCH : [],
	STATES.AERIAL: [],
}
var uncontrollable_states = [STATES.DASH, STATES.HURT]

func _ready() -> void:
	Global.player = self
	current_state = STATES.IDLE
	self.connect("health_changed", self, "_on_health_changed")

func get_state_from_input():
	left_pressed = Input.is_action_pressed("ui_left")
	right_pressed = Input.is_action_pressed("ui_right")

	# involuntary states (nothing pressed)	
	if is_on_floor():
		if STATES.IDLE in can_go_from[current_state]:
			prev_state = current_state
			current_state = STATES.IDLE
	else:
		if STATES.FALL in can_go_from[current_state] and vel.y > 0: # this sucks but idk how else to do it
			prev_state = current_state
			current_state = STATES.FALL

	# left or right 
	if left_pressed or right_pressed:
		if STATES.WALK in can_go_from[current_state]:
			prev_state = current_state
			current_state = STATES.WALK

	# up
	if Input.is_action_just_pressed("ui_up"):
		if STATES.JUMP in can_go_from[current_state] and jumps == 2:
			prev_state = current_state
			current_state = STATES.JUMP
		#elif STATES.WJUMP in can_go_from[current_state] and jumps == 1 and check_wall():
			#current_state = STATES.WJUMP
		elif STATES.DJUMP in can_go_from[current_state] and jumps == 1:
			prev_state = current_state
			current_state = STATES.DJUMP

	# down
	if Input.is_action_pressed("ui_down"):
		if STATES.FFALL in can_go_from[current_state]:
			prev_state = current_state
			current_state = STATES.FFALL
		elif STATES.CROUCH in can_go_from[current_state]:
			prev_state = current_state
			current_state = STATES.CROUCH
	
	# "a" (default key: p)
	if Input.is_action_just_pressed("a"):
		if !punch_cooldown and STATES.PUNCH in can_go_from[current_state]:
			prev_state = current_state
			current_state = STATES.PUNCH
		if !aerial_cooldown and STATES.AERIAL in can_go_from[current_state]:
			prev_state = current_state
			current_state = STATES.AERIAL
	
	# 'b' (default key: o)
	if Input.is_action_just_pressed("b"):
		if can_dash and STATES.DASH in can_go_from[current_state]:
			prev_state = current_state
			current_state = STATES.DASH

func get_physics_from_state() -> void:
	# you can always control his horizontal movement
	horizontal_pressed = int(right_pressed) - int(left_pressed)
	if horizontal_pressed and !(current_state in uncontrollable_states):
		if is_on_floor():
			vel.x += RUN_ACCEL * horizontal_pressed
		else:
			vel.x += AIR_X_ACCEL * horizontal_pressed
	elif current_state == STATES.HURT:
		if abs(vel.x) < 20:
			 vel.x = 0
		if vel.x > 0:		
			vel.x -= KB_STOP_ACCEL
		elif vel.x < 0:
			vel.x += KB_STOP_ACCEL
	else: 
		if abs(vel.x) < 160:
			 vel.x = 0
		elif vel.x > 0:		
			vel.x -= STOP_ACCEL
		elif vel.x < 0:
			vel.x += STOP_ACCEL
	
	if !(current_state in uncontrollable_states):
		vel.x = clamp(vel.x, -MAX_HORIZONTAL_VELOCITY, MAX_HORIZONTAL_VELOCITY)

	match current_state:
		STATES.IDLE:
			pass
		STATES.WALK:
			pass
		STATES.HURT:
			pass
		STATES.JUMP:
			if jumps == 2:
				vel.y = JUMP_SPEED
				jumps -= 1
		STATES.DJUMP:
			if jumps == 1:
				vel.y = JUMP_SPEED
				jumps -= 1
		STATES.WJUMP:
			pass
		STATES.DASH:
			if can_dash:
				if sprite.flip_h:
					dash(-1)
				else:
					dash(1)
		STATES.FALL:
			pass
		STATES.FFALL:
			if vel.y < MAX_VERTICAL_VELOCITY:
				vel.y += FASTFALL_SPEED
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
		can_dash = true

func apply_gravity() -> void:
	if !is_on_floor() and current_state != STATES.DASH and vel.y < MAX_VERTICAL_VELOCITY:
		vel.y += GRAVITY

func get_sprite_from_state() -> void:
	# flip sprite depending on which way facing
	if current_state != STATES.DASH:
		if vel.x > 0:
			sprite.flip_h = false
		elif vel.x < 0:
			sprite.flip_h = true

	match current_state:
		STATES.IDLE:
			sprite.play("idle")
		STATES.WALK:
			sprite.play("walk")
		STATES.HURT:
			sprite.play("hurt")
		STATES.JUMP:
			sprite.play("straight_jump")
		STATES.DJUMP:
			sprite.play("double_jump")
		STATES.WJUMP:
			pass
		STATES.DASH:
			sprite.play("dash")
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

func get_hitbox_from_state() -> void:
	match current_state:
		STATES.DJUMP:
			pass
#			$collision_box.disabled = true
#			$djump_collision_box.disabled = false
		STATES.CROUCH:
			pass
		_:
			$collision_box.disabled = false
			$djump_collision_box.disabled = true

func check_feet() -> void:
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
	get_hitbox_from_state()
	# warning-ignore:return_value_discarded
	move_and_slide(vel * delta * 60, UP)	

func _process(_delta) -> void:
	match current_state:
		STATES.IDLE:
			$state_label.text = "IDLE"
		STATES.WALK:
			$state_label.text = "WALK"
		STATES.HURT:
			$state_label.text = "HURT"
		STATES.JUMP:
			$state_label.text = "JUMP"
		STATES.DJUMP:
			$state_label.text = "DJUMP"
		STATES.WJUMP:
			$state_label.text = "WJUMP"
		STATES.DASH:
			$state_label.text = "DASH"
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
	if sprite.flip_h:
		punch_shape = $punch_hitbox/shape_left
	else:
		punch_shape = $punch_hitbox/shape_right
	punch_cooldown = true
	punch_shape.disabled = false
	$punch_timer.start()
	yield($punch_timer, "timeout")
	punch_shape.disabled = true
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

func dash(dir) -> void:
	can_dash = false
	vel.y = 0
	vel.x += dir * DASH_ACCEL
	$dash_timer.start()
	yield($dash_timer, "timeout")

func knockedback(enemy) -> void:
	if enemy.position.x > position.x:
		vel = KNOCKBACK_L
	if enemy.position.x < position.x:
		vel = KNOCKBACK_R

func disable_hurtbox() -> void:
	$hurtbox/shape.disabled = true;

func hurt_effect() -> void:
	$Camera/Screen_shake.start()	
#	Engine.set_time_scale(0.1)
#	Engine.set_iterations_per_second(3)
#	Engine.set_physics_jitter_fix(0)
#	yield(get_tree().create_timer(0.05), "timeout")
#	Engine.set_time_scale(1)
#	Engine.set_iterations_per_second(60)
#	Engine.set_physics_jitter_fix(0.5)

func check_wall(wall_raycasts):
	for raycast in wall_raycasts.get_children():
		if raycast.is_colliding():
			var dot = acos(Vector2.UP.dot(raycast.get_collision_normal()))
			if dot > PI * 0.45:
				return true
	return false

func _on_hurtbox_area_entered(area) -> void:
	if area.is_in_group("player_damager"):
		emit_signal("health_changed", -1)
		var enemy = area.get_parent()
		knockedback(enemy);

func _on_health_changed(change):
	health += change;
	if health <= 0:
		# warning-ignore:return_value_discarded
		get_tree().reload_current_scene()
	elif change < 0:
		current_state = STATES.HURT;
		call_deferred("disable_hurtbox")
		hurt_effect()
		$invincibility_timer.start()
		$hurt_timer.start()

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

func _on_aerial_timer_timeout():
	current_state = STATES.FALL

func _on_dash_timer_timeout():
	current_state = STATES.FALL

func _on_hurt_timer_timeout():
	current_state = STATES.IDLE

func _on_invincibility_timer_timeout():
	$hurtbox/shape.disabled = false
