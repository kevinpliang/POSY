extends AnimatedSprite

var can_talk = false
var dialogue1
var dialogue_num = 1

func _ready():
	dialogue1 = Dialogic.start("dahlia_sitting_1")
	dialogue1.connect("timeline_end", self, "on_dialogue_end")
	
func _process(delta):
	if Input.is_action_pressed("a"):
		if can_talk:
			match dialogue_num:
				1:
					add_child(dialogue1)
				2:
					pass
	
func _on_dialogue_range_area_entered(area):
	can_talk = true

func _on_dialogue_range_area_exited(area):
	can_talk = false

func on_dialogue_end():
	dialogue_num +=1;
