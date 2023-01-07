extends Node2D


onready var player = $Player
onready var nav = $Navigation2D
var new_dialog = Dialogic.start("test")


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _on_Area2D_body_entered(body):
	add_child(new_dialog)
	print("area entered")
