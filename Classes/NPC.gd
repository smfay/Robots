extends KinematicBody2D
class_name NPC

enum {WANDER,DIALOGUE,HURT,DISABLED}
export var state = WANDER

onready var animation = $SpriteContainer/AnimationPlayer
onready var sprite = $SpriteContainer
onready var sprite_texture = $SpriteContainer/Sprite

export var character_sprite : Texture
export var has_dialogue : bool
export var timeline := ""

export var hp = 100
export var knockback_factor := 1.0
export var knockback_increment : float = 0.1
export var knockback_decay : float = 0.5

var velocity = Vector2.ZERO
var in_knockback = false
export var acceleration = 3000
export var deceleration = 60
export var move_speed = 30
export var jump_height : float = 48
export var jump_time_to_peak : float = 0.5
export var jump_time_to_descent : float = 0.4
onready var jump_velocity : float = ((2.0 * jump_height) / jump_time_to_peak) * -1.0
onready var jump_gravity : float = ((-2.0 * jump_height) / (jump_time_to_peak * jump_time_to_peak)) * -1.0
onready var fall_gravity : float = ((-2.0 * jump_height) / (jump_time_to_descent * jump_time_to_descent)) * -1.0


# Called when the node enters the scene tree for the first time.
func _ready():
	sprite_texture.texture = character_sprite
	if has_dialogue:
		var dialogue = load("res://Nodes/DialogueZone.tscn").instance()
		dialogue.timeline = timeline
		dialogue.parent = self
		GameManager.connect("dialogue_end",self,"exit_dialogue")
		add_child(dialogue)
	var wander_time = rand_range(0.1,1)
	var timer = get_tree().create_timer(wander_time)
	timer.connect("timeout",self,"change_direction_or_stop")


func _physics_process(delta):
	match state:
		WANDER:
			wander_state(delta)
		DIALOGUE:
			disabled_state(delta)
		HURT:
			pass
		DISABLED:
			pass
			

func wander_state(delta):
	if velocity.x != 0:
		animation.play("Run")
	else:
		animation.play("Idle")
	
	velocity_to_direction()
	apply_physics(delta,acceleration)
	
func get_gravity() -> float:
	return jump_gravity if velocity.y < 0.0 else fall_gravity
	
func apply_gravity(delta):
	velocity.y += get_gravity() * delta
	
func disabled_state(delta):
	animation.play("Idle")
	apply_gravity(delta)
	velocity.x = 0
	velocity = move_and_slide(velocity, Vector2.UP)
	
func apply_physics(delta,acceleration,in_knockback: bool = false):
	if in_knockback:
		knockback_bounce_and_decrease(delta)
	else:
		apply_gravity(delta)
		velocity = move_and_slide(velocity, Vector2.UP)

func knockback_bounce_and_decrease(delta):
	var collision_info = move_and_collide(velocity * delta)
	var prev_velocity = velocity
	var ran_once = false
	if collision_info and not ran_once:
		ran_once = true
		var pause_length = (abs(velocity.length()) * 0.01) * 0.01
		pause_length = clamp(pause_length,0,0.1)
		var bounce_velocity = velocity.bounce(collision_info.normal)
		yield(get_tree().create_timer(pause_length), "timeout")
		velocity = bounce_velocity * knockback_decay
		emit_signal("hit_wall", 10)
	velocity.y += (get_gravity() * 2) * delta
	velocity.x = move_toward(velocity.x,0,5 * delta)
	velocity.y = move_toward(velocity.y,0,5 * delta)
	
func change_direction_or_stop():
	var stop_chance = rand_range(0,1)
	stop_chance = round(stop_chance)
	var wander_time = rand_range(4,5)
	if stop_chance == 0:
		wander_time = rand_range(0.5,2)
		velocity.x = rand_range(-move_speed,move_speed)
	else:
		wander_time = rand_range(1,5)
		velocity.x = 0
	var timer = get_tree().create_timer(wander_time)
	timer.connect("timeout",self,"change_direction_or_stop")
	
func velocity_to_direction():
	if velocity.x != 0:
		sprite.scale.x = sign(velocity.x)
		
func face_player(player):
	sprite.scale.x = sign(global_position.direction_to(player.global_position).x)
	
func enter_dialogue():
	state = DIALOGUE
	
func exit_dialogue():
	print("this works")
	state = WANDER
