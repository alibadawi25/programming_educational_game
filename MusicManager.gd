extends Node

@onready var music_player: AudioStreamPlayer = AudioStreamPlayer.new()

# Volume control (0 = mute, 100 = max)
var volume_percentage: int = 80  # Default to 80%
var is_muted: bool = false  # Mute toggle
var previous_volume: int = volume_percentage  # Stores last volume before muting

# Min and max volume in decibels
const MIN_DB = -80  # Mute
const MAX_DB = 6    # Max volume (6 dB higher)
const MID_DB = -15  # The boundary point between two mappings

func _ready():
	# Add the AudioStreamPlayer to the scene tree
	add_child(music_player)
	music_player.bus = "Music"  # Ensure it's on the correct audio bus
	music_player.stream = preload("res://game_music.mp3")  # Replace with your music file
	set_volume(volume_percentage)  # Apply initial volume (80%)
	music_player.play()

func play_music(music_path: String):
	if music_player.stream and music_player.stream.resource_path == music_path:
		return  # Avoid restarting the same music if it's already playing
	music_player.stream = load(music_path)
	music_player.play()

func stop_music():
	music_player.stop()

func toggle_mute():
	if is_muted:
		# Unmute and restore previous volume
		is_muted = false
		set_volume(previous_volume)
	else:
		# Save the current volume before muting
		previous_volume = volume_percentage
		is_muted = true
		music_player.volume_db = MIN_DB  # Mute audio

func set_volume(percentage: int):
	# Ensure the percentage is between 0 and 100
	volume_percentage = clamp(percentage, 0, 100)

	# If unmuted, apply volume change
	if not is_muted:
		music_player.volume_db = _convert_percentage_to_db(volume_percentage)

func _convert_percentage_to_db(percentage: int) -> float:
	# If the percentage is 0-30, map between -80 dB and -10 dB
	if percentage <= 30:
		var normalized_percentage = percentage / 30.0  # Normalize to 0 to 1
		# Map from -80 dB at 0% to -10 dB at 30%
		return lerp(MIN_DB, MID_DB, normalized_percentage)
	# If the percentage is 30-100, map between -10 dB and 6 dB
	else:
		var normalized_percentage = (percentage - 30) / 70.0  # Normalize to 0 to 1 for 30-100 range
		# Map from -10 dB at 30% to 6 dB at 100%
		return lerp(MID_DB, MAX_DB, normalized_percentage)
