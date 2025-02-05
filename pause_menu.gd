extends Control

@onready var world = $"../../"
@onready var main_panel = $MainPanel
@onready var settings_panel = $SettingsPanel

# Music Volume Controls
@onready var h_slider = $"SettingsPanel/Music-volume/HSlider"
@onready var audio_on_off_button = $"SettingsPanel/Music-volume/HSlider/AudioOnOffButton"
@onready var audio_sprites = $"SettingsPanel/Music-volume/HSlider/AudioOnOffButton/AudioSprites"

# SFX Volume Controls
@onready var sfx_slider = $"SettingsPanel/SFX-volume/HSlider"
@onready var sfx_audio_on_off_button = $"SettingsPanel/SFX-volume/HSlider/AudioOnOffButton"
@onready var sfx_audio_sprites = $"SettingsPanel/SFX-volume/HSlider/AudioOnOffButton/AudioSprites"

# Managers
@onready var music_manager = get_node("/root/MusicManager")  # Ensure MusicManager is in the scene tree
@onready var sfx_manager = get_node("/root/SFXManager")  # Ensure SFXManager is in the scene tree

func _ready():
	hide()  # Hide menu at the start

	# Initialize Music Slider
	h_slider.value = music_manager.volume_percentage
	update_audio_button()

	# Initialize SFX Slider
	sfx_slider.value = sfx_manager.volume_percentage
	update_sfx_audio_button()

	# Connect signals for Music
	h_slider.value_changed.connect(_on_music_slider_changed)
	audio_on_off_button.pressed.connect(_on_music_mute_pressed)

	# Connect signals for SFX
	sfx_slider.value_changed.connect(_on_sfx_slider_changed)
	sfx_audio_on_off_button.pressed.connect(_on_sfx_mute_pressed)

func _input(event):
	if event.is_action_pressed("ui_cancel"):  # Default "Esc" key
		toggle_pause()

func toggle_pause():
	if visible and world.paused:
		world.paused = false
		visible = false
		world.ui_ux.show()
	elif not visible and not world.paused:
		world.paused = true
		settings_panel.visible = false
		main_panel.visible = true
		visible = true
		world.ui_ux.hide()

func _on_resume_pressed():
	toggle_pause()

func _on_quit_pressed():
	var coordinates = "800 400"
	var filedata = coordinates + "\n" + str(world.is_first_time_playing) + "\n" + str(world.is_tutorial) + "\n" + str(world.coins) + "\n" + str(world.level)+ "\n" + str(world.level_part)
	var file = FileAccess.open("user://data.txt", FileAccess.WRITE)
	if file:
		file.store_line(filedata)  # This will overwrite the file content
		file.close()  # Always close the file when done
	else:
		print("Failed to open file.")
	get_tree().quit()

func _on_settings_pressed():
	main_panel.visible = false
	settings_panel.visible = true

func _on_back_pressed():
	main_panel.visible = true
	settings_panel.visible = false

# 🎵 MUSIC HANDLING 🎵
func _on_music_slider_changed(value: float):
	"""Adjusts music volume when slider value changes"""
	music_manager.set_volume(int(value))  # Convert float to int (0-100)
	update_audio_button()

func _on_music_mute_pressed():
	"""Mutes/unmutes music when button is pressed"""
	music_manager.toggle_mute()
	h_slider.value = 0 if music_manager.is_muted else music_manager.volume_percentage
	update_audio_button()

func update_audio_button():
	"""Updates music mute button icon based on volume"""
	if music_manager.is_muted or music_manager.volume_percentage == 0:
		audio_sprites.animation = "Audio-off" 
	else:
		audio_sprites.animation = "Audio-on"

func _on_h_slider_drag_ended(value_changed):
	if value_changed:
		_on_music_slider_changed(h_slider.value)

# 🔊 SFX HANDLING 🔊
func _on_sfx_slider_changed(value: float):
	"""Adjusts SFX volume when slider value changes"""
	sfx_manager.set_volume(int(value))  # Convert float to int (0-100)
	update_sfx_audio_button()

func _on_sfx_mute_pressed():
	"""Mutes/unmutes SFX when button is pressed"""
	sfx_manager.toggle_mute()
	sfx_slider.value = 0 if sfx_manager.is_muted else sfx_manager.volume_percentage
	update_sfx_audio_button()

func update_sfx_audio_button():
	"""Updates SFX mute button icon based on volume"""
	if sfx_manager.is_muted or sfx_manager.volume_percentage == 0:
		sfx_audio_sprites.animation = "Audio-off"
	else:
		sfx_audio_sprites.animation = "Audio-on"


func _on_sfx_h_slider_drag_ended(value_changed):
	if value_changed:
		_on_sfx_slider_changed(sfx_slider.value)
