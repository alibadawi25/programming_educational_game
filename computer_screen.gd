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

const CODE = preload("res://code.tres")
var old_content = ""
var isLoading = true
var time_accumulator = 0.0
var loading_time = 1.0 
var is_vs_code_on = false

func _ready():
	
	for keyword in BOOL_KEYWORDS:
		CODE.add_keyword_color(keyword, Color(0, 0.49, 0.176))
	for keyword in CONTROL_FLOW_KEYWORDS:
		CODE.add_keyword_color(keyword, Color(0, 0.49, 0.761))
	for keyword in LOGICAL_OPERATORS:
		CODE.add_keyword_color(keyword, Color(0, 0.271, 0.243))
	CODE.add_color_region('"','"', Color(0.714, 0.698, 0.878))
	CODE.add_color_region("'","'", Color(0.714, 0.698, 0.878))
	CODE.add_color_region('#','', Color(0.62, 0.62, 0.62))
	var file = FileAccess.open("res://code.py", FileAccess.WRITE)
	if file:
		var content = ""
		file.store_string(content)
		file.close()
		print("Content successfully written to file: ", "res://code.py")
	else:
		print("Error: Unable to open file for writing at ", "res://code.py")

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
			
	if Input.is_action_just_pressed("exit"):
		var coordinates = "768 184"
		var file = FileAccess.open("user://data.txt", FileAccess.WRITE)
		if file:
			file.store_line(coordinates)  # This will overwrite the file content
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


func _on_power_off_pressed():
	get_tree().change_scene_to_file("res://room.tscn")
