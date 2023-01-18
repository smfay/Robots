extends Area2D
class_name Passage
export var destination := ""
export var key := ""
var player
var player_in_position


func _init() -> void:
	collision_layer = 0
	collision_mask = 1

func _ready() -> void:
	connect("body_entered", self, "_on_body_entered")
	connect("body_exited", self, "_on_body_exited")

func _input(event):
	if event.is_action_pressed("ui_up"):
		if player_in_position and player.is_on_floor() and !player.holding and player.state != 4:
			player.state = 4
			player.global_position = global_position
			player.animation.play("Enter")
			GameManager.world.go_to(destination,key)
	
func _on_body_entered(body) -> void:
	if body.name == "Player":
		get_player(body)
		player_in_position = true
	
func _on_body_exited(body):
		if body.name == "Player":
			player_in_position = false
			
func get_player(player_node):
	player = player_node
