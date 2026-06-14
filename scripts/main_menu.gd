extends Node2D

func _ready():
	AudioManager.play_menu()
	$ButtonPlay.pressed.connect(_on_play_pressed)
	_fade_in()

func _on_play_pressed():
	get_tree().change_scene_to_file("res://scenes/menu/intro.tscn")

func _fade_in():
	$AnimationPlayer.play("fade_in")
