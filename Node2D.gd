extends Node2D

func _ready():

	# Save the Python script to a file
	var script_path = "res://code.py"

	# Convert the user:// path to a physical path
	var physical_script_path = ProjectSettings.globalize_path(script_path)

	# Input data for the Python script
	var input_data = "Hello from Godot!"

	# Command to run the Python script with input redirection
	var arguments = "echo " + "lol" + " | python " + physical_script_path
	var output = []
	# Execute the Python script
	var result = OS.execute("CMD.exe", ["/C", arguments], output, true)
	print(output)
	# Print the output
	for line in output:
		print(line)
