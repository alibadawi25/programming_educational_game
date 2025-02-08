extends ColorRect

@export var cell_size: int = 160  # Size of each grid cell
@export var grid_width: int = 12  # Number of columns
@export var grid_height: int = 5  # Number of rows
@export var grid_color: Color = Color(0.5, 0.5, 0.5, 0.5)  # Semi-transparent gray

func _draw():
	for x in range(grid_width + 1):
		draw_line(Vector2(x * cell_size, 0), Vector2(x * cell_size, grid_height * cell_size), grid_color, 1)
	for y in range(grid_height + 1):
		draw_line(Vector2(0, y * cell_size), Vector2(grid_width * cell_size, y * cell_size), grid_color, 1)
