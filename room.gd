extends Node2D

@onready var label = $"./Area2D/Label"
@onready var camera_2d = $Player/Camera2D

var canTurnLapOn = false

func _ready():
	label.visible = false  # Ensure the label is initially hidden

func _process(delta):
	if canTurnLapOn and Input.is_action_just_pressed("P"):  # "ui_select" is mapped to "P" by default in Input Map
		# Load the new scene
		get_tree().change_scene_to_file("res://computer_screen.tscn")

	if Input.is_action_just_pressed("exit"):
		get_tree().quit()

func _on_area_2d_body_entered(body):
	if body.name == "Player":
		label.visible = true
		canTurnLapOn = true

func _on_area_2d_body_exited(body):
	if body.name == "Player":
		label.visible = false
		canTurnLapOn = false
