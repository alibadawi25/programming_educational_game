extends CharacterBody2D

@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var animated_sprite_2d_2 = $AnimatedSprite2D2
@onready var animated_sprite_2d_3 = $AnimatedSprite2D3
@onready var animated_sprite_2d_4 = $AnimatedSprite2D4
@onready var animated_sprite_2d_5 = $AnimatedSprite2D5
@onready var animated_sprite_2d_6 = $AnimatedSprite2D6
const SPEED = 200.0

func _physics_process(delta):
	# Get the input direction
	var input_vector = Vector2(
		Input.get_axis("ui_left", "ui_right"),
		Input.get_axis("ui_up", "ui_down")
	).normalized()

	# Set velocity based on input
	velocity = input_vector * SPEED

	# Update animation based on movement
	if input_vector.length() > 0:
		# Determine direction and play corresponding animation
		if abs(input_vector.x) > abs(input_vector.y):
			if input_vector.x > 0:
				set_animation("walk")
				animated_sprite_2d.flip_h = false
				animated_sprite_2d_2.flip_h = false
				animated_sprite_2d_3.flip_h = false
				animated_sprite_2d_4.flip_h = false
				animated_sprite_2d_5.flip_h = false
				animated_sprite_2d_6.flip_h = false
			else:
				set_animation("walk")
				animated_sprite_2d.flip_h = true
				animated_sprite_2d_2.flip_h = true
				animated_sprite_2d_3.flip_h = true
				animated_sprite_2d_4.flip_h = true
				animated_sprite_2d_5.flip_h = true
				animated_sprite_2d_6.flip_h = true
				
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

func set_animation(animation_name):
	# Play the given animation on all animated sprites
	animated_sprite_2d.animation = animation_name
	animated_sprite_2d_2.animation = animation_name
	animated_sprite_2d_3.animation = animation_name
	animated_sprite_2d_4.animation = animation_name
	animated_sprite_2d_5.animation = animation_name
	animated_sprite_2d_6.animation = animation_name

	animated_sprite_2d.play()
	animated_sprite_2d_2.play()
	animated_sprite_2d_3.play()
	animated_sprite_2d_4.play()
	animated_sprite_2d_5.play()
	animated_sprite_2d_6.play()



