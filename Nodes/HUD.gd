extends CanvasLayer

onready var health_bar = $HealthBar
onready var health_label = $HealthLabel

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	visible = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Player_damaged(health):
	health_bar.value = health
	health_label.text = str(health) + "%"
