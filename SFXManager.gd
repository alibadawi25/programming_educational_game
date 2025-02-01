extends Node

# Volume control (0 = mute, 100 = max)
var volume_percentage: int = 80  # Default to 80%
var is_muted: bool = false  # Mute toggle
var previous_volume: int = volume_percentage  # Stores last volume before muting

# Min and max volume in decibels
const MIN_DB = -80  # Mute
const MAX_DB = 6    # Max volume (6 dB higher)
const MID_DB = -15  # The boundary point between two mappings

func _ready():
	# Set initial volume using the audio bus 'SFX'
	set_volume(volume_percentage)

func toggle_mute():
	if is_muted:
		# Unmute and restore previous volume
		is_muted = false
		set_volume(previous_volume)
	else:
		# Save the current volume before muting
		previous_volume = volume_percentage
		is_muted = true
		set_volume(0)  # Mute audio (0% volume)

func set_volume(percentage: int):
	# Ensure the percentage is between 0 and 100
	volume_percentage = clamp(percentage, 0, 100)

	# If unmuted, apply volume change to the SFX bus
	if not is_muted:
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), _convert_percentage_to_db(volume_percentage))
	else:
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), MIN_DB)

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
