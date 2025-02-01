extends CharacterBody2D

@onready var animated_sprite_2d = $AnimatedSprite2D

@onready var room = $"../"
var speed = 200

func _physics_process(delta):
	if not room.paused:
		# Get the input direction
		var input_vector = Vector2(
			Input.get_axis("ui_left", "ui_right"),
			Input.get_axis("ui_up", "ui_down")
		).normalized()

		# Set velocity based on input
		velocity = input_vector * speed

		# Update animation based on movement
		if input_vector.length() > 0:
			# Determine direction and play corresponding animation
			if abs(input_vector.x) > abs(input_vector.y):
				if input_vector.x > 0:
					set_animation("walk")
					animated_sprite_2d.flip_h = false
				else:
					set_animation("walk")
					animated_sprite_2d.flip_h = true
					
			else:
				if input_vector.y > 0:
					set_animation("walk")
				else:
					set_animation("walk")
		else:
			# No movement: set idle animation
			set_animation("idle")

		# Move the character
		move_and_slide()
	else:
		# No movement: set idle animation
		set_animation("idle")

func set_animation(animation_name):
	# Play the given animation on all animated sprites
	animated_sprite_2d.animation = animation_name
	animated_sprite_2d.play()


func set_speed(new_speed):
	speed = new_speed
