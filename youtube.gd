extends Node2D

@onready var line_edit = $Header/ColorRect/LineEdit
@onready var video_not_found_popup = $Body/ColorRect/ScrollContainer/VBoxContainer/video_not_found_popup

# Array of video objects, dynamically accessed by index
@onready var video_objects = [
	$Body/ColorRect/ScrollContainer/VBoxContainer/Video_object,
	$Body/ColorRect/ScrollContainer/VBoxContainer/Video_object2,
	$Body/ColorRect/ScrollContainer/VBoxContainer/Video_object3,
	$Body/ColorRect/ScrollContainer/VBoxContainer/Video_object4,
	$Body/ColorRect/ScrollContainer/VBoxContainer/Video_object5,
	$Body/ColorRect/ScrollContainer/VBoxContainer/Video_object6,
	$Body/ColorRect/ScrollContainer/VBoxContainer/Video_object7,
	$Body/ColorRect/ScrollContainer/VBoxContainer/Video_object8,
	$Body/ColorRect/ScrollContainer/VBoxContainer/Video_object9,
	$Body/ColorRect/ScrollContainer/VBoxContainer/Video_object10,
	$Body/ColorRect/ScrollContainer/VBoxContainer/Video_object11,
	$Body/ColorRect/ScrollContainer/VBoxContainer/Video_object12
]

@onready var links= [
	["Output Hello World in Python / How to Tutorial", "https://youtu.be/ynvUiKy1BmA?si=6Wfwf2HMLVgExX4D", "res://pic.jpg"],
	["marwan moussa - aloomek | مروان موسي - الومك (Drill Remix) | Yung Lee", "https://www.youtube.com/watch?v=6jFcPHXTmrU", "res://Sample.jpg"]
]

func _ready():
	load_videos(links)

func _process(delta):
	if Input.is_action_just_pressed("exit"):
		get_tree().quit()

func load_videos(links):
	links.shuffle()
	for link in links:
		if link:
			for video in video_objects:
				if link[0] == video.get_node("Title/Label").text :
					break
				if video.get_node("Title/Label").text == "":
					video.get_node("Title/Label").text = link[0]
					video.get_node("video/TextureRect").texture = load(link[2])
					break

func clear_videos():
	
	for video in video_objects:
		video.get_node("Title/Label").text = ""
		video.get_node("video/TextureRect").texture = null

func _on_button_pressed():
	load_videos(links)
	var text = line_edit.text
	if text != "":
		var filteredLinks = links.filter(func(element):
			return text.to_lower() in element[0].to_lower()
		)
		clear_videos()
		load_videos(filteredLinks)


# Generalized function for all video objects
func _on_video_pressed(video_index: int):
	if video_index >= 0 and video_index < video_objects.size():
		var video = video_objects[video_index]
		var title = video.get_node("Title/Label").text
		for entry in links:
			if entry:
				if entry[0] == title:
					var video_url = entry[1]

					OS.shell_open(video_url) # Open the link in the browser
					return
			else:
				video_not_found_popup.visible = true
				print("Video is not found")
	else:
		print("Invalid video index")

# Functions for each video press, calling the generalized function
func _on_video_1_pressed():
	_on_video_pressed(0)  # Video 1 corresponds to index 0

func _on_video_2_pressed():
	_on_video_pressed(1)  # Video 2 corresponds to index 1

func _on_video_3_pressed():
	_on_video_pressed(2)  # Video 3 corresponds to index 2

func _on_video_4_pressed():
	_on_video_pressed(3)  # Video 4 corresponds to index 3

func _on_video_5_pressed():
	_on_video_pressed(4)  # Video 5 corresponds to index 4

func _on_video_6_pressed():
	_on_video_pressed(5)  # Video 6 corresponds to index 5

func _on_video_7_pressed():
	_on_video_pressed(6)  # Video 7 corresponds to index 6

func _on_video_8_pressed():
	_on_video_pressed(7)  # Video 8 corresponds to index 7

func _on_video_9_pressed():
	_on_video_pressed(8)  # Video 9 corresponds to index 8

func _on_video_10_pressed():
	_on_video_pressed(9)  # Video 10 corresponds to index 9

func _on_video_11_pressed():
	_on_video_pressed(10)  # Video 11 corresponds to index 10

func _on_video_12_pressed():
	_on_video_pressed(11)  # Video 12 corresponds to index 11


func _on_texture_button_pressed():
	line_edit.text = ""
	clear_videos()
	load_videos(links)
