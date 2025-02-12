extends Node2D

class_name my_class

var data

func _init()->void:
	data = {}			# the data dict where all variables are kept
	data.id = 0			# An id that can be assigned externally
	data.type = 0		# The type of object we are
	data.x = 0			# current x position for the object
	data.y = 0			# current y position for the object
	data.xdir = 0		# x direction for the movement
	data.ydir = 0		# y direction for the movement
	data.speed = 0		# number of pixels moved each time
	data.reached = false # indicates if destination is reached
	data.time_scale = 0.5
	data.pixels_per_km = 10
	data.min_x = 0
	data.min_y = 0
	data.max_x = 1200
	data.max_y = 600
	data.waypoints = []			# Array of Vector2
	data.damage = 0.0			# A value representing a %
	data.damage_threshold = 80	# The % of damage beyond which the object is considered destroyed

# Sets the ID for the object. the application decides what the
# id is for and if it is unique
func set_id(id)->void:
	data.id = id

# returns the object's id
func get_id()->int:
	return data.id


# sets the type for the object which is likely to be a constant
# like TYPE_CAR or TYPE_BOAT.
func set_type(type:int)->void:
	data.type = type

# returns the object's type
func get_type()->int:
	return data.type


# this function is meant to update the 2D object position on
# screen once its x,y position has been calculated.
func update_position():
	position.x = data.x
	position.y = data.y


# function called once the application is notified of a
# collision. In a 2D environment, the area is passed by
# signals such as area_entered. To know what object we
# are colliding with, we call area.who_are_you() and this
# function will provide both the id and the type of object.
func who_are_you()->Array:
	return [data.id,data.type]	# array identifying the object


func set_direction(x,y):
	data.xdir = x
	data.ydir = y

func set_pos(x,y):
	data.x = x
	data.y = y
	update_position()

func set_speed(s):
	data.speed = s

# when scale is present, the move takes into consideration both the
# physical and time scales.
func basic_move():
	data.x += data.xdir * data.pixels_per_km * data.time_scale * data.speed
	data.y += data.ydir * data.pixels_per_km * data.time_scale * data.speed


func move()->void:
	var flag_x = false
	var flag_y = false
	basic_move() # performs the basic move calculation
	if(data.x <= data.min_x): # check if outside the x boundary
		data.x = data.min_x
		flag_x = true
	if(data.y <= data.min_y): # check if outside the y boundary
		data.y = data.min_y
		flag_y = true
	if(data.x >= data.max_x): # check if we overrun the y boundary
		data.x = data.max_x
		flag_x = true
	if(data.y >= data.max_y): # check if we overrun the y boundary
		data.y = data.max_y
		flag_y = true
	if(flag_x):
		out_of_bounds_x()
		return
	if(flag_y):
		out_of_bounds_y()
		return
	update_position() # only update position on screen if we are within bounds

func goto(x,y)->void:
	if(data.x < x):
		data.xdir = 1
	elif data.x > x:
		data.xdir = -1
	else:
		data.xdir = 0
	if(data.y < y):
		data.ydir = 1
	elif data.y > y:
		data.ydir = -1
	else:
		data.ydir = 0
		if(data.xdir == 0 && data.ydir == 0):
			data.speed = 0
			data.reached = true
			reached_destination()
		else:
			data.reached = false
			move()

func is_moving():
	return data.speed != 0

func stop():
	data.xdir = 0
	data.ydir = 0
	data.speed = 0
	has_stopped()

func has_stopped():
	pass

func reached_destination():
	pass


func set_time_scale(amount:float)->void:
	data.time_scale = amount

func get_time_scale()->float:
	return data.time_scale

func set_pixels_per_km(amount:float)->void:
	data.pixels_per_km = amount

func get_pixels_per_km()->float:
	return data.pixels_per_km


# Called when the object is out of bounds in the x direction.
func out_of_bounds_x()->void:
	pass

# Called when the object is out of bounds in the y direction.
func out_of_bounds_y()->void:
	pass


func set_waypoints(ar:Array)->void:
	data.waypoints = ar

func getnext_waypoint()->Vector2:
	return data.waypoints

func append_waypoint(wayp:Vector2):
	data.waypoints.append(wayp)

func goto_waypoint()->void:
	if data.waypoints == null:
		return
	if data.waypoints.size() == 0:
		return
	goto(data.waypoints[0].x,data.waypoints[0].y)


# causes damage to the object.
# If the damage reaches the threshold then the object is considered destroyed
# and the hook function has_been_destroyed() is called
func cause_damage(amount:float)->void:
	data.damage+=amount
	if(data.damage >= data.damage_threshold):
		has_been_destroyed()
		data.damage = data.damage_threshold

func repair(amount:float)->void:
	data.damage-=amount
	if(data.damage < 0):
		data.damage = 0

func has_been_destroyed()->void:
	pass

# loads a previously saved data dictionary
func load_data(saved_data)->void:
	data = saved_data

# returns the class data to the calling function for saving
# later the data can be restored with load_data()
func save_data():
	return data
