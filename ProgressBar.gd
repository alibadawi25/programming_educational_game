extends ProgressBar

var is_red = true  # Track the current color

func _ready():
	update_fill_color()

func update_fill_color():
	var style_box = StyleBoxFlat.new()
	style_box.bg_color = Color.RED if is_red else Color.BLUE
	add_theme_stylebox_override("fill", style_box)

func toggle_fill_color():
	is_red = !is_red  # Switch between red and blue
	update_fill_color()
