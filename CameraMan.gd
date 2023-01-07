extends Camera2D

export var NOISE_SHAKE_STRENGTH: float = 200.0
export var NOISE_SHAKE_SPEED: float = 200.0
export var SHAKE_DECAY_RATE: float = 5.0
export var user_preference: float = 1.0

onready var rand = RandomNumberGenerator.new()
onready var noise = OpenSimplexNoise.new()

var noise_i: float = 0.0
var shake_strength: float = 0.0

func _ready():
	rand.randomize()
	noise.seed = rand.randi()
	noise.period = 2

func apply_shake(amount: float = NOISE_SHAKE_STRENGTH) -> void:
	shake_strength = amount * user_preference

func _process(delta: float) -> void:
	shake_strength = lerp(shake_strength, 0, SHAKE_DECAY_RATE * delta)
	self.offset = get_noise_offset(delta)
	
func get_noise_offset(delta: float) -> Vector2:
	noise_i += delta * NOISE_SHAKE_SPEED
	
	return Vector2(
		noise.get_noise_2d(1,noise_i) * shake_strength,
		noise.get_noise_2d(100,noise_i) * shake_strength
	)

func _on_Player_damaged(health):
	apply_shake(80)


func _on_Player_hit_wall(amount):
	apply_shake(amount)


func _on_Player_hit_enemy(amount):
	apply_shake(amount)
