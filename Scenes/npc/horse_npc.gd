extends Node2D

@export var lines: Array[String] = [
	"Welcome to the Strike Workshop!",
	"Thanks for giving me a voice :D",
	"Hope everyone is having a great day :3",
	"Here are some horse facts:"
]

@export var dialogue_sfx: Array[AudioStream]

const no_audio_line: Array[String] = [
	"Uh oh...Please assign me a voice SFX in the Inspector!"
]

#region Extra Dialogue
var horse_facts: Array[String] = [
	"Horses can’t breathe through their mouth",
	"Horses can sleep standing up",
	"Horses can rotate their ears nearly 180 degrees",
	"The earliest ancestor of the horse is estimated to have lived 55 million years ago",
	"Horses can run at over 50 MPH",
	"Horses are super buoyant due to the size of their lungs!",
	"Horses have the largest eyes of any land mammal",
	"An adult horse typically drinks 25 gallons (or more) of water every single day",
	"Horses can sense your fear through chemosignaling",
	"Horses have one less bone than humans do",
	"There are an estimated 58 to 60 million horses worldwide today",
	"Most domestic horses live between 25 and 30 years",
]
#endregion

var character_tween: Tween
var base_scale: Vector2
var base_rotation: float
var swish_direction := 1.0

func _ready() -> void:
	await get_tree().process_frame
	base_scale = scale
	base_rotation = rotation
	
	DialogueManager.letter_displayed.connect(_animate)
	if dialogue_sfx.size() == 0:
		DialogueManager.start_dialogue(global_position, no_audio_line, dialogue_sfx)
	else:
		DialogueManager.dialogue_finished.connect(_start_horse_facts)
		DialogueManager.start_dialogue(global_position, lines, dialogue_sfx)

func _animate() -> void:
	if character_tween and character_tween.is_running():
		character_tween.kill()
	
	swish_direction *= -1
	
	character_tween = create_tween()
	character_tween.set_parallel(true)
	
	character_tween.tween_property(
		self, "scale",
		base_scale * Vector2(1.15, 0.85), 0.06
	)
	
	character_tween.tween_property(
		self, "rotation",
		base_rotation + deg_to_rad(5 * swish_direction), 0.06
	)
	
	character_tween.chain().tween_property(
		self, "scale", base_scale, 0.12
	).set_trans(Tween.TRANS_BACK)
	
	character_tween.parallel().tween_property(
		self, "rotation", base_rotation, 0.12
	).set_trans(Tween.TRANS_BACK)

func _start_horse_facts():
	horse_facts.shuffle()
	DialogueManager.start_dialogue(global_position, horse_facts, dialogue_sfx)
