extends Actor
class_name PlayerCharacter

var attacks = ["Attack1","Attack2","Attack3","Attack4"]
var current_attack = "Attack1"
enum PlayerStates {MOVE,DAMAGED,ATTACK,ROLL}
var player_state = PlayerStates.MOVE
onready var animation = $AnimationPlayer
onready var sprite_container = $SpriteContainer
onready var sprite = $SpriteContainer/Sprite
onready var emitter = $SpriteContainer/PointEmitter
onready var projectile = load("res://Assets/PlayerAttack.tscn")

export var attack_force = 250

func _ready():
	pass

func actor_process(delta):
	match player_state:
		PlayerStates.MOVE:
			move_state(delta)
			sprite.material.set_shader_param("Strength", 0)
			handle_move_animations()
			animation.playback_speed = 1.0
		PlayerStates.ATTACK:
			attack_state(delta)
			animation.playback_speed = 1.0
		PlayerStates.ROLL:
			roll_state(delta)
			animation.playback_speed = 1.5
		PlayerStates.DAMAGED:
			damaged_state(delta)
			animation.playback_speed = 0.1 * abs(velocity.x*0.1)
			sprite.material.set_shader_param("Strength", 5)
	
func move_state(delta):
	if Input.is_action_pressed("sprint"):
		speed_multiplier = 1.5
	else:
		speed_multiplier = 1.5
		
	h_input_to_velocity(delta)
	
	if Input.is_action_just_released("jump"):
		jump_release()
	
	if Input.is_action_just_pressed("attack"):
		pick_attack()
		animation.play("RESET")
		animation.play(current_attack)
		player_state = PlayerStates.ATTACK

	if Input.is_action_just_pressed("ability"):
		roll()
		player_state = PlayerStates.ROLL

func roll_state(delta):
	animation.play("Roll")
	if (Input.is_action_just_pressed("jump") and is_on_floor()) or (Input.is_action_just_pressed("jump") and jumps > 0):
		animation.play("RESET")
		jump()
		player_state = PlayerStates.MOVE
	if Input.is_action_just_pressed("attack"):
		pick_attack()
		animation.play("RESET")
		animation.play(current_attack)
		player_state = PlayerStates.ATTACK

func attack_state(delta):
	speed_multiplier = 0.8
	h_input_to_velocity(delta)
	animation.play(current_attack)
	velocity_move_to_zero(delta,2000)
	if Input.is_action_just_pressed("attack") and animation.is_playing():
		pick_attack()
		animation.queue(current_attack)

func damaged_state(delta):
	apply_knockback_physics(delta)
	
func hit_wall():
	animation.play("RESET")
	animation.play("Damaged")
	animation.queue("Tumble")

func exit_knockback():
	player_state = PlayerStates.MOVE

func take_damage(hitbox, amount: int, angle: Vector2, base_knockback: int) -> void:
	animation.play("RESET")
	animation.play("Damaged")
	animation.queue("Tumble")
	AudioBus.play(AudioBus.hurt,0.2,0.8,-10) 
	take_knockback(angle,base_knockback)
	health.lose_hp()
	print(health.current_hp)
	increment_knockback_factor(knockback_increment)
	player_state = PlayerStates.DAMAGED

func get_h_input_velocity() -> float:
	var h_input := 0.0
	h_input = Input.get_axis("ui_left","ui_right")
	return h_input
	
func get_v_input_velocity() -> float:
	var v_input := 0.0
	v_input = Input.get_axis("ui_up","ui_down")
	return v_input
	
func h_input_to_velocity(delta,speed := move_speed,rate := acceleration):
	velocity.x = move_toward(velocity.x,get_h_input_velocity() * (speed*speed_multiplier), rate * delta)

func velocity_move_to_zero(delta,rate := deceleration):
	velocity.x = move_toward(velocity.x,0, rate * delta)

func face_input_and_impulse(force = attack_force):
	if get_h_input_velocity() != 0:
		velocity.x += (force * 2) * sign(get_h_input_velocity())
	else:
		velocity.x = force * sprite_container.scale.x
	if velocity.x != 0:
		sprite_container.scale.x = sign(velocity.x)

func handle_move_animations():
	if is_on_floor():
		if velocity.x != 0:
			if speed_multiplier == 1.0:
				animation.play("Walk")
			else:
				animation.play("Run")
		else:
			animation.play("Idle")
	else:
		if velocity.y < 0:
			animation.play("Jump")
		else:
			animation.play("Fall")
			
	if (Input.is_action_just_pressed("jump") and is_on_floor()) or (Input.is_action_just_pressed("jump") and jumps > 0):
		jump()
		
	if velocity.x != 0:
		sprite_container.scale.x = sign(velocity.x)

func roll():
	var roll_speed = 100 * speed_multiplier
	velocity.x += roll_speed * sprite_container.scale.x
	animation.play("RESET")
	animation.play("Roll")

func pick_attack():
	var attack = attacks[int(round(rand_range(0,attacks.size()-1)))]
	current_attack = attack

func _on_AnimationPlayer_animation_finished(anim_name):
	if player_state == PlayerStates.ATTACK and animation.get_queue().size() == 0:
		animation.play("RESET")
		player_state = PlayerStates.MOVE
	if player_state == PlayerStates.ROLL:
		animation.play("RESET")
		player_state = PlayerStates.MOVE

func emit_projectile():
	var proj = projectile.instance()
	proj.global_position = emitter.global_position
	proj.direction = sprite_container.scale.x
	proj.initial_speed = proj.initial_speed + (velocity.x * proj.direction)
	proj.add_to_group("Player")
	GameManager.world.add_child(proj)
	AudioBus.play(AudioBus.throw,0.05,1.1,-10) 
	proj.global_position = emitter.global_position
	proj.direction = sprite_container.scale.x
