extends Node


var threads: Array = _create_pool()
var thread_sleep := Semaphore.new()

var task_list = ItemQueue.new()
var task_list_lock := Mutex.new()

var task_results: Dictionary


func _create_pool() -> Array:
	var pool := []
	for _i in 1:
	#for _i in max(OS.get_processor_count(), 1):
		var new_thread = Thread.new()
		pool.append(new_thread)
		new_thread.start(self, "_execute_tasks")
	return pool


func get_thread_count() -> int:
	return threads.size()


# !!! MUST MANUALLY LOCK TASK LISTS BEFORE CALLING !!! 
# !!! CALLING THIS FUNCTION WITHOUT LOCKING CAN RESULT IN UNDEFINED BEHAVIOUR !!!
#
# CORRECT USAGE:
#
# onready var thread_pool = $ThreadPool
#
# thread_pool.lock_task_list()
# thread_pool.add_task( ... )
# thread_pool.unlock_task_list()
#
func add_task(instance: Object, method: String, arguments := [], tag = null) -> void:
	task_list.append([self, instance, method, arguments, tag])


func lock_task_list() -> void:
	task_list_lock.lock()


func unlock_task_list() -> void:
	task_list_lock.unlock()
	#warning-ignore:return_value_discarded
	thread_sleep.post()


func _execute_tasks() -> void:
	while true:
		#warning-ignore:return_value_discarded
		thread_sleep.wait()
		while true:
			task_list_lock.lock()
			var task = task_list.pop_front()
			task_list_lock.unlock()
			if task != null:
				var task_result = task[1].callv(task[2], task[3])
				task[0].call_deferred("_finish_task", task[4], task_result)
			else:
				break


func _finish_task(tag, task_result) -> void:
	if tag != null:
		task_results[tag] = task_result
