extends Tree


var tree_item_biomes: TreeItem = create_item()
var tree_item_sea: TreeItem = create_item(tree_item_biomes)
var tree_item_land: TreeItem = create_item(tree_item_biomes)

var default_font: Font


func _ready() -> void:
	tree_item_biomes.set_text(0, "Biomes")
	tree_item_biomes.set_selectable(0, false)
	tree_item_sea.custom_minimum_height = 16
	tree_item_sea.set_text(0, "Sea")
	tree_item_sea.set_selectable(0, false)
	tree_item_land.custom_minimum_height = 16
	tree_item_land.set_text(0, "Land")
	tree_item_land.set_selectable(0, false)
	default_font = Control.new().get_font("font")
	_create_biome("deep_ocean", "sea", Color.darkblue)
	_create_biome("ocean", "sea", Color.blue)
	_create_biome("beach", "land", Color.wheat)
	_create_biome("plains", "land", Color.olivedrab)
	_create_biome("mountains", "land", Color.darkgray)
	_create_biome("high_mountains", "land", Color.dimgray)
	_create_biome("snowy_mountains", "land", Color.white)


func _create_biome(name: String, biome_type: String, color: Color) -> void:
	var new_tree_item
	match biome_type:
		"sea":
			new_tree_item = create_item(tree_item_sea)
		"land":
			new_tree_item = create_item(tree_item_land)
	new_tree_item.custom_minimum_height = 24
	new_tree_item.set_cell_mode(0, TreeItem.CELL_MODE_CUSTOM)
	new_tree_item.set_custom_draw(0, self, "_draw_biome_tree_item")
	var metadata_array: Array = [name, color]
	new_tree_item.set_metadata(0, metadata_array)


func _draw_biome_tree_item(tree_item: TreeItem, tree_item_rect: Rect2) -> void:
	var metadata_array: Array = tree_item.get_metadata(0)
	draw_rect(Rect2(tree_item_rect.position + Vector2(4, 4), Vector2(24, 24)), metadata_array[1])
	draw_string(default_font, tree_item_rect.position + Vector2(36, 20), metadata_array[0])
