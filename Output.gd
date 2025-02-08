extends Node2D

@export var input_node :Node2D
@onready var label = $Panel/Label

func _process(delta):
	if input_node.value != null:
		label.text = to_value(input_node)
	else:
		label.text = "0"
	
func to_value(input_node):
	if input_node.value:
		return "1"
	else:
		return "0"
	
