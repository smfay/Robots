extends Actor
class_name PlayerCharacter

enum PlayerStates {MOVE,DAMAGED}
var player_state = PlayerStates.MOVE
onready var animation = $AnimationPlayer

func _ready():
	pass

func actor_process(delta):
	move_state(delta)
	
func move_state(delta):
	if Input.is_action_pressed("sprint"):
		pass
	else:
		pass
		
	h_input_to_velocity(delta)

func get_h_input_velocity() -> float:
	var h_input := 0.0
	h_input = Input.get_axis("ui_left","ui_right")
	return h_input
	
func get_v_input_velocity() -> float:
	var v_input := 0.0
	v_input = Input.get_axis("ui_up","ui_down")
	return v_input
	
func h_input_to_velocity(delta,speed := move_speed,rate := acceleration):
	velocity.x = move_toward(velocity.x,get_h_input_velocity() * speed, rate * delta)
	
func handle_animations():
	pass
