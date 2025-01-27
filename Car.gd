extends CharacterBody2D

# Car movement parameters
const ACCELERATION = 100.0
const MAX_SPEED = 200.0
const TURN_SPEED = 4.0
const FRICTION = 10.0
const DECELERATION = 100.0  # Deceleration factor when no input is given
const TURN_SMOOTHNESS = 5.0  # Smoothness factor for turning

@onready var city = $"../"

# Car's current velocity and steering angle
var speed = 0.0
var steering_angle = 0.0
var target_steering_angle = 0.0  # Target steering angle to smooth out the steering

func _physics_process(delta):
	var forward_input = 0
	var steering_input = 0
	# Get the input for acceleration and steering
	if city.is_in_car:
		forward_input = Input.get_action_strength("ui_up") - Input.get_action_strength("ui_down")
		steering_input = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	else:
		forward_input = 0
		steering_input = 0
	# Apply acceleration or deceleration based on input
	if forward_input != 0:
		# Accelerate when forward input is provided
		speed += ACCELERATION * forward_input * delta
		speed = clamp(speed, -MAX_SPEED, MAX_SPEED)  # Limit speed to max speed
	else:
		# Apply deceleration when no input is given (slower deceleration)
		if speed != 0:
			var deceleration = sign(speed) * DECELERATION * delta
			speed -= deceleration
			if abs(speed) < abs(deceleration):
				speed = 0.0  # Stop the car when it slows down enough

	# Smooth turning: interpolate towards target steering angle
	var target_steering = steering_input * TURN_SPEED
	target_steering_angle += target_steering * delta
	steering_angle = lerp_angle(steering_angle, target_steering_angle, TURN_SMOOTHNESS * delta)
	rotation = steering_angle  # Set the car's rotation based on steering

	# Move the car forward based on current speed and direction
	var direction = Vector2(1, 0).rotated(rotation)  # Get direction based on rotation
	velocity = direction * speed
	move_and_slide()
