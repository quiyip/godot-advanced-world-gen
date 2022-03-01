extends Node2D


var loaded_chunks: Dictionary = {}
export var chunk_size: int = 64

var height_map = OpenSimplexNoise.new()

var view_updated := true
var middle_screen_chunk_pos := Vector2.ZERO

onready var thread_pool = $ThreadPool


func _ready() -> void:
	#warning-ignore-all:return_value_discarded
	get_tree().connect("screen_resized", self, "_on_screen_resized")


func generate() -> void:
	pass


# Thank you, stackoverflow.com/users/174728/john-la-rooy
func spiral(X: int, Y: int) -> PoolVector2Array:
	var return_values: PoolVector2Array = []
	X = X + 1 >> 1
	Y = Y + 1 >> 1
	var x = 0
	var y = 0
	var d = 1
	var side = 1
	while x < X or y < Y :
		if abs(y) < Y:
			for i in range(x, x + side, d):
				x = i
				if abs(x) < X:
#					print(x, "\t", y)
					return_values.append(Vector2(x, y))
			x += d
		else:
			x += side
		if abs(x) < X:
			for i in range(y, y + side, d):
				y = i
				if abs(y) < Y:
#					print(x, "\t", y)
					return_values.append(Vector2(x, y))
			y += d
		else:
			y += side
		d = -d
		side = d - side
	return return_values


func _draw() -> void:
	for i in loaded_chunks.keys():
		draw_texture(loaded_chunks.get(i), i)


func _update_loaded_chunks() -> void:
	# Todo: add tag to thread result, so as to only load chunks with current generation settings
	for k in thread_pool.task_results.keys():
		loaded_chunks[k] = thread_pool.task_results.get(k)
		thread_pool.task_results.erase(k)
	
	if view_updated:
		view_updated = false
		
		thread_pool.lock_task_list()
		thread_pool.task_list.clear()
		
		var new_loaded_chunks: Dictionary = {}
		var viewport_transform_affine_inverse: Transform2D = get_viewport_transform().affine_inverse()
		var visible_area := Rect2(	viewport_transform_affine_inverse.get_origin(),
									get_viewport().size * viewport_transform_affine_inverse.get_scale())
		#print(viewport_transform_affine_inverse)
		#print(get_viewport_rect().size * viewport_transform_affine_inverse.get_scale())
		middle_screen_chunk_pos = ((visible_area.position + visible_area.size / 2) / chunk_size).floor()
		
		var spiral_coords = spiral(int(ceil(visible_area.size.x / chunk_size)) + 2, int(ceil(visible_area.size.y / chunk_size)) + 2)
		
		for i in spiral_coords.size():
			var new_chunk_pos = (spiral_coords[i] + middle_screen_chunk_pos) * chunk_size
			
			var recycled_chunk = loaded_chunks.get(new_chunk_pos)
			if recycled_chunk != null:
				new_loaded_chunks[new_chunk_pos] = recycled_chunk
			else:
				thread_pool.add_task(self, "generate_chunk", [new_chunk_pos], new_chunk_pos)
		
		thread_pool.unlock_task_list()
		
		loaded_chunks = new_loaded_chunks
	
	update()


func generate_chunk(chunk_pos: Vector2) -> ImageTexture:
	var img = Image.new()
	img.create(chunk_size, chunk_size, false, Image.FORMAT_RGBA8)
	img.lock()
	for i in chunk_size:
		for j in chunk_size:
			# Issues could occur if height_map is changed
			var height_level: float = height_map.get_noise_2d(chunk_pos.x + i, chunk_pos.y + j)
			if height_level < -0.07:
				img.set_pixel(i, j, Color.darkblue) 
			elif height_level < 0:
				img.set_pixel(i, j, Color.blue)
			elif height_level < 0.03:
				img.set_pixel(i, j, Color.wheat)
			elif height_level < 0.25:
				img.set_pixel(i, j, Color.olivedrab)
			elif height_level < 0.35:
				img.set_pixel(i, j, Color.darkgray)
			elif height_level < 0.45:
				img.set_pixel(i, j, Color.dimgray)
			elif height_level < 1:
				img.set_pixel(i, j, Color.white)
	img.unlock()
	var chunk_texture = ImageTexture.new()
	chunk_texture.create_from_image(img, Texture.FLAG_MIPMAPS)
	return chunk_texture


func _on_screen_resized() -> void:
	view_updated = true
