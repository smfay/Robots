extends Actor
class_name Enemy

enum EnemyStates {IDLE, WANDER, PURSUE, AVOID, ATTACK}
enum DamageStates {NORMAL,DAMAGED}
export var enemy_state = EnemyStates.IDLE
export var damage_state = DamageStates.NORMAL
var previous_state
var player
var previous_player_loc : Vector2
var player_loc : Vector2
var wander_timer
var timer : SceneTreeTimer

export var long_attack_range : float = 300
export var short_attack_range : float = 100

func _ready():
	yield(GameManager,"ready")
	player = GameManager.world.player

func set_state(state):
	previous_state = enemy_state
	enemy_state = state
	if enemy_state == EnemyStates.ATTACK:
		if is_on_floor():
			pick_attack()
		else:
			set_state(EnemyStates.PURSUE)

func actor_process(delta):
	match damage_state:
		DamageStates.NORMAL:
			match enemy_state:
				EnemyStates.IDLE:
					idle_state(delta)
					state_change_timer(0.01)
				EnemyStates.WANDER:
					wander_state(delta)
					state_change_timer(0.01)
				EnemyStates.PURSUE:
					pursue_state(delta)
					state_change_timer(5.0)
				EnemyStates.AVOID:
					avoid_state(delta)
					state_change_timer(1.0)
				EnemyStates.ATTACK:
					attack_state(delta)
		DamageStates.DAMAGED:
			damaged_state(delta)
	enemy_process(delta)

func enemy_process(delta) -> void:
	pass

func damaged_state(delta):
	apply_knockback_physics(delta)

func take_damage(hitbox, amount: int, angle: Vector2, base_knockback: int) -> void:
	#animation.play("Damaged")
	#animation.queue("Tumble")
	AudioBus.play(AudioBus.hurt,0.2,0.8,-10) 
	take_knockback(angle,base_knockback)
	health.lose_hp()
	increment_knockback_factor(knockback_increment)
	enemy_state = EnemyStates.IDLE
	damage_state = DamageStates.DAMAGED

func idle_state(delta) -> void:
	velocity.x = move_toward(velocity.x,0,acceleration * delta)
	if get_player_distance() < 50:
		set_state(EnemyStates.AVOID)
	elif get_player_distance() > 300:
		set_state(EnemyStates.PURSUE)
	
func wander_state(delta) -> void:
	var direction
	if wander_timer == null:
		direction = change_direction_or_stop()
	if direction != null:
		walk_in_direction(delta,direction)
	if get_player_distance() < 50:
		set_state(EnemyStates.AVOID)
	elif get_player_distance() > 300:
		set_state(EnemyStates.PURSUE)
	
func pursue_state(delta) -> void:
	walk_to_player(delta)
	if abs(get_player_distance()) < short_attack_range:
		set_state(EnemyStates.ATTACK)
	
func avoid_state(delta) -> void:
	walk_from_player(delta)
	if get_player_distance() > 200:
		timer = null
		set_state(EnemyStates.PURSUE)
	if is_on_wall():
		timer = null
		set_state(EnemyStates.PURSUE)
	
func attack_state(delta) -> void:
	timer = null
	velocity.x = move_toward(velocity.x,0,deceleration * delta)
#	if abs(get_player_distance()) > 30:
#		jump()
#		enemy_state = EnemyStates.AVOID

func get_player_location() -> Vector2:
	var loc
	loc = GameManager.world.player.global_position
	return loc

func get_player_direction() -> Vector2:
	var loc
	loc = global_position.direction_to(GameManager.world.player.global_position)
	return loc
	
func get_player_distance() -> float:
	var loc
	loc = global_position.distance_to(GameManager.world.player.global_position)
	return loc

func state_change_timer(amount:= 1.0):
	if timer == null:
		timer = get_tree().create_timer(amount)
	if !timer.is_connected("timeout",self,"cycle_state"):
		timer.connect("timeout",self,"cycle_state")

func cycle_state():
	if timer != null:
		var rand_state = random_state()
		if rand_state != previous_state:
			if enemy_state != EnemyStates.ATTACK:
				set_state(rand_state)
		else:
			jump()
			set_state(EnemyStates.PURSUE)
		timer.disconnect("timeout",self,"cycle_state")
	timer = null
	state_change_timer()

func change_direction_or_stop() -> float:
	var target = 0.0
	var stop_chance = rand_range(0,1)
	stop_chance = round(stop_chance)
	var wander_time = rand_range(0.1,2)
	if stop_chance != 0:
		wander_time = rand_range(0.1,2)
		var dir = sign(rand_range(-1,1))
		target = dir * move_speed
	else:
		wander_time = rand_range(0.1,0.1)
		target = 0.0
	var timer = get_tree().create_timer(wander_time)
	timer.connect("timeout",self,"change_direction_or_stop")
	wander_timer = timer
	return target
	
func random_state() -> int:
	return int(round(rand_range(0,EnemyStates.size()-1)))

func pick_attack():
	pass

func walk_in_direction(delta,dir):
	if is_on_wall():
		dir = -dir
	velocity.x = move_toward(velocity.x, dir * move_speed, acceleration * delta)
	
func walk_to_player(delta):
	velocity.x = move_toward(velocity.x, get_player_direction().x * move_speed, acceleration * delta)

func walk_from_player(delta):
	velocity.x = move_toward(velocity.x, -get_player_direction().x * move_speed, acceleration * delta)
	
func lurch_in_dir(dir,force):
	velocity.x = force * dir

func turn_on_wall():
	if is_on_wall():
		velocity.x = -velocity.x

func exit_knockback():
	damage_state = DamageStates.NORMAL
