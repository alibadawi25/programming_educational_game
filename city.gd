extends Node2D

@onready var car = $car
@onready var explosion = $car/Explosion/CPUParticles2D
@onready var explosion_sound = $car/Explosion_Fx
@onready var camera_2d = $car/Camera2D
@onready var label = $Player/Label
@onready var path_follow_2d = $Car_ai/Path2D/PathFollow2D
@onready var car_ai = $Car_ai
@onready var horn = $Car_ai/horn
@onready var siren = $Car_ai/siren
@onready var enter_label = $Enter_House_Area/Label
@onready var exit_point = $car/Exit_point

@onready var player = $Player
@onready var player_camera_2d = $Player/Camera2D
@onready var halal_music = $Halal_music
@onready var wasted_screen = $"CanvasLayer/Wasted Screen"

@onready var point = $MapAiChasePoints/point
@onready var point_2 = $MapAiChasePoints/point2
@onready var point_3 = $MapAiChasePoints/point3
@onready var point_4 = $MapAiChasePoints/point4
@onready var point_5 = $MapAiChasePoints/point5
@onready var point_6 = $MapAiChasePoints/point6

@onready var points = [point, point_2, point_3, point_4, point_5, point_6]


var paused = false
var can_enter_car = false
var can_enter_house = true
var is_in_car = false
var is_car_in_water = false
var car_crashed = false
var shake_magnitude = 0.0  # Magnitude of the shake
var shake_time = 0.0  # Remaining time for the shake
var is_going_forward = true
var car_pos
var old_car_pos
var ai_stop = false
var stop_time = 0
var coins
var is_tutorial = false
var is_first_time_playing = false
# Called when the node enters the scene tree for the first time.
func _ready():
	#halal_music.play()
	player.set_speed(80)
	old_car_pos = car_pos
	var file = FileAccess.open("user://data.txt", FileAccess.READ)
	if file:
		var all_lines = []  # To store all lines from the file


		# Read the rest of the file
		while not file.eof_reached():
			all_lines.append(file.get_line())  # Append each line to the list
			
		file.close()  # Always close the file when done
		coins = int(all_lines[3])
		# Now you can use `all_lines` to access any part of the file later
		print("All file lines:", all_lines)
			
	else:
		print("File could not be opened.")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):

	if not paused:
		if not ai_stop or car_ai.chase:
			if not siren.playing: 
				siren.play()
			stop_time = 0
			#car_ai.position = Vector2(320, 672)
			#car_ai.position += path_follow_2d.position *2
			#var speed = 100
			#path_follow_2d.progress += delta * speed
			#
			#car_pos = car_ai.position
			#set_car_ai_direction()
		else:
			
			stop_time += delta
			if stop_time > 2:
				siren.playing = false
				if not horn.playing and not siren.playing:
					horn.play()
			if not siren.playing and not horn.playing: 
				siren.play()
				
		#if Input.is_action_just_pressed("exit"):
			#var coordinates = "800 400"
			#var filedata = coordinates + "\n" + "false"  + "\n" + str(is_tutorial) + "\n" + str(coins)
			#var file = FileAccess.open("user://data.txt", FileAccess.WRITE)
			#if file:
				#file.store_line(filedata)  # This will overwrite the file content
				#file.close()  # Always close the file when done
			#else:
				#print("Failed to open file.")
			#get_tree().quit()
			
		if car_crashed:
			car.speed = 0  # Stop the car when it crashes
		
		if not player.visible and label.visible:
			label.visible = false

		
		if can_enter_car and Input.is_action_just_pressed("R") and not is_in_car:
			player.visible = false
			camera_2d.make_current()
			is_in_car = true
			
		elif Input.is_action_just_pressed("R") and is_in_car:
			player.visible = true
			player_camera_2d.make_current()
			player.position = exit_point.global_position

			is_in_car = false
			
		if can_enter_house and Input.is_action_just_pressed("E"):
			get_tree().change_scene_to_file("res://room.tscn")
		
		if is_in_car:
			# Handle camera shake
			if shake_time > 0:
				shake_time -= delta
				shake_camera()
			else:
				camera_2d.zoom = Vector2(2, 2)
				camera_2d.offset = Vector2.ZERO  # Reset the camera position when shaking ends
	else:
		siren.playing = false
# Add a function to perform the camera shake effect
func shake_camera():
	# Apply random offsets within the shake magnitude
	var random_offset = Vector2(
		randf_range(-shake_magnitude, shake_magnitude),
		randf_range(-shake_magnitude, shake_magnitude)
	)
	camera_2d.offset = random_offset

#func _on_car_crash_body_entered(body):
	#if body.name == "car":
		#car_crashed = true
#
		## Set the number of particles based on the car's speed
		#var particle_count = int(abs(car.speed))  # Absolute value of speed to avoid negative particles
		#explosion.amount = particle_count
		#explosion.emitting = true  # Start emitting particles when crash happens
#
		## Set the volume based on car speed
		#var volume = abs(car.speed) / 10.0 - 30  # Normalize speed to a volume range (-60 dB to 0 dB)
		#explosion_sound.volume_db = volume
#
		#explosion_sound.play()
#
		## Start camera shake with magnitude and duration based on speed
		#shake_magnitude = abs(car.speed) / 50.0  # Scale shake magnitude with speed
		#shake_time = 0.5  # Shake duration (adjust as needed)
		#camera_2d.zoom = Vector2(2.3, 2.3)

#func _on_car_crash_body_exited(body):
	#if body.name == "car":
		#car_crashed = false
		#explosion.emitting = false  # Stop emitting particles when crash is over


func _on_area_2d_body_entered(body):
	if body.name == "Player":
		label.visible = true
		can_enter_car = true


func _on_area_2d_body_exited(body):
	if body.name == "Player":
		label.visible = false
		can_enter_car = false


#func _on_water_body_entered(body):
	#if body.name == "car":
		#is_car_in_water = true
#
#
#func _on_water_body_exited(body):
	#if body.name == "car":
		#is_car_in_water = false


func _on_car_collision_body_entered(body):
	print(body)
	if body.name == "Car_ai":
		car_ai.chase = true
		car_crashed = true

		# Set the number of particles based on the car's speed
		var particle_count = int(abs(car.speed))  # Absolute value of speed to avoid negative particles
		explosion.amount = particle_count
		explosion.emitting = true  # Start emitting particles when crash happens

		# Set the volume based on car speed, adjusting more drastically for higher speed
		var volume = clamp(abs(car.speed) / 5.0 - 40, -60, 0)  # Normalize speed to a volume range (-60 dB to 0 dB)
		explosion_sound.volume_db = volume  # Apply the calculated volume

		# Optionally change the pitch for more variation in sound
		explosion_sound.pitch_scale = 1 + (abs(car.speed) / car.MAX_SPEED) * 0.5  # Scale pitch based on speed

		explosion_sound.play()

		# Start camera shake with magnitude and duration based on speed
		shake_magnitude = abs(car.speed) / 50.0  # Scale shake magnitude with speed
		shake_time = 0.5  # Shake duration (adjust as needed)
		camera_2d.zoom = Vector2(2.3, 2.3)  # Zoom in during the crash


func _on_car_collision_body_exited(body):
	if body.name == "Car_ai":
		car_crashed = false
		explosion.emitting = false  # Stop emitting particles when crash is over


#func _on_ai_car_front_area_body_entered(body):
	#if body.name == "car" or body.name == "Player":
		#ai_stop = true
	#
#
#
#func _on_ai_car_front_area_body_exited(body):
	#if body.name == "car" or body.name == "Player":
		#ai_stop = false


func _on_car_crash_area_entered(area):
	if area.name == "Car_front":
		car_crashed = true

		# Set the number of particles based on the car's speed
		var particle_count = int(abs(car.speed))  # Absolute value of speed to avoid negative particles
		explosion.amount = particle_count
		explosion.emitting = true  # Start emitting particles when crash happens

		# Set the volume based on car speed, adjusting more drastically for higher speed
		var volume = clamp(abs(car.speed) / 5.0 - 40, -60, 0)  # Normalize speed to a volume range (-60 dB to 0 dB)
		explosion_sound.volume_db = volume  # Apply the calculated volume

		# Optionally change the pitch for more variation in sound
		explosion_sound.pitch_scale = 1 + (abs(car.speed) / car.MAX_SPEED) * 0.5  # Scale pitch based on speed

		explosion_sound.play()

		# Start camera shake with magnitude and duration based on speed
		shake_magnitude = abs(car.speed) / 50.0  # Scale shake magnitude with speed
		shake_time = 0.5  # Shake duration (adjust as needed)
		camera_2d.zoom = Vector2(2.3, 2.3)  # Zoom in during the crash


func _on_car_crash_area_exited(area):
	if area.name == "Car_front":
		car_crashed = false
		explosion.emitting = false  # Stop emitting particles when crash is over


func _on_water_area_entered(area):
	if area.name == "Car_front":
		is_car_in_water = true


func _on_water_area_exited(area):
	if area.name == "Car_front":
		is_car_in_water = false


func _on_enter_house_area_body_entered(body):
	print(body.name)
	if body.name == "Player" and player.visible:
		enter_label.visible = true
		can_enter_house = true


func _on_enter_house_area_body_exited(body):
	if body.name == "Player" and player.visible:
		enter_label.visible = false
		can_enter_house = false
