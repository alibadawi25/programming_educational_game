extends Node2D

# Array of textures
var textures = []

var value = null

@export var current_texture_index : int = 0
@export var input_node : Node2D
@export var input_2_node : Node2D
@export var editable : bool = true

@onready var sprite = $TextureRect
@onready var button = $Button

func _ready():
	# Add the textures to the array
	textures.append(null)  # No gate
	textures.append(load("res://And-Gate.png"))  # AND
	textures.append(load("res://Or-Gate.png"))   # OR
	textures.append(load("res://Not-Gate.png"))  # NOT
	
	# Set the initial texture
	sprite.texture = textures[current_texture_index]
	update_value()

func _process(delta):
	update_value()

# Function to safely update the gate's output value
func update_value():
	if input_node != null and input_2_node != null:
		if current_texture_index == 1:
			value = input_node.value and input_2_node.value
		elif current_texture_index == 2:
			value = input_node.value or input_2_node.value
		elif current_texture_index == 3:
			value = not input_node.value
		else:
			value = null
	else:
		value = null

# Function to handle the button press and switch textures
func _on_Button_pressed():
	if editable:
		var previous_texture_index = current_texture_index  # Store the old gate type
		var new_texture_index = current_texture_index

		# Loop until we find a valid gate
		for i in range(textures.size() - 1):  # Avoid infinite loop if all are empty
			new_texture_index = (new_texture_index + 1) % textures.size()

			# Check if the new texture is valid
			if (new_texture_index == 0 or  # No gate is always valid
				(new_texture_index == 1 and Inventory.and_gate_count > 0) or
				(new_texture_index == 2 and Inventory.or_gate_count > 0) or
				(new_texture_index == 3 and Inventory.not_gate_count > 0)):
				break  # Found a valid gate, exit loop
		
		# Restore the previous gate to inventory
		if previous_texture_index == 1:
			Inventory.and_gate_count += 1
		elif previous_texture_index == 2:
			Inventory.or_gate_count += 1
		elif previous_texture_index == 3:
			Inventory.not_gate_count += 1

		# Subtract from inventory for the new gate
		if new_texture_index == 1:
			Inventory.and_gate_count -= 1
		elif new_texture_index == 2:
			Inventory.or_gate_count -= 1
		elif new_texture_index == 3:
			Inventory.not_gate_count -= 1

		# Change texture
		current_texture_index = new_texture_index
		sprite.texture = textures[current_texture_index]

