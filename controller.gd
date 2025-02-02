#extends Node
#
#@export var mouse_speed: float = 200.0  # Adjust speed for comfortable movement
#
#func _process(delta):
	#var mouse_pos = Input.get_mouse_position()  # Get current mouse position
#
	## Get controller movement (analog stick or D-pad)
	#var move_x = Input.get_action_strength("controller-right") - Input.get_action_strength("controller-left")
	#var move_y = Input.get_action_strength("controller-down") - Input.get_action_strength("controller-up")
#
	## Apply movement speed and delta time
	#mouse_pos.x += move_x * mouse_speed * delta
	#mouse_pos.y += move_y * mouse_speed * delta
#
	## Move the mouse cursor
	#Input.warp_mouse(mouse_pos)
#
	## Simulate mouse click
	#if Input.is_action_just_pressed("controller-click"):
		#var click_event = InputEventMouseButton.new()
		#click_event.pressed = true
		#click_event.button_index = MOUSE_BUTTON_LEFT
		#Input.parse_input_event(click_event)
#
	#if Input.is_action_just_released("controller-click"):
		#var release_event = InputEventMouseButton.new()
		#release_event.pressed = false
		#release_event.button_index = MOUSE_BUTTON_LEFT
		#Input.parse_input_event(release_event)
