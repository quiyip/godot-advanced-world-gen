extends Node2D


onready var chunk_manager = $ChunkManager
onready var biome_list = $UI/WorldGenSettings/MarginContainer/VBoxContainer/BiomeList
onready var camera = $Camera


func _ready() -> void:
	randomize()
	chunk_manager.height_map.octaves = $UI/WorldGenSettings/MarginContainer/VBoxContainer/TabContainer/Height/Octaves/OctavesSlider.value
	chunk_manager.height_map.period = $UI/WorldGenSettings/MarginContainer/VBoxContainer/TabContainer/Height/Period/PeriodSlider.value
	chunk_manager.height_map.persistence = $UI/WorldGenSettings/MarginContainer/VBoxContainer/TabContainer/Height/Persistence/PersistenceSlider.value
	chunk_manager.height_map.seed = randi()


func _on_GenerateButton_pressed() -> void:
	chunk_manager.generate()


func _on_ExpandArrow_gui_input(event) -> void:
	if event is InputEventMouseButton and event.pressed:
		var expand_arrow = $UI/ExpandArrow
		var arrow_texture = $UI/ExpandArrow/ArrowTexture
		var world_gen_settings = $UI/WorldGenSettings
		if arrow_texture.flip_h:
			arrow_texture.flip_h = false
			world_gen_settings.show()
			expand_arrow.rect_position.x = 325
		else:
			arrow_texture.flip_h = true
			world_gen_settings.hide()
			expand_arrow.rect_position.x = -3


func _unhandled_input(event) -> void:
	if event is InputEventMouseMotion and Input.is_mouse_button_pressed(BUTTON_LEFT):
		camera.position -= event.relative * camera.zoom.length() * 0.707
		chunk_manager.view_updated = true
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_WHEEL_UP and camera.zoom.length() > 0.04:
			camera.zoom /= 1.1
			chunk_manager.view_updated = true
		elif event.button_index == BUTTON_WHEEL_DOWN and camera.zoom.length() < 4:
			camera.zoom *= 1.1
			chunk_manager.view_updated = true
