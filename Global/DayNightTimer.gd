extends Timer

export var cycle_duration_minutes : float = 3
onready var cycle : float
enum {DAY,NIGHT}
var time_cycle = NIGHT
var prev_cycle = DAY
var time_string = ""
onready var time_remaining : float = cycle

# Called when the node enters the scene tree for the first time.
func _init():
	wait_time = 60.0 * cycle_duration_minutes
	update_time_remaining()

func _process(delta):
	update_time_remaining()
func start_cycle():
	match time_cycle:
		DAY:
			start_timer()
		NIGHT:
			start_timer()

func start_timer():
	start(cycle)
	time_remaining = time_left
	
func update_time_remaining():
		time_remaining = time_left
		
func end_cycle():
	match time_cycle:
		DAY:
			prev_cycle = time_cycle
			time_cycle = NIGHT
			time_string = "day"
			GameManager.sky_animate.play("Day")
		NIGHT:
			prev_cycle = time_cycle
			time_cycle = DAY
			time_string = "night"
			GameManager.sky_animate.play("Night")
