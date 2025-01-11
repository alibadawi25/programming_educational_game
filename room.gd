extends Node2D

@onready var label = $"./Area2D/Label"
@onready var camera_2d = $Player/Camera2D
@onready var player = $Player
@onready var coins_label = $Player/Camera2D/Label

var canTurnLapOn = false

func _ready():
	update_label_position()
	label.visible = false  # Ensure the label is initially hidden
	var file = FileAccess.open("user://data.txt", FileAccess.READ)
	if file:
		var first_line = file.get_line()  # Reads the first line
		var coordinates = first_line.split(" ")
		player.position.x = int(coordinates[0])
		player.position.y = int(coordinates[1])
		file.close()  # Always close the file when done
	else:
		print("File could not be opened.")


func _process(delta):
	#print(coins_label.position)
	#print(player.position)
	#print(player.position + coins_label.position)
	update_label_position()
	if canTurnLapOn and Input.is_action_just_pressed("P"):  # "ui_select" is mapped to "P" by default in Input Map
		var player_x = player.position.x
		var player_y = player.position.y
		var coordinates = str(player_x) + " " + str(player_y)
		var file = FileAccess.open("user://data.txt", FileAccess.WRITE)
		if file:
			file.store_line(coordinates)  # This will overwrite the file content
			file.close()  # Always close the file when done
		else:
			print("Failed to open file.")
		get_tree().change_scene_to_file("res://computer_screen.tscn")

	if Input.is_action_just_pressed("exit"):
		var coordinates = "800 400"
		var file = FileAccess.open("user://data.txt", FileAccess.WRITE)
		if file:
			file.store_line(coordinates)  # This will overwrite the file content
			file.close()  # Always close the file when done
		else:
			print("Failed to open file.")
		get_tree().quit()

func update_label_position():
	coins_label.position.x = 175
	if (coins_label.position.x+player.position.x) > 1191:
		coins_label.position.x += floor((1016-(player.position.x))/1.6)
	elif (coins_label.position.x+player.position.x) <= 1191:
		coins_label.position.x = 175
func _on_area_2d_body_entered(body):
	if body.name == "Player":
		label.visible = true
		canTurnLapOn = true

func _on_area_2d_body_exited(body):
	if body.name == "Player":
		label.visible = false
		canTurnLapOn = false


func _on_area_2d_2_body_entered(body):
	if body.name == "Player":
		print("going out of the room")
