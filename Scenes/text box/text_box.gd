extends MarginContainer

@onready var label: Label = $MarginContainer/Label
@onready var timer: Timer = $LetterDisplayTimer
@onready var audio_player: AudioStreamPlayer2D = $AudioStreamPlayer2D

const MAX_WIDTH = 300
var init_scale

var text = ""
var letter_index = 0

var sfx: Array[AudioStream]

var letter_time = 0.03
var space_time = 0.06
var punctuation_time = 0.2

signal finished_displaying()
signal letter_displayed()

func _ready() -> void:
	init_scale = scale
	scale = Vector2.ZERO

func display_text(text_to_display: String, speech_sfx: Array[AudioStream]):
	text = text_to_display
	sfx = speech_sfx
	label.text = text_to_display
	letter_index = 0
	
	# Resize textbox
	await resized
	custom_minimum_size.x = min(size.x, MAX_WIDTH)
	
	if size.x > MAX_WIDTH:
		label.autowrap_mode = TextServer.AUTOWRAP_WORD
		await resized # wait for x resize
		await resized # wait for y resize
		custom_minimum_size.y = size.y
	
	global_position.x += size.x / 10
	global_position.y -= size.y * init_scale.y
	
	label.text = ""
	
	# popup animation
	pivot_offset = Vector2(size.x / 5, size.y)
	var tween = get_tree().create_tween()
	tween.tween_property(
		self, "scale", init_scale, 0.15
	).set_trans(
		Tween.TRANS_BACK
	)
	
	_display_letter()

func _display_letter():
	# Displays text letter by letter
	label.text += text[letter_index]
	
	letter_index += 1
	if letter_index >= text.length():
		finished_displaying.emit()
		return
	
	# Set text delay
	match text[letter_index]:
		"!",".",",","?":
			timer.start(punctuation_time)
		" ":
			timer.start(space_time)
		_:
			timer.start(letter_time)
			letter_displayed.emit() # for animations, etc...
			
			if sfx.size() == 0:
				return
			# Audio only played on letters
			var new_audio = audio_player.duplicate()
			# randomize audio and pitch
			new_audio.stream = sfx.pick_random()
			new_audio.pitch_scale += randf_range(-0.1, 0.1)
			if text[letter_index] in ["a", "e", "o", "i", "u"]:
				new_audio.pitch_scale += 0.2
			get_tree().root.add_child(new_audio)
			new_audio.play()
			await new_audio.finished
			new_audio.queue_free()

func _on_letter_display_timer_timeout() -> void:
	_display_letter()
