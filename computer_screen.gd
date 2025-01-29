extends Node2D  

@onready var loading = $screen/loading
@onready var apps_buttons = $screen/AppsButtons
@onready var line_edit = $screen/Apps/Youtube/Header/ColorRect/LineEdit
@onready var youtube = $screen/Apps/Youtube
@onready var file_dialog = $screen/Apps/freelance_app/Task_submission/FileDialog
@onready var accept_dialog = $screen/Apps/freelance_app/Task_submission/AcceptDialog
@onready var freelance_app = $screen/Apps/freelance_app
@onready var freelancing_tasks = $screen/Apps/freelance_app/freelancing_tasks
@onready var task_submission = $screen/Apps/freelance_app/Task_submission
@onready var freelancing_home = $screen/Apps/freelance_app/freelancing_home
@onready var apps = $screen/Apps
@onready var code_edit = $screen/Apps/freelance_app/Task_submission/CodeEdit
@onready var error_dialog = $screen/Apps/freelance_app/Task_submission/ErrorDialog
@onready var error_highlighter = $screen/Apps/freelance_app/Task_submission/CodeEdit/error_highlighter
@onready var command_line = $screen/Apps/freelance_app/Task_submission/command_line
@onready var levels = $screen/Apps/freelance_app/Task_submission/levels
@onready var bank = $screen/Apps/bank
@onready var cash = $screen/Apps/bank/cash
@onready var tutorial = $screen/Tutorial
@onready var utube_button = $screen/AppsButtons/utube
@onready var cashing_app_button = $screen/AppsButtons/cashing_app
@onready var bank_button = $screen/AppsButtons/bank
@onready var power_off_button = $screen/AppsButtons/power_off

# Boolean-related keywords in Python
const BOOL_KEYWORDS = [
	"True", "False", "None"
]

# Logical operators in Python
const LOGICAL_OPERATORS = [
	"and", "or", "not"
]

# Control flow keywords in Python
const CONTROL_FLOW_KEYWORDS = [
	"if", "elif", "else", "for", "while", "continue", "break", "pass", 
	"return", "raise", "try", "except", "finally"
]

# Data handling and special keywords in Python
const DATA_KEYWORDS = [
	"None", "lambda", "yield", "del"
]

# Definition-related keywords in Python
const DEFINITION_KEYWORDS = [
	"def", "class", "global", "nonlocal", "import", "as"
]

# Async programming keywords in Python
const ASYNC_KEYWORDS = [
	"async", "await"
]
var absolute_path
const CODE_FILE_PATH = "user://code.py"
const CODE = preload("res://code.tres")
var coordinates
var coins
var old_content = ""
var isLoading = true
var time_accumulator = 0.0
var loading_time = 1.0 
var is_vs_code_on = false
var is_tutorial = false
func _ready():
	absolute_path = ProjectSettings.globalize_path(CODE_FILE_PATH)  # Convert to real path
	for keyword in BOOL_KEYWORDS:
		CODE.add_keyword_color(keyword, Color(0, 0.49, 0.176))
	for keyword in CONTROL_FLOW_KEYWORDS:
		CODE.add_keyword_color(keyword, Color(0, 0.49, 0.761))
	for keyword in LOGICAL_OPERATORS:
		CODE.add_keyword_color(keyword, Color(0, 0.271, 0.243))
	CODE.add_color_region('"','"', Color(0.714, 0.698, 0.878))
	CODE.add_color_region("'","'", Color(0.714, 0.698, 0.878))
	CODE.add_color_region('#','', Color(0.62, 0.62, 0.62))
	var file = FileAccess.open(absolute_path, FileAccess.WRITE)
	if file:
		var content = ""
		file.store_string(content)
		file.close()
		print("Content successfully written to file: ", absolute_path)
	else:
		print("Error: Unable to open file for writing at ", absolute_path)
	
	var file2 = FileAccess.open("user://data.txt", FileAccess.READ)
	if file2:
		var all_lines = []  # To store all lines from the file
		# Read the rest of the file
		while not file2.eof_reached():
			all_lines.append(file2.get_line())  # Append each line to the list
		file2.close()  # Always close the file when done
		coordinates = all_lines[0]
		is_tutorial = string_to_bool(all_lines[2])
		coins = int(all_lines[3])
		cash.text = str(coins) + "💲" 
		# Now you can use `all_lines` to access any part of the file later
		print("All file lines:", all_lines)
			
	else:
		print("File could not be opened.")

func _process(delta):
	if line_edit.text != "":
		line_edit.clear_button_enabled = true
	else:
		line_edit.clear_button_enabled = false
	if isLoading:
		time_accumulator += delta
		if time_accumulator >= 0.1: 
			loading.rotate(0.0872665)  
			time_accumulator -= 0.1
		loading_time -= delta
		if loading_time <= 0:
			isLoading = false  
			loading.visible = false
			apps_buttons.visible = true
			if is_tutorial:
				tutorial.visible = true
				utube_button.disabled = true
				bank_button.disabled = true
				power_off_button.disabled = true
			
			
	if Input.is_action_just_pressed("exit"):
		var coordinates = "800 400"
		var file = FileAccess.open("user://data.txt", FileAccess.WRITE)
		var filedata = coordinates + "\n" + "false"  + "\n" + str(is_tutorial) + "\n" + str(coins)
		if file:
			file.store_line(filedata)  # This will overwrite the file content
			file.close()  # Always close the file when done
		else:
			print("Failed to open file.")
		get_tree().quit()

func _on_utube_pressed():
	apps_buttons.visible = false
	apps.visible = true
	youtube.visible = true
	youtube.clear_videos()
	youtube.load_videos(youtube.links)

func array_to_string(arr: Array) -> String:
	var s = ""
	for i in arr:
		s += String(i)
	return s


func _on_cashing_app_pressed():
	if is_tutorial:
		is_tutorial = false
		tutorial.visible = false
		utube_button.disabled = false
		bank_button.disabled = false
		power_off_button.disabled = false
	apps_buttons.visible = false
	freelance_app.visible = true
	apps.visible = true


func _on_close_button_pressed():
	if freelance_app.visible:
		freelance_app.visible = false
		freelancing_home.visible = true
		freelancing_tasks.visible = false
		task_submission.visible = false
		apps.visible = false
		apps_buttons.visible = true
	elif youtube.visible:
		youtube.visible = false
		apps.visible = false
		apps_buttons.visible = true
	elif bank.visible:
		bank.visible = false
		apps.visible = false
		apps_buttons.visible = true


func _on_power_off_pressed():
	var file = FileAccess.open("user://data.txt", FileAccess.WRITE)
	var filedata = coordinates + "\n" + "false"  + "\n" + str(is_tutorial) + "\n" + str(coins)
	if file:
		file.store_line(filedata)  # This will overwrite the file content
		file.close()  # Always close the file when done
	else:
		print("Failed to open file.")
	get_tree().change_scene_to_file("res://room.tscn")


func _on_bank_pressed():
	apps_buttons.visible = false
	bank.visible = true
	apps.visible = true

func add_coins(added_coins):
	coins += added_coins
	cash.text = str(coins) + "💲" 


func string_to_bool(input: String) -> bool:
	input = input.strip_edges().to_lower()
	return input == "true" or input == "1"
