extends CanvasLayer

onready var current_time = $Control/HBoxContainer/CurrentTime
onready var time_progress = $Control/HBoxContainer/TimeProgress
onready var time = GameManager.time

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func _process(delta):
	time_progress.max_value = GameManager.time.wait_time
	current_time.text = GameManager.time.time_string
	time_progress.value = GameManager.time.time_left
