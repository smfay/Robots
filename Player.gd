extends KinematicBody2D

# Required Nodes
onready var animation = $SpriteContainer/AnimationPlayer
onready var sprite = $SpriteContainer
onready var hitbox = $SpriteContainer/HitBox
onready var hitbox_collider = $SpriteContainer/HitBox/CollisionShape2D
onready var hurtbox = $SpriteContainer/HurtBox
onready var hurtbox_collider = $SpriteContainer/HurtBox/CollisionShape2D
onready var particle = $ParticleHandler
onready var grab_pivot = $SpriteContainer/GrabPivot

var parent = instance_from_id(get_instance_id())

# States
enum abilities {ROLLOUT}
enum {MOVE,GRAB,HURT,HOLDING,DISABLED,ABILITY}
export var state = MOVE

# Signals
signal damaged(health)
signal hit_wall(amount)
signal hit_enemy(amount)
signal effect(effect,location)

# Damage and Knockback
export var hp = 100
export var knockback_factor := 1.0
export var knockback_increment : float = 0.1
export var knockback_decay : float = 0.5
#var knockback_angle = Vector2.ZERO

# Movement
var holding = false
var held_item = null
export var throw_force = 150
var sprinting = false
var velocity = Vector2.ZERO
var jumps = 0
var speed_mod = 1
export var max_speed_mod = 2.0
export var acceleration = 3000
export var deceleration = 60
export var move_speed = 200
export var slide_force : float
export var jump_height : float
export var jump_time_to_peak : float
export var jump_time_to_descent : float
export var fast_fall_factor : float
onready var jump_velocity : float = ((2.0 * jump_height) / jump_time_to_peak) * -1.0
onready var jump_gravity : float = ((-2.0 * jump_height) / (jump_time_to_peak * jump_time_to_peak)) * -1.0
onready var fall_gravity : float = ((-2.0 * jump_height) / (jump_time_to_descent * jump_time_to_descent)) * -1.0

# Combat
var input_buffered = -1
var air_stall : float = 1000.0
export var base_air_stall : float = 1000.0
export var air_stall_clamp : float = 5.0



func _ready():
	hitbox.base_knockback = 150
	
func _physics_process(delta):
	sprite.rotation = 0
	match state:
		MOVE:
			move_state(delta)
			hurtbox_collider.disabled = false
		GRAB:
			grab_state(delta)
		HURT:
			hitbox_collider.disabled = true
			sprite.rotation = move_toward(sprite.rotation,velocity.x * 0.05,0.2)
			hurt_state(delta)
		HOLDING:
			holding_state(delta)
		DISABLED:
			disabled_state(delta)
		ABILITY:
			ability_state(delta)
	
	air_stall = move_toward(air_stall, base_air_stall, 150 * delta)
	if is_on_floor():
		jumps = 2
	
func move_state(delta):
	if Input.is_action_pressed("sprint"):
		sprinting = true
	else:
		sprinting = false
	hitbox_collider.disabled = true
	animation.playback_speed = 1
	if is_on_floor():
		if velocity.x != 0:
			if sprinting: 
				animation.playback_speed = 1 * speed_mod
				animation.play("Sprint")
			else:
				animation.play("Run")
		else:
			animation.play("Idle")
	elif velocity.y > 0:
		animation.play("Fall")
	if (Input.is_action_just_pressed("jump") and is_on_floor()) or (Input.is_action_just_pressed("jump") and jumps > 0):
		jump()
	if Input.is_action_just_pressed("grab"):
		if !holding:
			animation.play("grab")
			state = GRAB
	handle_direction()
	apply_physics(delta,acceleration,false)
	
	if Input.is_action_just_pressed("ability"):
		if check_ability("rollout"):
			print("I have this ability!")
			state = ABILITY
			rollout()
		else:
			print("I do not have this ability!")
	
func ability_state(delta):
	if (Input.is_action_just_pressed("jump") and is_on_floor()) or (Input.is_action_just_pressed("jump") and jumps > 0):
		state = MOVE
		jump()
	apply_physics(delta,10,false)
	
func check_ability(ability):
	if GameManager.has_ability(ability):
		return true
	else:
		return false
	
func grab_state(delta):
	if holding:
		state = HOLDING
	apply_physics(delta,acceleration,false)
	
func holding_state(delta):
	if Input.is_action_pressed("sprint"):
		sprinting = true
	else:
		sprinting = false
	hitbox_collider.disabled = true
	animation.playback_speed = 1
	if is_on_floor():
		if velocity.x != 0:
			if sprinting: 
				animation.playback_speed = 2
				animation.play("SprintHolding")
			else:
				animation.play("RunHolding")
		else:
			animation.play("IdleHolding")
	elif velocity.y > 0:
		animation.play("Fall")
	if (Input.is_action_just_pressed("jump") and is_on_floor()) or (Input.is_action_just_pressed("jump") and jumps > 0):
		jump()
		
	if Input.is_action_just_pressed("grab"):
		throw()
	handle_direction()
	apply_physics(delta,acceleration,false)
	
func hurt_state(delta):
	hitbox_collider.disabled = true
	apply_physics(delta,3,true)
	handle_direction(true)
	
func take_damage(hitbox, amount: int, angle: Vector2, base_knockback: int) -> void:
	animation.play("Hurt")
	AudioBus.play(AudioBus.hurt,0.2,0.8,-10) 
	if holding:
		throw()
	take_knockback(angle,base_knockback)
	decrease_health(amount)
	increment_knockback_factor(knockback_increment)
	state = HURT
	
func handle_direction(flip: bool = false):
	if flip:
		if velocity.x != 0:
			$SpriteContainer.scale.x = sign(-velocity.x)
	elif get_h_input_velocity() != 0:
		$SpriteContainer.scale.x = sign(get_h_input_velocity())

# ------------------------------------------------------------------------------------------------

func decrease_health(amount):
	hp -= amount
	var current_hp = hp
	emit_signal("damaged",current_hp)

func increment_knockback_factor(amount: float):
	knockback_factor += amount

func take_knockback(knockback_angle: Vector2, base_knockback: float):
	var new_velocity = (knockback_angle * base_knockback) * knockback_factor
	if is_on_floor() and new_velocity.y > 0: new_velocity.y = -new_velocity.y
	if is_on_ceiling() and new_velocity.y < 0: new_velocity.y = -new_velocity.y
	velocity = new_velocity
	
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

# ------------------------------------------------------------------------------------------------

func get_gravity() -> float:
	var fall_mod = 0
	if velocity.y > 0.0 and get_v_input_velocity() > 0:
		if not is_on_floor():
			fall_mod = fast_fall_factor
	return jump_gravity if velocity.y < 0.0 else fall_gravity + (fall_gravity * fall_mod)
	
func apply_gravity(delta):
	velocity.y += get_gravity() * delta
	
func disabled_state(delta):
	apply_gravity(delta)
	velocity.x = 0
	velocity = move_and_slide(velocity, Vector2.UP)
	
func apply_physics(delta,acceleration,in_knockback: bool = false):
	if in_knockback:
		knockback_bounce_and_decrease(delta)
	else:
		if sprinting:
				speed_mod = move_toward(speed_mod,max_speed_mod,6*delta)
		else:
			if is_on_floor():
				speed_mod = 1
		apply_gravity(delta)
		h_input_to_velocity(delta,move_speed * speed_mod,acceleration)
		handle_jump_release()
		velocity = move_and_slide(velocity, Vector2.UP)
		
func get_h_input_velocity() -> float:
	var h_input := 0.0
	h_input = Input.get_axis("ui_left","ui_right")
	return h_input
	
func get_v_input_velocity() -> float:
	var v_input := 0.0
	v_input = Input.get_axis("ui_up","ui_down")
	return v_input
	
func h_input_to_velocity(delta,speed,rate):
	if state == ABILITY:
		velocity.x = velocity.x
	else:
		velocity.x = move_toward(velocity.x,get_h_input_velocity() * speed, rate * delta)
	
func jump():
	jumps -= 1
	animation.play("RESET")
	animation.play("Jump")
	AudioBus.play(AudioBus.jump,0.2,5)
	velocity.y = jump_velocity
	
#unlock abilities
func rollout():
	var roll_speed = 30 * speed_mod
	if is_on_floor():
		roll_speed = 60 * speed_mod
	velocity.x += roll_speed * sprite.scale.x
	speed_mod = 4
	animation.playback_speed = 1.0
	animation.play("Rollout")

func successfully_grab(object) -> void:
	held_item = object
	animation.play("RESET")
	holding = true
	state = HOLDING
	AudioBus.play(AudioBus.throw,0.2,4)
	
func throw():
	if held_item.has_method("get_thrown"):
		var throw_angle = Vector2($SpriteContainer.scale.x,0)
		held_item.get_thrown(throw_angle,throw_force + abs(velocity.x))
	animation.play("throw")
	held_item = null
	holding = false
	AudioBus.play(AudioBus.throw,0.2,2)
	state = MOVE

func handle_jump_release():
	if Input.is_action_just_released("jump") and velocity.y < -100:
		velocity.y = -100

# ------------------------------------------------------------------------------------------------

func queue_attack():
	pass

# ------------------------------------------------------------------------------------------------

func current_location() -> Vector2:
	var my_location = global_position
	return my_location

# ------------------------------------------------------------------------------------------------

func _on_HitBox_area_shape_entered(area_rid, area, area_shape_index, local_shape_index):
	if area.owner != parent:
		emit_signal("hit_enemy", 30)
		air_stall = air_stall_clamp
		if animation.current_animation == "dwnSlash":
			animation.play("RESET")
			jump()
			state = MOVE
		elif animation.current_animation == "Slide":
			animation.play("RESET")
			velocity.x = -velocity.x * 0.1
			jump()
			state = MOVE
			
func footstep():
	AudioBus.play(AudioBus.footstep,3,6,rand_range(-10,-5))
