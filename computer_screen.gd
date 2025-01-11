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

var isLoading = true
var time_accumulator = 0.0
var loading_time = 1.0 

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


func _on_vs_code_pressed():
	open_vscode()

func open_vscode():
	# You can open a specific file or the whole project folder.
	var project_path = ProjectSettings.globalize_path("res://code.py")  # Path to the Godot project
	var command = "code" + " " + project_path  # Command to open VS Code with the project folder
	var output = []
	var clear_command = "type nul > " + project_path
	OS.execute("CMD.exe", ["/C", clear_command], [])
	OS.execute("CMD.exe", ["/C", command], output)


func _on_advance_button_pressed():
	freelancing_tasks.visible = true


func _on_submit_button_pressed():
	file_dialog.visible = true
	file_dialog.current_file = "code.py"
	file_dialog.popup_centered() 

func _on_file_selected(path):
	var output = []
	var command = "python " + path
	OS.execute("CMD.exe", ["/C", command], output)
	print(output)
	if array_to_string(output).to_lower() == "hello world\r\n":
		task_submission.visible = false
		accept_dialog.visible
		accept_dialog.popup_centered() 
		accept_dialog.position[1]=accept_dialog.position[1]-60

func array_to_string(arr: Array) -> String:
	var s = ""
	for i in arr:
		s += String(i)
	return s


func _on_cashing_app_pressed():
	apps_buttons.visible = false
	freelance_app.visible = true
	apps.visible = true


func _on_task_button_pressed():
	task_submission.visible = true


func _on_close_button_pressed():
	if freelance_app.visible:
		freelance_app.visible = false
		freelancing_home.visible = true
		apps.visible = false
		apps_buttons.visible = true
	elif youtube.visible:
		youtube.visible = false
		apps.visible = false
		apps_buttons.visible = true


func _on_power_off_pressed():
	get_tree().change_scene_to_file("res://room.tscn")
