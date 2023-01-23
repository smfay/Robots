extends KinematicBody2D
class_name Actor

var velocity = Vector2.ZERO

export var max_speed_mod = 2.0
export var acceleration = 3000
export var deceleration = 60
export var move_speed = 200
export var jump_height : float = 48
export var jump_time_to_peak : float = 0.4
export var jump_time_to_descent : float = 0.3
onready var jump_velocity : float = ((2.0 * jump_height) / jump_time_to_peak) * -1.0
onready var jump_gravity : float = ((-2.0 * jump_height) / (jump_time_to_peak * jump_time_to_peak)) * -1.0
onready var fall_gravity : float = ((-2.0 * jump_height) / (jump_time_to_descent * jump_time_to_descent)) * -1.0

export var knockback_factor := 1.0
export var knockback_increment : float = 0.1
export var knockback_decay : float = 0.5

func _ready():
	pass # Replace with function body.

func action() -> void:
	pass
	
func take_damage():
	pass
	
func get_gravity() -> float:
	if velocity.y < 0.0:
		return jump_gravity
	else:
		return fall_gravity
	
func apply_gravity(delta):
	velocity.y += get_gravity() * delta

func apply_physics(delta,acceleration):
		apply_gravity(delta)
		velocity = move_and_slide(velocity, Vector2.UP)
		
func apply_knockback_physics(delta):
	knockback_bounce_and_decrease(delta)

func knockback_bounce_and_decrease(delta):
	var collision_info = move_and_collide(velocity * delta)
	var prev_velocity = velocity
	if collision_info:
		var pause_length = (abs(velocity.length()) * 0.01) * 0.01
		pause_length = clamp(pause_length,0,0.1)
		var bounce_velocity = velocity.bounce(collision_info.normal)
		yield(get_tree().create_timer(pause_length), "timeout")
		velocity = bounce_velocity * knockback_decay
	velocity.y += (get_gravity() * 2) * delta
	velocity.x = move_toward(velocity.x,0,5 * delta)
	velocity.y = move_toward(velocity.y,0,5 * delta)
