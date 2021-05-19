extends KinematicBody2D

onready var sprite = $sprite
onready var bullet = preload("res://objects/hazards/Bullet_love.tscn")

# properties
var vel = Vector2(300, 0)
var speed = 800
var time = 0

# for cosine movement
var freq = 5
var amplitude = 300

func _physics_process(delta):
	if global_position.x < 0 or global_position.x > 1920:
		vel.x *= -1
	time += delta
	vel.y = cos(time * freq) * amplitude
	move_and_slide(vel * delta * 60)

func _process(delta):
	if vel.x < 0:
		sprite.flip_h = true
	else:
		sprite.flip_h = false

func shoot():
	var player_pos = Global.player.global_position
	sprite.play("shoot")
	var love_bullet = Global.instance_node_at(bullet, global_position, Global.main)
	love_bullet.vel = (player_pos - global_position).normalized()
	love_bullet.speed = 1000
	yield( get_tree().create_timer(0.2), "timeout")
	sprite.play("default")

func _on_fire_rate_timeout():
	shoot()
