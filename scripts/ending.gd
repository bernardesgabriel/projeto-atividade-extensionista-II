extends Node2D

func _ready():
	AudioManager.stop_music()
	AudioManager.play_success()
	
	var time_used = 300.0 - GameData.time_remaining
	var minutes = int(time_used / 60)
	var seconds = int(time_used) % 60
	
	$Title.text = "Missão Concluída!"
	$Message.text = "A pesquisa de energia limpa está salva."
	$StatsLabel.text = "Tempo decorrido: %02d:%02d" % [minutes, seconds]
	$ButtonMenu.pressed.connect(_on_menu_pressed)
	
func _on_menu_pressed():
	# Reseta o GameData para nova partida
	GameData.inventory.clear()
	GameData.lab_leak_fixed = false
	GameData.lab_tube_inserted = false
	GameData.lab_puzzle_complete = false
	GameData.lab_visited = false
	GameData.wrench_ever_collected = false
	GameData.tube_ever_collected = false
	GameData.timer_running = false
	GameData.time_remaining = 300.0
	GameData.last_room = ""
	GameData.notebook_delivered = false
	GameData.notebook_content = ""
	get_tree().change_scene_to_file("res://scenes/menu/main_menu.tscn")
	
