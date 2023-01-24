extends Actor
class_name Enemy

enum EnemyStates {IDLE, WANDER, PURSUE, AVOID, ATTACK}
var enemy_state = EnemyStates.IDLE
var player = GameManager.world.player
var player_loc : Vector2

func _ready():
	pass
	
func actor_process(delta):
	match enemy_state:
		EnemyStates.IDLE:
			idle_state()
		EnemyStates.WANDER:
			wander_state()
		EnemyStates.PURSUE:
			pursue_state()
		EnemyStates.AVOID:
			avoid_state()
		EnemyStates.ATTACK:
			pass
	enemy_process()

func enemy_process() -> void:
	pass

func idle_state() -> void:
	pass
	
func wander_state() -> void:
	pass
	
func pursue_state() -> void:
	pass
	
func avoid_state() -> void:
	pass
	
func attack_state() -> void:
	pass

func get_player_location() -> Vector2:
	var loc
	loc = player.global_position
	return loc

func get_player_direction() -> Vector2:
	var loc
	loc = global_position.direction_to(player.global_position)
	return loc
