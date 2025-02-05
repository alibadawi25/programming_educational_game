extends Control

@onready var button = $"Mission Card/Button"
@onready var mission = $"Mission Card/nav_button/Mission"
@onready var desc = $"Mission Card/nav_button/Desc"
@onready var coins_count = $coins_count
@onready var nav_button = $NavButton
@onready var nav_button_area = $"Mission Card/nav_button"

var is_details_shown = false

func _process(delta):
	nav_button.size.y = nav_button_area.size.y

func _on_button_pressed():
	if is_details_shown:
		button.text = "▼"
		is_details_shown = false
		nav_button.size.y=72
		desc.hide()
	else:
		button.text = "▲"
		is_details_shown = true
		desc.show()
