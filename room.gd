extends Node2D

@onready var label = $"./Area2D/Label"
@onready var camera_2d = $Player/Camera2D
@onready var player = $Player
@onready var coins_label = $Player/Camera2D/Label
@onready var leave_label = $door/Label
@onready var camera = $Camera2D
@onready var panel = $Panel
@onready var me = $Panel/Dialogue1/Me
@onready var doc = $Panel/Dialogue1/Doc
@onready var proceed = $Panel/Dialogue1/Proceed
@onready var skip = $Panel/Dialogue1/Skip
@onready var dialogue_dr = $Panel/Dialogue1/Dialogue_dr
@onready var dialogue_me = $Panel/Dialogue1/Dialogue_me
@onready var timer = $Panel/Dialogue1/Timer
@onready var dialogue_separate_time = $Panel/Dialogue1/dialogue_separate_time
@onready var tutorial = $Tutorial
@onready var tutorial_collision = $Tutorial/StaticBody2D
@onready var halal_music = $Halal_music
@onready var ui_ux = $UI_UX_Canvas/UI_UX
@onready var mob_area = $Mob_Area
@onready var door = $door
@onready var line_2d = $Line2D
@onready var meet_me_outside_dialogue = $Mob_Area/meet_me_outside_dialogue
@onready var meet_me_outside_label = $Mob_Area/meet_me_outside_label

var dialogue_dr_finished = false
var dialogue_me_finished = false
var can_leave_room = false
var canTurnLapOn = false
var is_first_time_playing
var paused = false
var start_dialogue = false
var start_doc = false
var timer_started = false
var doc_timer_started = false
var is_tutorial = false
var did_dialogue1_start = false
var did_dialogue2_start = false
var is_meet_me = false
var coins
var level
var level_part
var required_coins


func _ready():
	camera_2d.zoom = Vector2(1.2, 1.2)
	camera_2d.limit_left = -20
	camera_2d.limit_right = 1620
	camera_2d.limit_bottom = 1222
	camera_2d.limit_top = -24
	label.visible = false  # Ensure the label is initially hidden
	var file = FileAccess.open("user://data.txt", FileAccess.READ)
	if file:
		var all_lines = []  # To store all lines from the file


		# Read the rest of the file
		while not file.eof_reached():
			all_lines.append(file.get_line())  # Append each line to the list
			
		var first_line = all_lines[0]  # Reads the first line
		var coordinates = first_line.split(" ")
		player.position.x = int(coordinates[0])
		player.position.y = int(coordinates[1])
		file.close()  # Always close the file when done
		is_first_time_playing = string_to_bool(all_lines[1])
		coins = int(all_lines[3])
		level = int(all_lines[4])
		level_part = int(all_lines[5])
		# Now you can use `all_lines` to access any part of the file later
		print("All file lines:", all_lines)
		if not is_first_time_playing:
			ui_ux.show()
			camera.queue_free()
			tutorial_collision.queue_free()
	else:
		print("File could not be opened.")
	ui_ux.coins_count.text = str(coins)+"💲"


func _process(delta):
	ui_ux.coins_count.text = str(coins)+"💲"
	if is_first_time_playing:
		paused = true
		panel.visible = true
		skip.visible = true
		is_tutorial = true
		if not timer_started:
			timer.start()
			timer_started = true
		if start_dialogue:
			MusicManager.set_volume(50)
			me.visible = true
			if not dialogue_me.playing and not dialogue_me_finished and not did_dialogue1_start:
				did_dialogue1_start = true
				dialogue_me.play()
			if not doc_timer_started and not dialogue_dr.playing and dialogue_me_finished and not dialogue_dr_finished:
				dialogue_separate_time.start()
				doc_timer_started = true
			if not dialogue_dr.playing and dialogue_me_finished and not dialogue_dr_finished:
				if start_doc and not did_dialogue2_start:
					did_dialogue2_start = true
					doc.visible = true
					dialogue_dr.play()
				
			if dialogue_dr_finished and dialogue_me_finished:
				skip.visible = false
				proceed.visible = true
				MusicManager.set_volume(80)
			#dialogue_me.play()
			#if not dialogue_me.playing:
				#doc.visible = true
				#dialogue_dr.play() 
			#if not dialogue_dr.playing and not dialogue_me.playing:
				#print("lol")
				#is_first_time_playing = false
	if not paused:
		
		if is_tutorial:
			tutorial.visible = true
		#print(coins_label.position)
		#print(player.position)
		#print(player.position + coins_label.position)
		
		
		#level 0
		if level == 0:
			required_coins = 60
			if coins >= required_coins and level_part == 0:
				draw_path(player.position, mob_area.position)
			if meet_me_outside_label.visible and player.velocity != Vector2(0,0):
				meet_me_outside_label.hide()
				level_part = 1
			if coins >= required_coins and level_part == 1:
				draw_path(player.position, door.position)
			
			
		
		if canTurnLapOn and Input.is_action_just_pressed("P"):  # "ui_select" is mapped to "P" by default in Input Map
			canTurnLapOn = false
			var player_x = player.position.x
			var player_y = player.position.y
			var coordinates = str(player_x) + " " + str(player_y)
			var filedata = coordinates + "\n" + str(is_first_time_playing) + "\n" + str(is_tutorial) + "\n" + str(coins) + "\n" + str(level) + "\n" + str(level_part)
			var file = FileAccess.open("user://data.txt", FileAccess.WRITE)
			if file:
				file.store_line(filedata)  # This will overwrite the file content
				file.close()  # Always close the file when done
			else:
				print("Failed to open file.")
			get_tree().change_scene_to_file("res://computer_screen.tscn")
		
		if can_leave_room and Input.is_action_just_pressed("E"):
			var player_x = player.position.x
			var player_y = player.position.y
			var coordinates = str(player_x) + " " + str(player_y)
			var filedata = coordinates + "\n" +str(is_first_time_playing)  + "\n" + str(is_tutorial) + "\n" + str(coins) + "\n" + str(level) + "\n" + str(level_part)
			var file = FileAccess.open("user://data.txt", FileAccess.WRITE)
			if file:
				file.store_line(filedata)  # This will overwrite the file content
				file.close()  # Always close the file when done
			else:
				print("Failed to open file.")
			get_tree().change_scene_to_file("res://city.tscn")
	else:
		if Input.is_action_just_pressed("ui_accept"):

			if dialogue_dr_finished and dialogue_me_finished:
				paused = false
				panel.visible = false
				is_first_time_playing = false
				ui_ux.show()
				MusicManager.set_volume(80)
				camera.queue_free()
			elif dialogue_me_finished and not dialogue_dr_finished:
				if not start_doc:
					start_doc = true
				else:
					dialogue_dr.stop() 
					dialogue_dr_finished = true
			elif not dialogue_me_finished:
				if not start_dialogue:
					start_dialogue = true
				else:
					dialogue_me.stop()
					dialogue_me_finished = true
	#if Input.is_action_just_pressed("exit"):

	
	

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
		leave_label.visible = true
		can_leave_room = true
		#get_tree().change_scene_to_file("res://city.tscn")


func _on_area_2d_2_body_exited(body):
	if body.name == "Player":
		leave_label.visible = false
		can_leave_room = false


func string_to_bool(input: String) -> bool:
	input = input.strip_edges().to_lower()
	return input == "true" or input == "1"


func _on_dialogue_me_finished():
	dialogue_me_finished = true
	
func _on_dialogue_dr_finished():
	dialogue_dr_finished = true


func _on_timer_timeout():
	start_dialogue = true


func _on_dialogue_separate_time_timeout():
	start_doc = true


func _on_mob_area_body_entered(body):
	if body == player:
		if level == 0 and level_part == 0 and line_2d.points.size() != 0:
			line_2d.clear_points()
			paused = true
			if MusicManager.volume_percentage > 50:
				MusicManager.previous_volume = MusicManager.volume_percentage
				MusicManager.set_volume(50)
			meet_me_outside_dialogue.play()
			meet_me_outside_label.show()


func _on_meet_me_outside_dialogue_finished():
	MusicManager.set_volume(MusicManager.previous_volume)
	paused = false
	is_meet_me = true

func draw_path(pos1, pos2):
	line_2d.clear_points()
	line_2d.add_point(pos1)
	line_2d.add_point(pos2)

func clear_path():
	line_2d.clear_points()
