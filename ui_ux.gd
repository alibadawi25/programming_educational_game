extends Control

@onready var button = $"Mission Card/Button"
@onready var mission = $"Mission Card/nav_button/Mission"
@onready var desc = $"Mission Card/nav_button/Desc"
@onready var coins_count = $coins_count
@onready var nav_button = $NavButton
@onready var nav_button_area = $"Mission Card/nav_button"

var is_details_shown = false
var level 
func _ready():
	var file = FileAccess.open("user://data.txt", FileAccess.READ)
	if file:
		var all_lines = []  # To store all lines from the file


		# Read the rest of the file
		while not file.eof_reached():
			all_lines.append(file.get_line())  # Append each line to the list
			
		file.close()  # Always close the file when done
		level = int(all_lines[4])
		# Now you can use `all_lines` to access any part of the file later
		print("All file lines:", all_lines)
			
	else:
		print("File could not be opened.")
	
	if level == 0:
		desc.text = "Get 60$, and save your mom!"
	elif level == 1:
		desc.text = "You made it!\nStay tuned for more missions soon"

func _process(delta):
	nav_button.size.y = nav_button_area.size.y

func _on_button_pressed():
	if is_details_shown:
		button.text = "▼"
		is_details_shown = false
		nav_button.size.y=72
		desc.hide()
	else:
		button.text = "▲"
		is_details_shown = true
		desc.show()
