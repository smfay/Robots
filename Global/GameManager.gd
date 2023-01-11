extends Node2D

enum {PLAY,CUTSCENE,PAUSED,TRANSITION}
var state = PLAY

onready var world
onready var transition_layer = $SceneTransition
onready var transition_animate = $SceneTransition/ViewportContainer/Control/AnimationPlayer
onready var transition_rect = $SceneTransition/ViewportContainer/Control/ColorRect
onready var player_data = $PlayerData
export var transition_speed := 1.0
export var transition_color : Color
signal dialogue_end

# Called when the node enters the scene tree for the first time.
func _ready():
	transition_animate.playback_speed = transition_speed
	transition_rect.material.set_shader_param("out_color",transition_color)

func _process(delta):
		match state:
			PLAY:
				pass
			CUTSCENE:
				pass
			PAUSED:
				pass
			TRANSITION:
				pass
				
func fade_out():
	transition_layer.visible = true
	transition_animate.play("FadeOut")
	
func fade_in():
	transition_animate.play("FadeIn")
	
func enter_dialogue(timeline):
	state = CUTSCENE
	world.player.state = 4
	world.player.animation.play("Idle")
	var dialogue = str(timeline)
	var current_dialogue = Dialogic.start(dialogue)
	current_dialogue.connect("timeline_end", self, "exit_dialogue")
	add_child(current_dialogue)

func dialogue_listener(string):
	match string:
		"timeline_ended":
			exit_dialogue()

	
func exit_dialogue():
	state = PLAY
	world.player.state = 0
	emit_signal("dialogue_end")
	print("ran")
	
func has_ability(ability):
	if player_data.unlocked_abilities.has(ability):
		return true
	else:
		return false
		
func gain_ability(ability):
	if !player_data.unlocked_abilities.has(ability):
		player_data.unlocked_abilities.append(ability)
		print(player_data.unlocked_abilities)


