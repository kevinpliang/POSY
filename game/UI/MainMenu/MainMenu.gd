extends Control

func _ready():
	$Panel/MarginContainer/VBoxContainer/Start.grab_focus()

func _on_Panel_visibility_changed():
	if (visible and $Panel/MarginContainer/VBoxContainer/Start):
		$Panel/MarginContainer/VBoxContainer/Start.grab_focus()
