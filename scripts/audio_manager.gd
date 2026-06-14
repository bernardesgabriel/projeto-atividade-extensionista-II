extends Node

@onready var music_player = AudioStreamPlayer.new()
@onready var sfx_player = AudioStreamPlayer.new()

func _ready():
	add_child(music_player)
	add_child(sfx_player)
	music_player.volume_db = -10
	process_mode = Node.PROCESS_MODE_ALWAYS
	music_player.process_mode = Node.PROCESS_MODE_ALWAYS
	sfx_player.process_mode = Node.PROCESS_MODE_ALWAYS

func play_music(path: String, loop: bool = true, volume: float = -15.0):
	var stream = load(path)
	if stream:
		music_player.stream = stream
		if loop and stream is AudioStreamOggVorbis:
			stream.loop = true
		music_player.volume_db = volume
		music_player.play()

func stop_music():
	music_player.stop()

func play_sfx(path: String, volume: float = -8.0):
	var stream = load(path)
	if stream:
		sfx_player.volume_db = volume
		sfx_player.stream = stream
		sfx_player.play()

func play_alarm():
	play_sfx("res://assets/audio/sfx/alarm.ogg")

func play_door():
	play_sfx("res://assets/audio/sfx/door_open.ogg", -15.0)

func play_collect():
	play_sfx("res://assets/audio/sfx/item_collect.ogg")

func play_correct():
	play_sfx("res://assets/audio/sfx/puzzle_correct.ogg")

func play_wrong():
	play_sfx("res://assets/audio/sfx/puzzle_wrong.ogg")

func play_ambient():
	play_music("res://assets/audio/music/ambient_loop.ogg", true, -20.0)

func play_menu():
	play_music("res://assets/audio/music/menu_theme.ogg", true, -5.0)
	
func play_mroom():
	play_sfx("res://assets/audio/sfx/door_opening_closing.ogg")
	
func play_boot():
	play_sfx("res://assets/audio/sfx/pc_boot.ogg")

func play_puzzle():
	play_sfx("res://assets/audio/sfx/puzzle_start.ogg")

func play_sequence():
	play_sfx("res://assets/audio/sfx/sequence_correct.ogg")

func play_win():
	play_sfx("res://assets/audio/sfx/puzzle_win.ogg")

func play_success():
	play_sfx("res://assets/audio/sfx/success.ogg", -15.0)

func play_vazfix():
	play_sfx("res://assets/audio/sfx/vazamento_fix.ogg", -15.0)
