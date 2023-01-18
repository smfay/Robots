extends Control


onready var animation = $AnimationPlayer
onready var options = $TitleScreen/Panel/Options/NewGame


# Called when the node enters the scene tree for the first time.
func _ready():
	GameManager.fade_out()
	GameManager.fade_in()
	animation.play("SplashScreen")


func fade_in():
	GameManager.fade_in()
	
func fade_out():
	GameManager.fade_out()
	
func give_menu_focus():
	options.grab_focus()
