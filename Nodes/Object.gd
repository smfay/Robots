extends KinematicBody2D
class_name GrabbableObject

# States
enum {STATIC,GRABBED,THROWN}
export var state = STATIC
onready var collider = $CollisionShape2D
onready var sprite = $Sprite
onready var hitbox_collider = $HitBox/CollisionShape2D
var parent = instance_from_id(get_instance_id())

var velocity = Vector2.ZERO
var holder = null
export var knockback_factor = 0.1
export var knockback_decay = 0.7
export var sound_weight = 1.0
var knockback_times_bounced = 0

export var slide_factor = 0.5
export var jump_height : float = 48
export var jump_time_to_peak : float = 0.4
export var jump_time_to_descent : float = 0.3
onready var jump_velocity : float = ((2.0 * jump_height) / jump_time_to_peak) * -1.0
onready var jump_gravity : float = ((-2.0 * jump_height) / (jump_time_to_peak * jump_time_to_peak)) * -1.0
onready var fall_gravity : float = ((-2.0 * jump_height) / (jump_time_to_descent * jump_time_to_descent)) * -1.0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _physics_process(delta):
	match state:
		STATIC:
			static_state(delta)
			hitbox_collider.disabled = true
		GRABBED:
			grabbed_state(delta)
		THROWN:
			thrown_state(delta)
			hitbox_collider.disabled = false
		
func static_state(delta) -> void:
	sprite.rotation = 0
	velocity.x = move_toward(velocity.x,0,50 * delta)
	velocity.y = move_toward(velocity.y,0,50 * delta)
	apply_physics(delta,slide_factor)
	
func get_grabbed(grabber) -> void:
	var grab_receiver = self
	if grabber.has_method("successfully_grab"):
		grabber.successfully_grab(grab_receiver)
		holder = grabber
		state = GRABBED

func grabbed_state(delta) -> void:
	collider.disabled = true
	global_position = holder.grab_pivot.global_position
	
func get_thrown(throw_angle,throw_force) -> void:
	collider.disabled = false
	take_knockback(throw_angle,throw_force)
	state = THROWN

func get_gravity() -> float:
	return jump_gravity if velocity.y < 0.0 else fall_gravity
	
func apply_gravity(delta):
	velocity.y += get_gravity() * delta
	
func apply_physics(delta,acceleration,in_knockback: bool = false):
	if in_knockback:
		knockback_bounce_and_decrease(delta)
	else:
		apply_gravity(delta)
		velocity = move_and_slide(velocity, Vector2.UP)
		
func thrown_state(delta):
	apply_physics(delta,3,true)
	
func take_damage(hitbox, amount: int, angle: Vector2, base_knockback: int) -> void:
	AudioBus.play(AudioBus.hurt,0.1,6,-10)
	take_knockback(angle,base_knockback)
	state = THROWN

	
func take_knockback(knockback_angle: Vector2, base_knockback: float):
	var new_velocity = (knockback_angle * base_knockback) * knockback_factor
	if is_on_floor() and new_velocity.y > 0: new_velocity.y = -new_velocity.y
	if is_on_ceiling() and new_velocity.y < 0: new_velocity.y = -new_velocity.y
	velocity = new_velocity
	
func knockback_bounce_and_decrease(delta):
	var collision_info = move_and_collide(velocity * delta)
	var prev_velocity = velocity
	if collision_info:
		var pause_length = (abs(velocity.length()) * 0.01) * 0.001
		pause_length = clamp(pause_length,0,0.1)
		var bounce_velocity = velocity.bounce(collision_info.normal)
		yield(get_tree().create_timer(pause_length), "timeout")
		velocity = bounce_velocity * knockback_decay
		emit_signal("hit_wall", 10)
		sprite.rotation = rand_range(-0.001,0.001) * velocity.x
		var hit_volume = clamp(-30 + abs(velocity.x * 0.1),-30,0)
		if hit_volume > -20:
			AudioBus.play(AudioBus.groundhit,0.1,sound_weight,hit_volume)
	velocity.y += (get_gravity()*1.5) * delta
	velocity.x = move_toward(velocity.x,0,50 * delta)
	if abs(velocity.x) < 5 and abs(velocity.x) < 5:
		state = STATIC

