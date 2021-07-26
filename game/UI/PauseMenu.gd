extends Control

func _on_Panel_visibility_changed():
	if (visible and $Panel/MarginContainer/VBoxContainer/Resume):
		$Panel/MarginContainer/VBoxContainer/Resume.grab_focus()
