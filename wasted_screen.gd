extends Control

func _input(event):
	if (event.is_action_pressed("ui_cancel") or event.is_action_pressed("ui_accept")) and visible:  # Default "Esc" key
		restart()
		
func restart():
	get_tree().change_scene_to_file("res://room.tscn")
