extends Node2D

const DATA_FILE_PATH = "user://data.txt"
const INITIAL_DATA = "800 400\ntrue\nfalse\n0\n"  # Initial data

# Called when the node enters the scene tree for the first time.
func _ready():
	initialize_data_file()

# Check if data.txt exists, else create and initialize it
func initialize_data_file():
	var absolute_path = ProjectSettings.globalize_path(DATA_FILE_PATH)  # Convert to real path
	if not FileAccess.file_exists(absolute_path):
		var file = FileAccess.open(absolute_path, FileAccess.WRITE)
		file.store_string(INITIAL_DATA)  # You can change this to default content
		file.close()
		print("data.txt initialized")
	else:
		print("data.txt already exists")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_quit_pressed():
	get_tree().quit()

func _on_play_pressed():
	get_tree().change_scene_to_file("res://room.tscn")
