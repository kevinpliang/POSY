extends StateMachine

func _ready():
	add_state("idle")
	add_state("walk")
	add_state("jump")
	add_state("fall")
	# "crouch",
	# "punch"
	call_deferred("set_state", states.idle)

func _input(event):
# refresh jumps if on floor
	if parent.is_on_floor():
		parent.jumps = parent.max_jumps
		
	# if you can jump and a jump is input, jump
	if [states.idle, states.walk].has(state):
		if Input.is_action_just_pressed("ui_up"):
			parent.jumps -= 1
			parent.vel.y = parent.jump_speed
		
func _state_logic(delta):
	parent._get_input()
	parent._apply_gravity(delta)
	parent._apply_movement(delta)
	
func _get_transition(delta):
	match state:
		states.idle:
			if !parent.is_on_floor():
				if parent.vel.y < 0:
					return states.jump
				elif parent.vel.y > 0:
					return states.fall
			elif parent.vel.x != 0:
				return states.walk
		states.walk:
			if !parent.is_on_floor():
				if parent.vel.y < 0:
					return states.jump
				elif parent.vel.y > 0:
					return states.fall
			elif parent.vel.x == 0:
				return states.idle
		states.jump:
			if parent.is_on_floor():
				return states.idle
			elif parent.vel.y > 0:
				return states.fall
		states.fall:
			if parent.is_on_floor():
				return states.idle
			elif parent.vel.y <= 0:
				return states.jump
	return null
			
func _enter_state(old_state, new_state):
	match new_state:
		states.idle:
			parent.sprite.play("idle")
		states.walk:
			parent.sprite.play("walk")
		states.jump:
			parent.sprite.play("straight_jump")
		states.fall:
			parent.sprite.play("fall")
	
func _exit_state(old_state, new_state):
	pass

