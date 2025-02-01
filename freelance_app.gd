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
@onready var error_dialog = $Task_submission/ErrorDialog
@onready var input_pop_up = $Task_submission/InputPopUp
@onready var line_edit = $Task_submission/InputPopUp/LineEdit

@onready var computer_screen = $"../../.."
var error_line
var id
var task
var old_content = ""
var is_vs_code_on = false
var absolute_path
var solved_tasks=[]
const CODE_FILE_PATH = "user://code.py"
const TASKS_FILE_PATH = "user://tasks.txt"

var inputs = []

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
	var tasks_path = ProjectSettings.globalize_path(TASKS_FILE_PATH)

	if FileAccess.file_exists(tasks_path):
		var file = FileAccess.open(tasks_path, FileAccess.READ)
		if file:
			while not file.eof_reached():  # Read until end of file
				var line = file.get_line().strip_edges()  # Read a line and remove whitespace
				if line != "":  # Ignore empty lines
					solved_tasks.append(int(line))
			file.close()
	
	
	for level in levels.levels:
		if level.id in solved_tasks:
			level.is_solved = true
			
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
	var error_output = ""
	var error_test_case = ""
	var error_expected_output = ""
	var is_right = false

	write_in_py_file()  # Ensure user code is written before execution

	if expected_output is String:
		var output = []
		var command = "echo | python " + absolute_path
		OS.execute("CMD.exe", ["/C", command], output, true)
		output = array_to_string(output).strip_edges()
		
		if output.to_lower() == expected_output.to_lower():
			is_right = true
		else:
			is_right = false
			error_output = output

	elif expected_output is Array:
		if task.test_cases:
			for test_case in task.test_cases:
				# Write inputs to input.txt for redirection
				var input_file_path = "input.txt"
				var file = FileAccess.open(input_file_path, FileAccess.WRITE)
				if test_case is Array:
					for input_value in test_case:
						file.store_line(str(input_value))  # Store each input on a new line
				else:
					file.store_line(str(test_case))  # Handle single input case
				file.close()

				# Execute Python script using redirected input
				var command = "python " + absolute_path + " < " + input_file_path
				var output = []
				OS.execute("CMD.exe", ["/C", command], output, true)
				output = array_to_string(output).strip_edges()

				# Validate output
				if output == expected_output[task.test_cases.find(test_case)]:
					is_right = true
				else:
					is_right = false
					error_test_case = test_case
					error_expected_output = expected_output[task.test_cases.find(test_case)]
					error_output = output
					break  # Stop on first incorrect test case

				# Delete input.txt after execution
				OS.execute("CMD.exe", ["/C", "del input.txt"], [], false)

	# Handle test case validation results
	if is_right:
		task_submission.visible = false
		accept_dialog.visible = true
		accept_dialog.dialog_text = "Congrats, you earned " + str(task.outcome) + "💲"

		# Update solved tasks file
		var levels_path = ProjectSettings.globalize_path(TASKS_FILE_PATH)
		if FileAccess.file_exists(levels_path):
			var file = FileAccess.open(levels_path, FileAccess.READ_WRITE)
			file.seek_end()
			file.store_string(str(task.id) + "\n")
			file.close()
		else:
			print("Error: Unable to open file for writing.")

		computer_screen.add_coins(task.outcome)

		# Mark level as solved
		for level in levels.levels:
			if level["id"] == task.id:
				level["is_solved"] = true
				load_levels()

		accept_dialog.popup_centered()
		accept_dialog.position[1] -= 60
	else:
		print(error_output)

		if "echo" in error_output.to_lower():
			command_line.text = ""
		elif "error" in error_output.to_lower():
			if "EOFError: EOF when reading a line" in error_output:
				command_line.text = "The Task Requires "+str(error_test_case.size())+" inputs only!"
			else:
				command_line.text = error_output
		elif "is not" in error_output:
			error_dialog.dialog_text = "Python is not installed on your device!\nPlease install it first."
			error_dialog.visible = true
		else:
			command_line.text = "For test case \"" + array_to_string(error_test_case) + "\" you should have outputted \"" + str(error_expected_output) + "\" but instead you outputted \"" + str(error_output) + "\"."

func _on_file_selected(path):
	var output = []
	var command = "python " + path
	OS.execute("CMD.exe", ["/C", command], output)
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
	command_line.text = ""
	var command = ""
	
	var input_file_path = "input.txt"
	var file = FileAccess.open(input_file_path, FileAccess.WRITE)
	for input_value in inputs:
		file.store_line(str(input_value))  # Store each input on a new line
	file.close()

	# Redirect input.txt to Python
	command = "python " + absolute_path + " < " + input_file_path

	var output = []
	write_in_py_file()  # Ensure the user's code is written before execution
	
	OS.execute("CMD.exe", ["/C", command], output, true)

	var output_str = array_to_string(output)

	if "error" in output_str.to_lower():
		if "EOFError: EOF when reading a line" not in output_str:
			command_line.text = output_str
			inputs.clear()
			command = ""
		else:
			input_pop_up.show()
	elif "is not" in output_str.to_lower():
		error_dialog.dialog_text = "Python is not installed on your device!\nPlease install it first."
		error_dialog.visible = true
	else:
		command_line.text = output_str.replace("\r\n", "\n")  # Normalize newlines
		inputs.clear()
		command = ""

	# Clean up input file after execution
	OS.execute("CMD.exe", ["/C", "del input.txt"], [], false)



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
		s += str(i)
	return s

func _on_vs_code_pressed():
	open_vscode()

func open_vscode():
	is_vs_code_on = true
	# You can open a specific file or the whole project folder.

	var command = "code" + " " + absolute_path  # Command to open VS Code with the project folder
	var output = []
	write_in_py_file()
	OS.execute("CMD.exe", ["/C", command], output, true)
	if "is not" in array_to_string(output):
		is_vs_code_on = false
		error_dialog.dialog_text = "Visual Studio Code is not downloaded on your device!\nPlease download it first if you want to use this feature."
		error_dialog.visible = true



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
	var title = task_objects[3].get_node("Button/Label").text
	for level in levels.levels:
		if level["title"] == title:
			id = level["id"]
			task = level
			_on_task_button_pressed()


func _on_input_pop_up_confirmed():
	inputs.append(line_edit.text)
	line_edit.clear()
	_on_run_pressed()
