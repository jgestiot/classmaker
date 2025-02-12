extends Node2D

var debug = false

var scriptname
var extending
var classname
var comments = []
var functions = {}

# ClassMaker is an attempt to create objects based on the multiple features
# The features list in user://features/feature_list.txt
# Each of its lines will be loaded into the itemlist $list. The lines have the
# following format:
# feature<space>text
# The text can be anything that helps you decide which feature to pick. Example:
# can_collide [can identify self during a collision -  req has_id ]
# The above lines says that the code for the feature will be retrieved from the
# file can_collide.txt, what it does and what are the pre-requisites. In this
# case, can_collide.txt requires the feature has_id.txt to be enabled.
# All feature files are stored in user://features the same folder that also has
# the feature_list.txt file. This means that each feature folder is independent
# with any number of feature files.
#
# Understanding the feature files.
#
# Each feature file has code that will be integrated into the final class.
# The difference with normal code is in a keyword that follows each function
# definition. For example:
# func _init()->void: append
# This line says that the _init() function should be appended to if it has
# already been defined by another feature. If the keyword has been "create" it
# would mean that _init() should be created rather than appended to.
# This is useful to override functions. If a feature has the same function as \
# another but it is more complete, it can replace the function of the same name.
# Important: there cannot be a space in the function's signature. For example:
# func move(distance: int , speed: int)->void: create
# Instead, it should be:
# func move(distance:int,speed:int)->void: create
#
#
func _ready() -> void:
	var line
	scriptname = $scriptname.text
	classname = $classname.text
	extending = $extending.text
	var handle = FileAccess.open("user://features/feature_list.txt", FileAccess.READ)
	if handle == null:
		return
	$list.clear()
	while(handle.eof_reached() == false):
		line = get_line(handle)
		if(debug):
			print(line)
		if(line.length() > 10):
			$list.add_item(line)


# every file has this code because each rely on the data dictionary initialised
# in _init()
func create_core_code():
	if(scriptname == null):
		print("Script name missing")
		return false

	if(extending == null):
		print("extending is missing")
		return false

	if(classname == null):
		print("Classname is missing")
		return false

	# injects the _init() function that will init the dictionary
	functions["_init"] = {}
	functions["_init"].comments = []
	functions["_init"].signature = "_init()->void:"
	functions["_init"].data = []
	functions["_init"].data.append("	data = {}			# the data dict where all variables are kept")
	return true

func output_all():
	var function_list = FileAccess.open("user://scripts/"+scriptname+".functions", FileAccess.WRITE)
	var feature_list = FileAccess.open("user://scripts/"+scriptname+".features", FileAccess.WRITE)
	var handle = FileAccess.open("user://scripts/"+scriptname+".gd", FileAccess.WRITE)
	if(handle == null):
		print("Failed to create script file");
		return
	handle.store_line("extends "+extending)
	handle.store_line("")
	handle.store_line("class_name "+classname)
	handle.store_line("")

	handle.store_line("var data")
	handle.store_line("")

	# now loops through list items
	var next
	var space
	for n in $list.get_selected_items():
		next = $list.get_item_text(n)
		space = next.findn(" ")
		if(space):
			next = next.left(space)
			if(debug):
				print("Processing ferature "+next)
			feature_list.store_line(next)
			process_feature(next)
		else:
			print("Error in line "+next)

	for z in functions:
		if(debug):
			print("Outputting "+z)
		function_list.store_line(z)
		for k in functions[z].comments: # output all comments that may have been collected
			handle.store_line(k)
		handle.store_line("func "+functions[z].signature)
		for k in functions[z].data:
			handle.store_line(k)
		handle.store_line("")

	handle.close() # flushes all output
	feature_list.close()
	function_list.close()
	print("Done!")

func _on_generate_btn_pressed() -> void:
	if(create_core_code()):
		output_all()


# when the name of the script is changed
func _on_scriptname_text_changed(new_text: String) -> void:
	scriptname = $scriptname.text

func _on_extending_text_changed(new_text: String) -> void:
	extending = $extending.text

func _on_classname_text_changed(new_text: String) -> void:
	classname = $classname.text

func process_feature(name):
	var function
	var idx
	var mode
	var line
	var flag
	var exists
	var current # the current function we are parsing
	var handle = FileAccess.open("user://features/"+name+".txt", FileAccess.READ)
	if(handle == null):
		print("Failed to open "+name+" file");
		return
	current = ""
	while(handle.eof_reached() == false):
		line = get_line(handle)
		if(debug):
			print(line)
		if(line.length() > 4) && (line.left(4) == "func"):
			flag = false
			if(debug):
				print("Function has been found")
			line = line.split(" ",false)
			if(debug):
				print(line)
			if(line.size() != 3):
				print("There is an error in line: "+str(line[1])+" (feature: "+name+") Missing keyword?")
				return
			idx = line[1].findn("(")
			current = line[1].left(idx)
			if(debug):
				print("Function is "+current)
			function = {}
			function.comments = comments # transfer comments
			function.signature = line[1]
			function.data = []
			mode = (line[2] == "create")
			if(debug):
				print(function)
			exists = functions.has(current)
			if(!exists): # if the function does not exist we automatically create it
				flag = true
			else:
				if(mode):
					flag = true
			if(flag):
				functions[current] = function
				comments = [] # reset comments for next function
		else:
			functions[current].data.append(line)
			pass




func get_line(handle):
	var str
	var is_comment # we strip comments
	while(handle.eof_reached() == false):
		str = handle.get_line()	# get the next line
		if(is_comment(str)):
			if(debug):
				print("Comment found: "+str)
			if(comments == null):
				comments = []
			comments.append(str) # collects comments
			continue

		str = str.lstrip(" ")	# strip leading spaces
		if(str.length()):
			return str
	return "" # must!


func is_comment(line):
	line = line.lstrip(" 	")
	if(line.length()):
		if(line.left(1) == "#"):
			return true
	return false

func output_functions(handle):
	print("### Outputting functions")
	print(functions)
	for n in functions:
		for z in functions[n].comments: # output all comments that may have been collected
			handle.write(z)
		handle.write("func "+functions[n].signature)
		for k in functions[n].data:
			print(k)
