# old blue platform color in hex 000826

extends Spatial


onready var ruut = get_tree().get_root()

func _ready() -> void:
	pass
	
	var pleya_resourse = load("res://Player.tscn")
	var pleya = pleya_resourse.instance()
	pleya.translation.y = 20
	print(pleya)
	print(get_tree().get_root().get_children())
	print(get_tree().get_root().get_node('World'))
	get_tree().get_root().get_node('World').add_child(pleya)
#	get_tree().get_root().add_child(pleya)


func _process(delta):
	$FPSCounter.text = str(Engine.get_frames_per_second())
	
	if Input.is_action_just_pressed("ui_cancel"):
		print(get_tree().get_frame())
		get_tree().quit()
	
	if Input.is_action_just_pressed("ui_page_down"):
		print('gettree() ', get_tree())
		print('get_tree().get_root() ', get_tree().get_root())
		print('get_tree().get_current_scene() ', get_tree().get_current_scene())
		get_tree().reload_current_scene()
		
	
	if Input.is_action_just_pressed("annihilate_world"):
#		var platforms = ruut.get_node('World')
		var platforms = get_node('Platforms')
		var worldschildren = ruut.get_node('World').get_children()
		print('worlds children ', worldschildren)
		print('get_node("Platforms) ', get_node('Platforms'))
		print('self.get_node("Platforms) ', self.get_node('Platforms'))
		print('get_node("Platforms")', platforms)
		print('ruut.get_children ', ruut.get_children())
		
#		ruut.remove_child(platforms)
		remove_child(platforms)
		platforms.call_deferred("free")
		
		
#Note: Fetching absolute paths only works when the node is inside the scene tree (see is_inside_tree()).
#
#Example: Assume your current node is Character and the following tree:
#
#/root
#/root/Character
#/root/Character/Sword
#/root/Character/Backpack/Dagger
#/root/MyGame
#/root/Swamp/Alligator
#/root/Swamp/Mosquito
#/root/Swamp/Goblin
#
#Possible paths are:
#
#get_node("Sword")
#get_node("Backpack/Dagger")
#get_node("../Swamp/Alligator")
#get_node("/root/MyGame")

	
	
	if Input.is_action_just_pressed("ui_page_up"):
#		get_tree().get_root().play_custom_scene('World 002')
		
		get_tree().change_scene("res://World 010.tscn")
		
#		# Remove the current level
#		var ruut = get_tree().get_root()
##		var level = root.get_node("Level")
#		var level = ruut.get_node("World")
#		ruut.remove_child(level)
#		level.call_deferred("free")
#
#		# Add the next level
#		var next_level_resource = load("res://World 010.tscn")
#		var next_level = next_level_resource.instance()
#		ruut.add_child(next_level)

#	void play_custom_scene(scene_filepath: String) Plays the scene specified by its filepath.
#		get_tree().set_current_scene('World 002': Node) #no string should be Node
