extends Actor
class_name PlayerCharacter

enum PlayerStates {MOVE,GRAB,HURT,HOLDING,DISABLED, ABILITY}

func _ready():
	pass

func _physics_process(delta):
	pass

func get_h_input_velocity() -> float:
	var h_input := 0.0
	h_input = Input.get_axis("ui_left","ui_right")
	return h_input
	
func get_v_input_velocity() -> float:
	var v_input := 0.0
	v_input = Input.get_axis("ui_up","ui_down")
	return v_input
	
func h_input_to_velocity(delta,speed,rate):
	velocity.x = move_toward(velocity.x,get_h_input_velocity() * speed, rate * delta)
