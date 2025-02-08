extends Node2D

@export var and_gate_start_count : int = 0
@export var or_gate_start_count : int = 0
@export var not_gate_start_count : int = 0
@onready var not_count = $"Not-gate/Label"
@onready var and_count = $"And-gate/Label"
@onready var or_count = $"Or-gate/Label"

func _ready():
	# Set inventory values based on this scene
	Inventory.and_gate_count = and_gate_start_count
	Inventory.or_gate_count = or_gate_start_count
	Inventory.not_gate_count = not_gate_start_count
	and_count.text = str(and_gate_start_count)
	or_count.text = str(or_gate_start_count)
	not_count.text = str(not_gate_start_count)

func _process(delta):
	and_count.text = str(Inventory.and_gate_count)
	or_count.text = str(Inventory.or_gate_count)
	not_count.text = str(Inventory.not_gate_count)
