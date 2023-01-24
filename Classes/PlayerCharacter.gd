extends Actor
class_name PlayerCharacter

enum PlayerStates {MOVE,DAMAGED}
var player_state = PlayerStates.MOVE
onready var animation = $AnimationPlayer
onready var sprite_container = $SpriteContainer

func _ready():
	pass

func actor_process(delta):
	match player_state:
		PlayerStates.MOVE:
			move_state(delta)
			handle_move_animations()
		PlayerStates.DAMAGED:
			damaged_state(delta)
	
func move_state(delta):
	if Input.is_action_pressed("sprint"):
		pass
	else:
		pass
		
	h_input_to_velocity(delta)
	
	if Input.is_action_just_released("jump"):
		jump_release()

func damaged_state(delta):
	apply_knockback_physics(delta)
	


func take_damage(hitbox, amount: int, angle: Vector2, base_knockback: int) -> void:
	animation.play("Damaged")
	animation.queue("Tumble")
	AudioBus.play(AudioBus.hurt,0.2,0.8,-10) 
	take_knockback(angle,base_knockback)
	health.lose_hp()
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
	velocity.x = move_toward(velocity.x,get_h_input_velocity() * speed, rate * delta)
	
func handle_move_animations():
	if is_on_floor():
		if velocity.x != 0:
			animation.play("Sprint")
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
