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
var id
var task
var old_content = ""
var is_vs_code_on = false

func _ready():
	load_levels()
	# Initialize app state
	freelancing_home.visible = true
	freelancing_tasks.visible = false
	task_submission.visible = false

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
	if Input.is_action_just_pressed("exit"):
		get_tree().quit()

func _on_advance_button_pressed():
	freelancing_tasks.visible = true

func _on_task_button_pressed():
	code_edit.text = ""
	write_in_py_file()
	is_vs_code_on = false
	task_submission.visible = true
	title.text = task.title

func _on_submit_button_pressed():
	check_code()


func check_code():
	var expected_output = task.expected_outputs
	print(expected_output)
	var path = "C:\\Users\\aliba\\OneDrive\\Documents\\ProgrammingEducationalGame\\code.py"
	var is_right = false
	if expected_output is String:
		var output = []
		var command = "python " + path
		write_in_py_file()
		OS.execute("CMD.exe", ["/C", command], output, true)
		output = array_to_string(output)
		if output.to_lower().trim_suffix("\r\n") == expected_output.to_lower():
			is_right = true
	elif expected_output is Array:
		if task.test_cases:
			for test_case in task.test_cases:
				if test_case is Array:
					print("3lol")
				elif test_case is String:
					var command = "echo " + test_case + " | python " + path
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
							break
	if is_right:
		task_submission.visible = false
		accept_dialog.visible = true
		accept_dialog.dialog_text = "Congrats, you earned " + str(task.outcome) + "💲"
		for level in levels.levels:
			if level["id"] == task.id:
				level["is_solved"] = true
				load_levels()
		accept_dialog.popup_centered() 
		accept_dialog.position[1] -= 60

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
	#var temp_file_path = "user://temp_file.py"
#
	#var physical_path = ProjectSettings.globalize_path(temp_file_path)
#
	#var temp_file = FileAccess.open(temp_file_path, FileAccess.WRITE)
	#temp_file.store_string(code)
	#temp_file.close()
#
	#var output = []
	#var result = OS.execute("python", [physical_path], output, true)
	#print(array_to_string(output))
#
	#if "^" in array_to_string(output):
		#var error_line = int(array_to_string(output).split("\n")[-5].split(" ")[5].strip_edges().rstrip(","))
		#if code.split("\n").size() > error_line:
			#error_highlighter.visible = true
			#error_highlighter.position.y = 4 + (28 * (error_line - 1))
	#elif "Error" in array_to_string(output):
		#var error_line = int(array_to_string(output).split("\n")[-4].split(" ")[5].strip_edges().rstrip(","))
		#if code.split("\n").size() > error_line:
			#error_highlighter.visible = true
			#error_highlighter.position.y = 4 + (29 * (error_line - 1))

func _on_run_pressed():
	var path = "C:\\Users\\aliba\\OneDrive\\Documents\\ProgrammingEducationalGame\\code.py"
	var command = "python " + path
	var output = []
	write_in_py_file()
	OS.execute("CMD.exe", ["/C", command], output, true)
	command_line.text = array_to_string(output)

func write_in_py_file():
	old_content = code_edit.text
	var file = FileAccess.open("res://code.py", FileAccess.WRITE)
	if file:
		file.store_string(code_edit.text)
		file.close()
	else:
		print("Error: Unable to open file for writing.")

func read_py_file_and_update():
	var file = FileAccess.open("res://code.py", FileAccess.READ)
	if file:
		var content = file.get_as_text()
		file.close()
		code_edit.text = content
	else:
		print("Error: Unable to open file for reading at ", "res://code.py")

func read_py_file():
	var file = FileAccess.open("res://code.py", FileAccess.READ)
	if file:
		var content = file.get_as_text()
		file.close()
		if content != old_content:
			is_vs_code_on = true
			old_content = content
	else:
		print("Error: Unable to open file for reading at ", "res://code.py")


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
	var project_path = ProjectSettings.globalize_path("res://code.py")  # Path to the Godot project
	var command = "code" + " " + project_path  # Command to open VS Code with the project folder
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
