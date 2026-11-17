extends Node2D

@onready var text_box_scene = preload("res://Scenes/text box/text_box.tscn")

var dialogue_lines: Array[String] = []
var current_line_index = 0

var text_box
var text_box_position: Vector2

var sfx: Array[AudioStream]

var is_dialogue_active = false
var can_advance_line = false

signal letter_displayed()
signal dialogue_finished()

func start_dialogue(pos: Vector2, lines: Array[String], speech_sfx: Array[AudioStream]):
	if is_dialogue_active:
		return
	
	dialogue_lines = lines
	sfx = speech_sfx
	text_box_position = pos
	_show_text_box()
	
	is_dialogue_active = true

func _show_text_box():
	# Spawns and displays textbox
	text_box = text_box_scene.instantiate()
	text_box.finished_displaying.connect(_on_text_finished)
	text_box.letter_displayed.connect(_handle_letter_display)
	get_tree().root.add_child(text_box)
	text_box.global_position = text_box_position
	text_box.display_text(dialogue_lines[current_line_index], sfx)
	can_advance_line = false

func _on_text_finished():
	can_advance_line = true

func _unhandled_input(event: InputEvent) -> void:
	# Handles advacing to the next dialogue line
	if (event.is_action_pressed("ui_accept") && is_dialogue_active && can_advance_line):
		text_box.queue_free()
		current_line_index += 1
		if current_line_index >= dialogue_lines.size():
			is_dialogue_active = false
			current_line_index = 0
			dialogue_finished.emit()
			return
		
		_show_text_box()

func _handle_letter_display():
	letter_displayed.emit()
