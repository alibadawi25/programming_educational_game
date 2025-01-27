extends Node2D

@onready var car = $car
@onready var explosion = $car/Explosion/CPUParticles2D
@onready var explosion_sound = $car/Explosion_Fx
@onready var camera_2d = $car/Camera2D

var car_crashed = false
var shake_magnitude = 0.0  # Magnitude of the shake
var shake_time = 0.0  # Remaining time for the shake

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("exit"):
		get_tree().quit()
	if car_crashed:
		car.speed = 0  # Stop the car when it crashes

	# Handle camera shake
	if shake_time > 0:
		shake_time -= delta
		shake_camera()
	else:
		camera_2d.zoom = Vector2(2, 2)
		camera_2d.offset = Vector2.ZERO  # Reset the camera position when shaking ends

# Add a function to perform the camera shake effect
func shake_camera():
	# Apply random offsets within the shake magnitude
	var random_offset = Vector2(
		randf_range(-shake_magnitude, shake_magnitude),
		randf_range(-shake_magnitude, shake_magnitude)
	)
	camera_2d.offset = random_offset

func _on_car_crash_body_entered(body):
	if body.name == "car":
		car_crashed = true

		# Set the number of particles based on the car's speed
		var particle_count = int(abs(car.speed))  # Absolute value of speed to avoid negative particles
		explosion.amount = particle_count
		explosion.emitting = true  # Start emitting particles when crash happens

		# Set the volume based on car speed
		var volume = abs(car.speed) / 10.0 - 30  # Normalize speed to a volume range (-60 dB to 0 dB)
		explosion_sound.volume_db = volume

		explosion_sound.play()

		# Start camera shake with magnitude and duration based on speed
		shake_magnitude = abs(car.speed) / 50.0  # Scale shake magnitude with speed
		shake_time = 0.5  # Shake duration (adjust as needed)
		camera_2d.zoom = Vector2(2.3, 2.3)

func _on_car_crash_body_exited(body):
	if body.name == "car":
		car_crashed = false
		explosion.emitting = false  # Stop emitting particles when crash is over
