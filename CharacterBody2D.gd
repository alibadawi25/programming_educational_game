extends CharacterBody2D

@onready var navigation_agent_2d = $NavigationAgent2D

var speed = 300
var accel = 7

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var direction = Vector3()
	
	navigation_agent_2d.target_position = get_global_mouse_position()
	
	direction = navigation_agent_2d.get_next_path_position() - global_position
	direction = direction.normalized()
	
	velocity = velocity.lerp(direction * speed, accel * delta)
	
	move_and_slide()
