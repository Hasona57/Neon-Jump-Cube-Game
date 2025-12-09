extends Node

@onready var player: AudioStreamPlayer = AudioStreamPlayer.new()

func _ready():
	add_child(player)
	player.autoplay = true

	var stream = preload("res://music/cyberpunk-metaverse-event-background-music-391980.mp3")

	# Enable looping on the audio stream
	if stream is AudioStreamMP3:
		stream.loop = true

	player.stream = stream
	player.volume_db = -5
	player.play()
