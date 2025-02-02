extends CharacterBody2D

@onready var navigation_agent_2d = $NavigationAgent2D
@onready var world = $"../"
@onready var progress_bar = $ProgressBar

var speed = 195
var accel = 7
var chase = false
var switch_time = 1
var point_index = 0

func _process(delta):
	if not world.paused:
		switch_time-= delta
		if switch_time <= 0:
			switch_time = 1
			progress_bar.toggle_fill_color()
		if chase:

			if world.car:  # Ensure world.car exists before accessing position
				navigation_agent_2d.target_position = world.car.position
				#if progress_bar.value <= 0:
					#chase = false
		elif not world.ai_stop:  # Only move if ai_stop is false
			if world.points.size() > point_index and world.points[point_index]:  # Check if the point exists
				navigation_agent_2d.target_position = world.points[point_index].global_position

				# Check if AI reached the current point and increment index
				if global_position.distance_to(world.points[point_index].global_position) < 10.0:
					point_index = (point_index + 1) % world.points.size()  # Loop safely
		else:
			return  # Stop execution if ai_stop is true

		var direction = navigation_agent_2d.get_next_path_position() - global_position
		if direction.length() > 0:  # Prevent division by zero
			direction = direction.normalized()
		if not global_position.distance_to(world.car.position) < 95.0:
			velocity = velocity.lerp(direction * speed, accel * delta)
			move_and_slide()
			
		if not global_position.distance_to(world.car.position) < 95.0:
			if progress_bar.value > 0:
				progress_bar.value -= 5 * delta

		else:
			if chase:
				if progress_bar.value < 100:
					if progress_bar.value < 50:
						progress_bar.value += 20 * delta
					else: 
						progress_bar.value += 10 * delta
		
		if progress_bar.value <= 0:
			progress_bar.visible = false
			chase = false
		else:
			progress_bar.visible = true

		# Rotate the car to face the direction of movement
		if velocity.length() > 0.01:  # Avoid rotation when stationary
			rotation_degrees = velocity.angle() * 180 / PI + 270
		
		
		if progress_bar.value >= 100:
			world.wasted_screen.visible = true
			world.paused = true

func _on_ai_car_front_area_body_entered(body):
	if body.name == "car" or body.name == "Player":
		world.ai_stop = true

func _on_ai_car_front_area_body_exited(body):
	if body.name == "car" or body.name == "Player":
		world.ai_stop = false
