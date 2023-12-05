extends Control

#var sound = preload("res://sfx/Gravando (8).mp3")

var btns_state = {}

var btn_element = preload("res://scene/button.tscn")
var audiostream_element = preload("res://scene/sound.tscn")
var volume_bar_element = preload("res://scene/volume_bar.tscn")

var btns_dict = {}
var audiostream_dict = {}
var volume_bar_dict = {}

var streams_path = {
	4: "res://sfx/africa_sfx/vento.mp3",
	5: "res://sfx/africa_sfx/chuva.mp3",
	0: "res://sfx/africa_sfx/cigarra.mp3",
	1: "res://sfx/africa_sfx/grilo.mp3",
	9: "res://sfx/africa_sfx/falcao.mp3",
	2: "res://sfx/africa_sfx/hiena.mp3",
	6: "res://sfx/africa_sfx/gnu.mp3",
	7: "res://sfx/africa_sfx/girafa.mp3",
	8: "res://sfx/africa_sfx/gorila.mp3",
	10: "res://sfx/africa_sfx/rinonceronte.mp3",
	11: "res://sfx/africa_sfx/zebra.mp3",
	3: "res://sfx/africa_sfx/leao.mp3",
	12: "res://sfx/africa_sfx/tambor.mp3",
	13: "res://sfx/africa_sfx/Makambo.mp3",
}

# Called when the node enters the scene tree for the first time.
func _ready():
	set_btns_state(btns_state, streams_path)
	create_btns(streams_path, btns_dict)
	create_busses(streams_path)
	create_audiostreams_nodes(streams_path)
	mute_all_audiostreams(audiostream_dict)
	connect_busses_to_audiostreams(audiostream_dict)
	connect_btns(btns_dict, audiostream_dict, btns_state)
	create_volume_bar_nodes(streams_path)
	plug_audiostreams(audiostream_dict, streams_path)
	connect_volume_bar(audiostream_dict,volume_bar_dict)
	silence_audiostreams(audiostream_dict)
	
	print("all set")


func create_busses(_streams_path):
	print("creating busses")
	for index in len(_streams_path.keys()):
		AudioServer.add_bus()	
		
func connect_busses_to_audiostreams(_audiostream_dict):
	for index in len(_audiostream_dict.keys()):
		_audiostream_dict[index].bus = AudioServer.get_bus_name(index+1)

func create_btns(_streams_path, _btns_dict):
	print("creating buttons")
	for index in len(_streams_path.keys()):
		if index<=6:
			var sound_name = _streams_path[index].split("/", false)[3].split(".", false)[0]
			var btn = btn_element.instantiate()
			btn.text = sound_name
			_btns_dict[index] = btn
			$MainContainer/VBoxContainer/btns_box.add_child(btn)
		else:
			var sound_name = _streams_path[index].split("/", false)[3].split(".", false)[0]
			var btn = btn_element.instantiate()
			btn.text = sound_name
			_btns_dict[index] = btn
			$MainContainer/VBoxContainer2/btns_box2.add_child(btn)
		
		
func create_audiostreams_nodes(_streams_path):
	print("creating audiostreams nodes")
	for index in len(streams_path.keys()):
		var soundstream = audiostream_element.instantiate()
#		soundstream.bus = 
		$".".add_child(soundstream)
		audiostream_dict[index] = soundstream
		
func create_volume_bar_nodes(_streams_path):
	print("creating volume bar nodes")
	for index in len(streams_path.keys()):
		if index<=6:
			var volume_bar = volume_bar_element.instantiate()
			$MainContainer/VBoxContainer/volume_bar_box.add_child(volume_bar)
			volume_bar_dict[index] = volume_bar
		else:
			var volume_bar = volume_bar_element.instantiate()
			$MainContainer/VBoxContainer2/volume_bar_box2.add_child(volume_bar)
			volume_bar_dict[index] = volume_bar

func set_btns_state(_btns_state, _streams_path):
	print("setting buttons states")
	for index in len(_streams_path.keys()):
#		print(_btns_state[index])
		_btns_state[index] = false

func mute_all_audiostreams(_audiostream_dict):
	print("silencing audiostreams nodes")
	for index in len(_audiostream_dict.keys()):
		set_volume(index, 0)
	

func set_volume(btn_number, volume_db):
	AudioServer.set_bus_volume_db(
			btn_number+1,
			linear_to_db(volume_db)
	)

func on_btn_pressed(btn_number, _audiostream, _btns_state, _btns_dict):
		if _btns_state[btn_number]:
			_btns_state[btn_number] = false
			_btns_dict[btn_number].modulate = Color(1, 1, 1, 1)
			_audiostream.stop()
		else:
			_btns_dict[btn_number].modulate = Color(0, 1, 0, 1)
			_btns_state[btn_number] = true
			_audiostream.play()
			
func connect_stream(audiostream_number, _audiostream_dict, _streams_paths):
	_audiostream_dict[audiostream_number].stream = load(_streams_paths[audiostream_number])

	
func plug_audiostreams(_audiostream_dict, _streams_path):
	print("connecting the streams to the audiostreams")
	for index in _audiostream_dict.keys():
		connect_stream(index, _audiostream_dict, _streams_path)

func connect_btns(_btns_dict, _audiostream_dict,_btns_state):
	print("connecting btns nodes to the audiostreams nodes")
	for index in _btns_dict.keys():
		_btns_dict[index].pressed.connect(on_btn_pressed.bind(index, _audiostream_dict[index], _btns_state, _btns_dict))

func connect_volume_bar(_audiostream_dict, _volume_bar_dict):
	print("connecting volume bars")
	for index in volume_bar_dict.keys():
#		volume_bar_dict[index].value_changed.connect(on_change_volume.bind(index,_audiostream_dict[index], _volume_bar_dict[index]))
		volume_bar_dict[index].value_changed.connect(on_change_volume.bind(index, _audiostream_dict[index]))
	
func on_change_volume(value,index, _audiostream):
	AudioServer.set_bus_volume_db(
		index+1,
		linear_to_db(value)
	)
	
func silence_audiostreams(_audiostream_dict):
	for index in _audiostream_dict:
		_audiostream_dict[index].volume_db = -20


#func dir_contents(path):
#	var dir = DirAccess.open(path)
#	if dir:
#		dir.list_dir_begin()
#		var file_name = dir.get_next()
#		while file_name != "":
#			if dir.current_is_dir():
#				print("Found directory: " + file_name)
#			else:
#				print("Found file: " + file_name)
#			file_name = dir.get_next()
#	else:
#		print("An error occurred when trying to access the path.")
		
