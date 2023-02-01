extends Node2D

onready var levels = $Level
onready var player_world = $PlayerWorld
onready var player = $PlayerWorld/Player
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	
	GameManager.world = self


func go_to(scene, room_key) -> void:
	set_process_unhandled_input(true)
	GameManager.fade_out()
	AudioBus.play(AudioBus.enter,0,0.7)
	yield(GameManager.transition_animate, "animation_finished")
	for level in levels.get_children():
		level.queue_free()
	var next_scene = load("res://Levels/" + str(scene) + ".tscn").instance()
	levels.add_child(next_scene)
	var doors = levels.get_node(str(scene) +"/Doors")
	if room_key != "":
		if doors:
			for door in doors.get_children():
				if door.key == room_key:
					player.global_position = door.global_position
					break
			GameManager.fade_in()
			AudioBus.play(AudioBus.exit,0,0.4)
			player.animation.play("Exit")
			
			yield(player.animation, "animation_finished")
			player.state = 0

