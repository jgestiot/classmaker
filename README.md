Important
---------
The features and scripts folders must be created in user:// 
For those using Windows, the path to that folder will be C:\Users\<your user name>>\AppData\Roaming\Godot\app_userdata\classmaker\features. Once you create a script using ClassMaker, it will be found in user://scripts or C:\Users\<your user name>>\AppData\Roaming\Godot\app_userdata\classmaker\scripts. Make sure user://features has the same content as res://features or else you will have no content to play with.

Introduction
------------

ClassMaker is a tool that was built to help in a project that had a lot of vehicles including cars, boats, planes, helicopters and so on. Initially, I tried to construct classes that inherited the necessary features but because Godot does not support multiple inheritance, which is what I needed, I quickly got bogged doww.

I started to think outside the box and I came up with ClassMaker, which is not a full-on utility but just a hack which I release in case it helps someone else.

Whatever object exists in your application, it has properties and methods. I called the combination of both properties and methods a set of "features." A feature is the combination of variables and methods that bring something very specific to the object and nothing else. ClassMaker allows you to choose from a features list to generate your classes. For example a class plane will have features such as can_move, can_climb, can_take_off, burns_fuel and so on. Once you tick all the plane's features, you are ready to generate the plane class.

Examples
--------
 
Note that this example deals with vehicles that are moved by timer on a map so there is no physics in the features provided as example. It should also be noted that the features provided are just examples and not meant to be used in your game. You have permission to use the code in your game but doing so without modifications is not going to get you far. 

Let's take an object that:

- exists
- has an ID
- is of a certain type
- has a position
- detects collisions

To create this object with classmaker, you would pick the following features from the list provided to you as example:

- has_id
- has_type
- has_position
- can_collide

Multi-selecting the four features above in ClassMaker's list, setting the class to "port" and extends to "Node2D" will produce the following class:

-------------------------- port.gd script -----------------------------
extends Node2D

class_name port

var data

func _init()->void:
	data = {}
	data.id = 0			# An id that can be assigned externally
	data.type = 0		# The type of object we are
	data.x = 0			# current x position for the object
	data.y = 0			# current y position for the object

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


# loads a previously saved data dictionary
func load_data(saved_data)->void:
	data = saved_data

# returns the class data to the calling function for saving
# later the data can be restored with load_data()
func save_data():
	return data
-----------------------------------------------------------------------

The feature "exists" is built in and it is always part of the core for every class created by ClassMaker. It creates an _init() function with the line: data = {}, which is creating the dictionary that will hold all variables for the class. This is useful for saving and later loading objects. See the can_be_saved feature.

Feature files
-------------
 Feature files are essentially GDscript files with a small difference. A function declaration must be as follows:
 func <function signature> <keyword>
 Where the keyword is "create" or "append" to define how the function will be integrated into the class. If you have something like:
 func shoot()->void: create
	pass
it means the function shoot() will overwrite any shoot() function that may have been previously defined by another feature. if you have:
 func shoot()->void: append
	pass
It means that if the shoot() function has already been defined, the code "pass" will be appended to the existing function.

Needless to say that none of your features can have the following:
func _init(): create
Because it would overwrite essential core code as explained above. Instead, always append to the _init() function.

A feature file can contain any number of functions. It can also have any variables as long as they are part of the data dictionary and iitialised in _init().

It is desirable to break down features into the smallest possible unit of functionality possible. Make sure each of your features have a single area of responsibility. Do not load feature files with spaghetti code. What makes the strength of ClassMaker is the ability to combine many different features into one class. don't hesitate to break your features into single focus files like can_move, can_stop, can_eat, can_reverse, can_cry, can_explode, has_health and so on.

You may have a number of feature folders and activate one at a time. It is a bit like having a library of code you may re-use in different classes. You may have one folder for props, another for vehicles, another for characters and copy the content of the one you need to use to user://features. When you run ClassMaker, it retrieves te content of the itemlist from feature_list.txt in user://features. Do not forget to create user://features and user://scripts before you start using ClassMaker.

A <script name>.features file is also created in user://scripts. It lists the features selected for the class.

Note about comments
-------------------
If you wish to have comments included in your features, you must do it as follows:

# This is a comment
# It documents the function
# There cannot have spaces between
# the comment and the function
func my_function()->void: create
	var code = true			# this comment will be preserved
	# this comment will be stripped
	code = false
