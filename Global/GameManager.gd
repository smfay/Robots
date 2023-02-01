extends Node2D

var _save : SaveGame

enum {PLAY,CUTSCENE,PAUSED,TRANSITION,MENU}
var state = PLAY

onready var world
onready var environment = $Filter/WorldEnvironment
onready var transition_layer = $SceneTransition
onready var transition_animate = $SceneTransition/ViewportContainer/Control/AnimationPlayer
onready var transition_rect = $SceneTransition/ViewportContainer/Control/ColorRect
onready var player_data = $PlayerData
onready var time = $DayNightTimer
onready var sky = $Sky
onready var sky_animate = $Sky/AnimationPlayer
var current_gradient : GradientTexture
export var transition_speed := 1.0
export var transition_color : Color
export var night_gradient : GradientTexture
export var day_gradient : GradientTexture
export var game_data : Resource

#Utils
var fx := ParticleManager.new()

signal dialogue_end

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func create_or_load_save() -> void:
	if SaveGame.save_exists():
		_save = SaveGame.load_savegame() as SaveGame
	else:
		_save = SaveGame.new()

func _process(delta):
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
	
func has_ability(ability):
	if player_data.unlocked_abilities.has(ability):
		return true
	else:
		return false
		
func gain_ability(ability):
	if !player_data.unlocked_abilities.has(ability):
		player_data.unlocked_abilities.append(ability)

func time_cycle_ended():
	time_to_gradient()

func time_to_gradient():
	match time.time_cycle:
		0:
			environment.environment.adjustment_color_correction = night_gradient
			#sky.visible = false
		1:
			environment.environment.adjustment_color_correction = day_gradient
			#sky.visible = true

func previous_time_to_gradient():
	match time.prev_cycle:
		0:
			environment.environment.adjustment_color_correction = night_gradient
		1:
			environment.environment.adjustment_color_correction = day_gradient

func _on_DayNightTimer_timeout():
	time.end_cycle()
	time_cycle_ended()
	print(time.time_cycle)
