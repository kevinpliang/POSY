extends AnimatedSprite

onready var animations = $AnimationPlayer

func _ready():
	pass
	
func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "fall":
		queue_free()
