extends Reference
class_name ItemQueue
# Wrapper class for a Dictionary that allows you to use pop_front()
# This prevents you from having to use an Array, since pop_front() on large arrays is problematic for performance.

var item_list := {}
var item_keys: PoolIntArray = []
var item_id := 0

var item_list_changed := false


func pop_front():
	if item_list_changed:
		item_keys = item_list.keys()
		item_list_changed = false
	if item_list.size() > 0:
		var item_key = item_keys[item_keys.size() - item_list.size()]
		var return_val = item_list.get(item_key)
		#warning-ignore:return_value_discarded
		item_list.erase(item_key)
		return return_val
	else:
		return null


func size() -> int:
	return item_list.size()


func clear() -> void:
	item_list.clear()


func append(item) -> void:
	item_list[item_id] = item
	item_id += 1
	item_list_changed = true
