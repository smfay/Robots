extends Node

const footstep = preload("res://Audio/General/footstep.ogg")
const groundhit = preload("res://Audio/General/ground_hit.ogg")
const jump = preload("res://Audio/General/jump.ogg")
const throw = preload("res://Audio/General/throw.ogg")
const hurt = preload("res://Audio/General/hurt.ogg")
const enter = preload("res://Audio/General/enter.ogg")
const exit = preload("res://Audio/General/exit.ogg")

const daytime = preload("res://Audio/Music/daytime.ogg")
const farm = preload("res://Audio/Music/farm.ogg")

onready var audioplayers = $AudioPlayers


# Called when the node enters the scene tree for the first time.
func _ready():
	#play(daytime,0,0.95,-25)
	pass


func play(sound,rand: float = 0, base: float = 1,volume: float = 0):
	for audiostream in audioplayers.get_children():
		if not audiostream.is_playing():
			audiostream.stream = sound
			audiostream.volume_db = volume
			audiostream.pitch_scale = base + rand_range(-rand,rand)
			audiostream.play()
			break
