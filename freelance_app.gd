extends Node2D

@onready var freelancing_tasks = $freelancing_tasks
@onready var task_submission = $Task_submission
@onready var freelancing_home = $freelancing_home
@onready var code_edit = $Task_submission/CodeEdit
@onready var error_highlighter = $Task_submission/CodeEdit/error_highlighter
@onready var command_line = $Task_submission/command_line
@onready var accept_dialog = $Task_submission/AcceptDialog
@onready var file_dialog = $Task_submission/FileDialog
@onready var levels = $Task_submission/levels
@onready var task_objects = [
	$freelancing_tasks/task_object,
	$freelancing_tasks/task_object2,
	$freelancing_tasks/task_object3,
	$freelancing_tasks/task_object4
]
@onready var title = $Task_submission/Title
@onready var description = $Task_submission/Description
@onready var computer_screen = $"../../.."
var error_line
var id
var task
var old_content = ""
var is_vs_code_on = false
var absolute_path
const CODE_FILE_PATH = "user://code.py"

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

func _ready():
	absolute_path = ProjectSettings.globalize_path(CODE_FILE_PATH)  # Convert to real path
	initialize_code_file()
	for keyword in BOOL_KEYWORDS:
		CODE.add_keyword_color(keyword, Color(0, 0.49, 0.176))
	for keyword in CONTROL_FLOW_KEYWORDS:
		CODE.add_keyword_color(keyword, Color(0, 0.49, 0.761))
	for keyword in LOGICAL_OPERATORS:
		CODE.add_keyword_color(keyword, Color(0, 0.271, 0.243))
	CODE.add_color_region('"','"', Color(0.714, 0.698, 0.878))
	CODE.add_color_region("'","'", Color(0.714, 0.698, 0.878))
	CODE.add_color_region('#','', Color(0.62, 0.62, 0.62))
	load_levels()
	# Initialize app state
	freelancing_home.visible = true
	freelancing_tasks.visible = false
	task_submission.visible = false

func initialize_code_file():
	if not FileAccess.file_exists(absolute_path):
		var file = FileAccess.open(absolute_path, FileAccess.WRITE)
		file.store_string("")
		file.close()

func load_levels():
	clear_task_objects()
	for level in levels.levels:
		if not level.is_solved:
			for task in task_objects:
				if task.get_node("Button/Label").text == "":
					task.get_node("Button/Label").text = level.title
					task.get_node("Button/Label2").text = str(level.outcome) + "💲"
					break
					
	for task in task_objects:
		if task.get_node("Button/Label").text == "":
			task.visible = false

func clear_task_objects():
	for task in task_objects:
		task.get_node("Button/Label").text = ""
		task.get_node("Button/Label2").text = ""

func _process(delta):
	print(error_highlighter.position.y)
	read_py_file()
	if is_vs_code_on:
		read_py_file_and_update()

func _on_advance_button_pressed():
	freelancing_tasks.visible = true

func _on_task_button_pressed():
	code_edit.text = ""
	write_in_py_file()
	is_vs_code_on = false
	task_submission.visible = true
	title.text = task.title
	description.text = task.description

func _on_submit_button_pressed():
	check_code()


func check_code():
	var expected_output = task.expected_outputs
	print(expected_output)
	var error_output = ""
	var is_right = false
	if expected_output is String:
		var output = []
		var command = "python " + absolute_path
		write_in_py_file()
		OS.execute("CMD.exe", ["/C", command], output, true)
		output = array_to_string(output)
		if output.to_lower().trim_suffix("\r\n") == expected_output.to_lower():
			is_right = true
		else:
			is_right = false
			error_output = output
	elif expected_output is Array:
		if task.test_cases:
			for test_case in task.test_cases:
				if test_case is Array:
					for case in test_case:
						var command = "("
						for input in test_case:
							command += "echo " + str(input) + " & "
						command = command.substr(0, command.length() - 2)
						command += ")" + " | python " + absolute_path
						write_in_py_file()
						var output = []
						OS.execute("CMD.exe", ["/C", command], output, true)
						output = int(array_to_string(output))
						if output == expected_output[task.test_cases.find(test_case)]:
							is_right = true
						else:
							is_right = false
							error_output = output
							break
						print("3lol")
				elif test_case is String:
					var command = "echo " + test_case + " | python " + absolute_path
					write_in_py_file()
					var output = []
					OS.execute("CMD.exe", ["/C", command], output, true)
					print(expected_output[task.test_cases.find(test_case)].to_lower())
					output = array_to_string(output)
					if output:
						print(output.to_lower().trim_suffix(" \r\n"))
						if output.to_lower().trim_suffix(" \r\n") == expected_output[task.test_cases.find(test_case)].to_lower():
							is_right = true
						else:
							is_right = false
							error_output = output
							break
	elif expected_output is int:
		if task.test_cases:
			for test_case in task.test_cases:
				if test_case is Array:
					pass
	if is_right:
		task_submission.visible = false
		accept_dialog.visible = true
		accept_dialog.dialog_text = "Congrats, you earned " + str(task.outcome) + "💲"
		computer_screen.add_coins(task.outcome)
		for level in levels.levels:
			if level["id"] == task.id:
				level["is_solved"] = true
				load_levels()
		accept_dialog.popup_centered() 
		accept_dialog.position[1] -= 60
	else:
		command_line.text = error_output
		

func _on_file_selected(path):
	var output = []
	var command = "python " + path
	OS.execute("CMD.exe", ["/C", command], output)
	print(output)
	if array_to_string(output).to_lower() == "hello world\r\n":
		task_submission.visible = false
		accept_dialog.visible = true
		accept_dialog.popup_centered()
		accept_dialog.position[1] -= 60

func _on_close_button_pressed():
	if freelancing_home.visible:
		freelancing_home.visible = false
		freelancing_tasks.visible = false
		task_submission.visible = false
	elif freelancing_tasks.visible:
		freelancing_tasks.visible = false
		freelancing_home.visible = true
	elif task_submission.visible:
		task_submission.visible = false
		freelancing_home.visible = true

#func _on_code_edit_text_changed():
	#if error_highlighter.visible:
		#error_highlighter.visible = false
	#var code = code_edit.text
#
	#var temp_file_path = "user://temp_file.py"
#
	#var physical_path = ProjectSettings.globalize_path(temp_file_path)
#
	#var temp_file = FileAccess.open(temp_file_path, FileAccess.WRITE)
	#temp_file.store_string(code)
	#temp_file.close()
	#
	#var syntax_analyzer_path = "user://syntax_testing.py"
	#var syntax_analyzer_physical_path = ProjectSettings.globalize_path(syntax_analyzer_path)
	#var output = []
	#
	#var result = OS.execute("python", [syntax_analyzer_physical_path], output, true)
	#print(array_to_string(output))
	#print(array_to_string(output).split("\n")[0].split(" ")[-1])
	#if array_to_string(output):
		#error_line = int(array_to_string(output).split("\n")[0].split(" ")[-1])
		#if code.split("\n").size() > error_line:
			#error_highlighter.visible = true
			#error_highlighter.position.y = 4 + (29 * (error_line - 1))


func _on_run_pressed():
	var command = "python " + absolute_path
	print(absolute_path)
	var output = []
	write_in_py_file()
	OS.execute("CMD.exe", ["/C", command], output, true)
	command_line.text = array_to_string(output)

func write_in_py_file():
	old_content = code_edit.text
	var file = FileAccess.open(absolute_path, FileAccess.WRITE)
	if file:
		file.store_string(code_edit.text)
		file.close()
	else:
		print("Error: Unable to open file for writing.")

func read_py_file_and_update():
	var file = FileAccess.open(absolute_path, FileAccess.READ)
	if file:
		var content = file.get_as_text()
		file.close()
		code_edit.text = content
	else:
		print("Error: Unable to open file for reading at ", absolute_path)

func read_py_file():
	var file = FileAccess.open(absolute_path, FileAccess.READ)
	if file:
		var content = file.get_as_text()
		file.close()
		if content != old_content:
			is_vs_code_on = true
			old_content = content
	else:
		print("Error: Unable to open file for reading at ", absolute_path)


func array_to_string(arr: Array) -> String:
	var s = ""
	for i in arr:
		s += String(i)
	return s

func _on_vs_code_pressed():
	open_vscode()

func open_vscode():
	is_vs_code_on = true
	# You can open a specific file or the whole project folder.

	var command = "code" + " " + absolute_path  # Command to open VS Code with the project folder
	var output = []
	write_in_py_file()
	OS.execute("CMD.exe", ["/C", command], output)


func _on_code_edit_mouse_entered():
	is_vs_code_on = false


func _on_task_1_pressed():
	var title = task_objects[0].get_node("Button/Label").text
	for level in levels.levels:
		if level["title"] == title:
			id = level["id"]
			task = level
			_on_task_button_pressed()


func _on_task_2_pressed():
	var title = task_objects[1].get_node("Button/Label").text
	for level in levels.levels:
		if level["title"] == title:
			id = level["id"]
			task = level
			_on_task_button_pressed()


func _on_task_3_pressed():
	var title = task_objects[2].get_node("Button/Label").text
	for level in levels.levels:
		if level["title"] == title:
			id = level["id"]
			task = level
			_on_task_button_pressed()


func _on_task_4_pressed():
	pass # Replace with function body.
