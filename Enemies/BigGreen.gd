extends Enemy


onready var animation := $AnimationPlayer
onready var sprite_container := $SpriteContainer
onready var sprite : Sprite = $SpriteContainer/Sprite
onready var label = $Label
var attacks = ["Attack1","Attack2"]
var current_attack = "Attack2"

func enemy_process(delta):
	match damage_state:
		DamageStates.NORMAL:
			sprite.material.set_shader_param("Strength", 0)
			pass
		DamageStates.DAMAGED:
			sprite.material.set_shader_param("Strength", 5)
			pass
	match enemy_state:
		0:
			label.text = "idle"
		1:
			label.text = "wander"
		2:
			label.text = "pursue"
		3:
			label.text = "avoid"
		4:
			label.text = "attack"

	if enemy_state == EnemyStates.ATTACK:
		animation.playback_speed = 1.0
		animation.play(current_attack)
	else:
		if is_on_floor():
			if velocity.x != 0:
				animation.play("Run")
				animation.playback_speed = 0.5 * abs(velocity.x*0.01)
				sprite_container.scale.x = sign(velocity.x)
			else:
				animation.play("Idle")
				if enemy_state == EnemyStates.IDLE:
					sprite_container.scale.x = sign(get_player_direction().x)
		else:
			if velocity.y < 0:
				animation.play("Jump")
			else:
				animation.play("Fall")

func attack_lurch(force):
	lurch_in_dir(sprite_container.scale.x,force)
	
func face_player():
	sprite_container.scale.x = sign(get_player_direction().x)
	
func pick_attack():
	var attack = attacks[int(round(rand_range(0,attacks.size()-1)))]
	current_attack = attack

func take_damage(hitbox, amount: int, angle: Vector2, base_knockback: int) -> void:
	animation.play("RESET")
	#animation.queue("Tumble")
	AudioBus.play(AudioBus.hurt,0.05,0.95,-10) 
	take_knockback(angle,base_knockback)
	health.lose_hp()
	increment_knockback_factor(knockback_increment)
	enemy_state = EnemyStates.IDLE
	damage_state = DamageStates.DAMAGED
