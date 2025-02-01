extends CharacterBody2D

const ACCELERATION = 100.0
const MAX_SPEED = 200.0
const TURN_SPEED = 4.0
const FRICTION = 10.0
const DECELERATION = 100.0
const TURN_SMOOTHNESS = 5.0
const BRAKE_FORCE = 300.0

@onready var city = $"../"

var r = 1.0
var g = 1.0
var b = 1.0
var a = 1.0
var speed = 0.0
var min_speed = 0
var steering_angle = 0.0
var target_steering_angle = 0.0

func _physics_process(delta):
	if not city.paused:
		min_speed = 0
		var forward_input = 0
		var steering_input = 0

		# Get player input
		if city.is_in_car:
			if not city.is_car_in_water:
				forward_input = Input.get_action_strength("ui_up") - Input.get_action_strength("ui_down")
				min_speed = 0
			else:
				min_speed = 20
			steering_input = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
		else:
			forward_input = 0
			steering_input = 0

		# Apply water effect smoothly
		if city.is_car_in_water:
			r = lerp(r, 0.35, delta * 2)
			g = lerp(g, 0.35, delta * 2)
			b = lerp(b, 1.0, delta * 2)
		else:
			r = lerp(r, 1.0, delta * 2)
			g = lerp(g, 1.0, delta * 2)
			b = lerp(b, 1.0, delta * 2)

		modulate = Color(r, g, b, a)

		# Braking & Acceleration
		if forward_input > 0:
			speed += ACCELERATION * forward_input * delta
			speed = clamp(speed, -MAX_SPEED, MAX_SPEED)
		elif forward_input < 0:
			if speed > 0:
				# Brake if moving forward
				speed -= BRAKE_FORCE * delta
				speed = max(speed, 0)
			else:
				# Accelerate backward when already moving backward
				speed += ACCELERATION * forward_input * delta
				speed = clamp(speed, -MAX_SPEED, MAX_SPEED)
		else:
			# Apply normal deceleration in both directions
			if abs(speed) > abs(min_speed):
				var deceleration = sign(speed) * DECELERATION * delta
				speed -= deceleration
				if abs(speed) < abs(deceleration):
					speed = 0.0

		# When moving backward and pressing "up", apply stronger brake force
		if forward_input > 0 and speed < 0:
			speed += BRAKE_FORCE * delta  # Stronger braking when moving backward
			speed = min(speed, 0)  # Ensure speed does not go forward

		# Handbrake
		if Input.is_action_pressed("handbrake"):
			
			if steering_input == 0:
				speed *= 0.9
				if abs(speed) < 5:
					speed = 0
			else:
			   # Drifting effect when steering and handbrake are applied
				var drift_factor = 0.98 + abs(steering_input) * 0.05  # Allow drifting without speeding up
				speed *= drift_factor  # Apply drifting deceleration to simulate sliding without accelerating

				# Apply a smaller deceleration to slow down the car gradually
				var steering_deceleration = BRAKE_FORCE * 0.1 * (1 - abs(steering_input))  # Weaker braking when steering
				speed -= steering_deceleration * delta
				
				if abs(speed) < 5:
					speed = 0  # Stop the car if it slows down too much

		# Steering logic with speed influence
		var speed_factor = clamp(1 - (abs(speed) / MAX_SPEED), 0.5, 1)
		var slippery_factor = 1 + (abs(speed) / MAX_SPEED) * 0.5  # Make steering more slippery with speed
		var target_steering = steering_input * TURN_SPEED * speed_factor * slippery_factor

		# Apply resistance to steering drift
		if steering_input == 0:
			# Slow down the steering angle to prevent drifting
			target_steering_angle = lerp_angle(target_steering_angle, rotation, delta * 5)
		else:
			target_steering_angle += target_steering * delta

		steering_angle = lerp_angle(steering_angle, target_steering_angle, TURN_SMOOTHNESS * delta)
		rotation = steering_angle

		# Move the car
		var direction = Vector2(1, 0).rotated(rotation)
		velocity = direction * speed
		move_and_slide()
