extends Control

func _on_Panel_visibility_changed():
	if (visible and $Panel/MarginContainer/VBoxContainer/QuitNo):
		$Panel/MarginContainer/VBoxContainer/QuitNo.grab_focus()
