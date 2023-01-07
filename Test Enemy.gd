extends KinematicBody2D
var velocity = Vector2.ZERO
enum {ENGAGE,ATTACK,WANDER,HURT}
export var state = WANDER
onready var sprite = $Sprite
onready var sight = $LineOfSight
export var path_speed =  100
export var aim_accuracy = 0.1
var aggression = rand_range(0.01,5)
var path = []
var threshold = 10
var player = null
var dir_to_player = Vector2.ZERO
var can_shoot = true
var wander_target = Vector2.ZERO
export var wander_range = 50

export var jump_height : float
export var jump_time_to_peak : float
export var jump_time_to_descent : float

onready var jump_velocity : float = ((2.0 * jump_height) / jump_time_to_peak) * -1.0
onready var jump_gravity : float = ((-2.0 * jump_height) / (jump_time_to_peak * jump_time_to_peak)) * -1.0
onready var fall_gravity : float = ((-2.0 * jump_height) / (jump_time_to_descent * jump_time_to_descent)) * -1.0

onready var animation = $AnimationPlayer

onready var hp = 30
export var knockback_factor := 2.0
export var knockback_increment : float = 1.0
var death_effect := preload("res://Assets/FX/ExplodeSmall.tscn")
var wall_hit_effect := preload("res://Assets/FX/ExplodeBullet.tscn")
var charge_effect := preload("res://Assets/FX/EnergyBulletCharge.tscn")
var knockback_effect := preload("res://Assets/FX/DustRun.tscn")
var bullet := preload("res://Projectiles/EnergyBullet.tscn")

func _ready():
	yield(owner, "ready")
	player = owner.player
	animation.playback_speed = 1.5
	animation.play("Idle")
	$ShootDelay.start(rand_range(1,5))

func _physics_process(delta):
	match state:
		ENGAGE:
			engage_state(delta)
			collision_layer = 1
		ATTACK:
			attack_state(delta)
			collision_layer = 1
		WANDER:
			wander_state(delta)
			collision_layer = 1
		HURT:
			hurt_state(delta)
			collision_layer = 0
	
	sprite.visible = true
	dir_to_player.x = move_toward(dir_to_player.x,global_position.direction_to(player.hurtbox.global_position).x,aim_accuracy)
	dir_to_player.y = move_toward(dir_to_player.y,global_position.direction_to(player.hurtbox.global_position).y,aim_accuracy)
	
func get_gravity() -> float:
	return jump_gravity if velocity.y < 0.0 else fall_gravity
	
func apply_physics(delta,rate,in_knockback: bool = false):
	if in_knockback:
		knockback_bounce_and_decrease(delta)
	else:
		if is_on_floor():
			velocity.y -= 10
		velocity = move_and_slide(velocity, Vector2.UP)

		
func engage_state(delta):
	sprite.rotation = velocity.x * 0.002
	if velocity.x != 0 and animation.current_animation != "Hurt":
		sprite.scale.x = sign(velocity.x)
	elif animation.current_animation == "Hurt":
		animation.queue("Idle")
		
	if global_position.distance_to(owner.player.global_position) < 300:
		if global_position.distance_to(owner.player.global_position) > 100:
			velocity.x = move_toward(velocity.x,global_position.direction_to(owner.player.global_position).x * path_speed,aggression)
			velocity.y = move_toward(velocity.y,global_position.direction_to(owner.player.global_position).y * path_speed,aggression)
		else:
			velocity.x = move_toward(velocity.x,-global_position.direction_to(owner.player.global_position).x * path_speed,aggression)
			velocity.y = move_toward(velocity.y,-global_position.direction_to(owner.player.global_position).y * path_speed,aggression)
	else:
		animation.play("Idle")
		state = WANDER
	if global_position.distance_to(owner.player.global_position) < 500:
		if owner.player.global_position.y > global_position.y:
			if can_shoot == true and sight.can_see_player:
				animation.play("Attack")
				can_shoot = false
				velocity.x = 0
				velocity.y = 0
				state = ATTACK
	apply_physics(delta,30,false)
		
func attack_state(delta):
	velocity.x = move_toward(velocity.x,global_position.direction_to(owner.player.global_position).x * path_speed,1)
	velocity.y = move_toward(velocity.y,global_position.direction_to(owner.player.global_position).y * path_speed,1)
	animation.queue("Idle")
	sprite.rotation = 0
	can_shoot = false
	
func wander_state(delta):
	velocity.x = move_toward(velocity.x,global_position.direction_to(wander_target).x * path_speed,1)
	velocity.y = move_toward(velocity.y,global_position.direction_to(wander_target).y * path_speed,1)
	sprite.rotation = velocity.x * 0.002
	if velocity.x != 0:
		sprite.scale.x = sign(velocity.x)
	if global_position.distance_to(owner.player.global_position) < 200 and sight.can_see_player:
		animation.play("Idle")
		state = ENGAGE
	apply_physics(delta,30,false)
	
func update_wander():
	var dist = wander_range
	var pos = global_position
	var x = rand_range(pos.x - dist, pos.x + dist)
	var y = rand_range(pos.y - dist, pos.y + dist)
	wander_target = Vector2(x,y)
	
func hurt_state(delta):
	effect(knockback_effect)
	apply_physics(delta,3,true)

func jump():
	#animation.play("Jump")
	velocity.y = jump_velocity
	velocity.y = move_toward(velocity.y,0,20)

func take_damage(hitbox, amount: int, angle: Vector2, base_knockback: int) -> void:
	animation.play("Hurt")
	collision_layer = 0
	take_knockback(angle,base_knockback)
	decrease_health(amount)
	increment_knockback_factor(knockback_increment)
	state = HURT
		
func death_check():
	if hp <= 0:
		effect(death_effect)
		queue_free()
		
func effect(effect):
		var fx = effect.instance()
		fx.global_position = global_position
		get_tree().current_scene.add_child(fx)
	
func charge():
	effect(charge_effect)
	
func knockback():
	effect(knockback_effect)
	
func attack():
	visible = true
	sprite.scale.x = sign(global_position.direction_to(owner.player.global_position).x)
	var method := bullet.instance()
	method.global_position = global_position
	method.parent = instance_from_id(get_instance_id())
	method.velocity = dir_to_player * method.speed
	get_tree().current_scene.add_child(method)


func _on_Timer_timeout():
	update_wander()


func _on_ShootDelay_timeout():
	can_shoot = true
	
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
		effect(wall_hit_effect)
		yield(get_tree().create_timer(pause_length), "timeout")
		velocity = bounce_velocity
		emit_signal("hit_wall", 10)
	velocity.y += (get_gravity() * 2) * delta
	#velocity.x = move_toward(velocity.x,0,5)

# ------------------------------------------------------------------------------------------------

func can_see_player() -> bool:
	var ray := RayCast2D.new()
	var angle = global_position.direction_to(player.global_position)
	ray.cast_to = angle * 100
	if ray.is_colliding() and ray.get_collider() is player:
		return true
	else:
		return false
	
