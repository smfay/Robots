extends KinematicBody2D
class_name Projectile

var velocity := Vector2.ZERO

var creator

export var initial_speed := 200.0
export var passive_speed := 0.0
export var speed_damping := 2000.0
export var direction : float
export var lifetime := 5.0
export var random_initial_variate := 0.0
export var random_passive_variate := 0.0
export var initial_x_scale = 1.0
export var initial_y_scale = 1.0

export var die_at_depleted_speed : bool = true
export var depletion_threshold := 0.0
export var x_scale_to_zero : bool = true
export var x_to_zero_rate := 10.0
export var y_scale_to_zero : bool = true
export var y_to_zero_rate := 5.0
export var x_scale_target := 0.0
export var y_scale_target := 0.0
export var y_spread = 0.0

var death_timer : SceneTreeTimer

func _ready():
	velocity.y = rand_range(-y_spread,y_spread)
	var spd = rand_range(passive_speed-random_passive_variate,passive_speed+random_passive_variate)
	var spd_init = rand_range(initial_speed-random_initial_variate,passive_speed+random_initial_variate)
	rotation = velocity.y *0.001
	scale.x = direction
	death_timer = get_tree().create_timer(lifetime)
	death_timer.connect("timeout",self,"die")
	scale.x = initial_x_scale * direction
	scale.y = initial_y_scale
	velocity.x = initial_speed * direction
	passive_speed = spd

func die():
	death_process()
	queue_free()

func _physics_process(delta):
	velocity.x = move_toward(velocity.x,passive_speed*direction,speed_damping*delta)
	if x_scale_to_zero:
		scale.x = move_toward(scale.x,x_scale_target*direction,x_to_zero_rate*delta)
	if y_scale_to_zero:
		scale.y = move_toward(scale.y,y_scale_target,y_to_zero_rate*delta)
	if die_at_depleted_speed == true:
		if velocity.x == depletion_threshold:
			die()
	apply_physics(delta,speed_damping)

func death_process():
	pass
	
func apply_physics(delta,acceleration):
	velocity = move_and_slide(velocity, Vector2.UP)
