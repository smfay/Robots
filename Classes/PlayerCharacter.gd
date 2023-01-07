extends KinematicBody2D

# Required Nodes
onready var animation = $SpriteContainer/AnimationPlayer
onready var sprite = $SpriteContainer
onready var hitbox = $SpriteContainer/HitBox
onready var hitbox_collider = $SpriteContainer/HitBox/CollisionShape2D
onready var hurtbox = $SpriteContainer/HurtBox
onready var hurtbox_collider = $SpriteContainer/HurtBox/CollisionShape2D
onready var particle = $ParticleHandler

var parent = instance_from_id(get_instance_id())

# States
enum {MOVE,MELEE,SLIDE,HURT}
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
var velocity = Vector2.ZERO
var jumps = 0
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
	$SpriteContainer/SwordSlash.visible = false
	hitbox.base_knockback = 150
	
func _physics_process(delta):
	sprite.rotation = 0
	match state:
		MOVE:
			move_state(delta)
		MELEE:
			melee_state(delta)
		SLIDE:
			slide_state(delta)
		HURT:
			hitbox_collider.disabled = true
			sprite.rotation = move_toward(sprite.rotation,velocity.x * 0.05,0.2)
			$SpriteContainer/SwordSlash.visible = false
			hurt_state(delta)
	
	air_stall = move_toward(air_stall, base_air_stall, 150 * delta)
	
	if is_on_floor():
		jumps = 2
	
func move_state(delta):
	animation.playback_speed = 1.3
	$SpriteContainer/SwordSlash.visible = false
	hitbox_collider.disabled = true
	animation.playback_speed = 1	
	if is_on_floor():
		if velocity.x != 0:
			animation.play("Run")
		else:
			animation.play("Idle")
	elif velocity.y > 0:
		animation.play("Fall")
		
	if Input.is_action_just_pressed("dash"):
		animation.play("Slide")
		velocity.x = slide_force*$SpriteContainer.scale.x
		state = SLIDE
	elif (Input.is_action_just_pressed("jump") and is_on_floor()) or (Input.is_action_just_pressed("jump") and jumps > 0):
		jump()
	elif Input.is_action_just_pressed("attack"):
		input_buffered = 0
		if Input.is_action_pressed("ui_up"):
			animation.play("upSlash")
		elif !is_on_floor() and Input.is_action_pressed("ui_down"):
			animation.play("dwnSlash")
		else:
			animation.play("fwdSlash")
		state = MELEE
	
	handle_direction()
	apply_physics(delta,acceleration,false)
	
func melee_state(delta):
	animation.playback_speed = 1.4
	if Input.is_action_just_pressed("dash"):
		animation.queue("Slide")
		velocity.x = slide_force*$SpriteContainer.scale.x
		state = SLIDE
	if Input.is_action_just_pressed("jump") and is_on_floor():
		jump()
		input_buffered = 0
		state = MOVE
	if Input.is_action_just_pressed("attack"):
		input_buffered += 1
	if !animation.is_playing():
		input_buffered = 0
		animation.play("RESET")
		state = MOVE
	#velocity.y = move_toward(velocity.y,0,20)
	#velocity.x = clamp(velocity.x,-air_stall,air_stall)
	velocity.y = clamp(velocity.y,-air_stall,air_stall)
	apply_physics(delta,acceleration,false)
	
func slide_state(delta):
	animation.playback_speed = 3.0
	velocity.y = 0
	if Input.is_action_just_pressed("jump") and jumps > 0:
		jump()
		state = MOVE
	if Input.is_action_just_pressed("attack"):
		input_buffered = 0
		animation.play("fwdSlash")
		#velocity.x = 500*$SpriteContainer.scale.x
		state = MELEE
	#apply_gravity(delta)
	velocity.x = move_toward(velocity.x,0,3000 * delta)
	move_and_slide_with_snap(velocity,Vector2.UP)
	
func hurt_state(delta):
	hitbox_collider.disabled = true
	particle.knockback()
	apply_physics(delta,3,true)
	handle_direction(true)
	
func take_damage(hitbox, amount: int, angle: Vector2, base_knockback: int) -> void:
	animation.play("Hurt")
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
	
func handle_attack_buffer():
	if input_buffered == 0:
		state = MOVE
		return
	if input_buffered > 0:
		if Input.is_action_pressed("ui_up"):
			animation.queue("upSlash")
			handle_direction()
			input_buffered = 0
		elif Input.is_action_pressed("ui_down") and !is_on_floor():
			animation.queue("dwnSlash")
			handle_direction()
			input_buffered = 0
		else:
			animation.queue("fwdSlash")
			handle_direction()
			input_buffered = 0
			
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
		particle.hit_wall()
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
	
func apply_physics(delta,acceleration,in_knockback: bool = false):
	if in_knockback:
		knockback_bounce_and_decrease(delta)
	else:
		apply_gravity(delta)
		h_input_to_velocity(delta,move_speed,acceleration)
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
	velocity.x = move_toward(velocity.x,get_h_input_velocity() * speed, rate * delta)
	
func jump():
	jumps -= 1
	animation.play("RESET")
	animation.play("Jump")
	velocity.y = jump_velocity
	
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
