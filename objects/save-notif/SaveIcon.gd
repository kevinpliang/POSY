extends Node2D

func _on_IntroPlayer_animation_finished(anim_name):
	queue_free()
