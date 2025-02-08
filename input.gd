extends Node2D


@onready var label = $Panel/Label

@export var value :bool = false
@export var edittable :bool = true

func _process(delta):
	if value:
		label.text = "1"
	else:
		label.text = "0"

func _on_button_toggled(toggled_on):
	if edittable:
		value = toggled_on
