extends Node3D


@onready var main_menu = $CanvasLayer/MainMenu
@onready var address_entry = $CanvasLayer/MainMenu/MarginContainer/VBoxContainer/AddressEntry

const PORT = 9999
var enet_peer = ENetMultiplayerPeer.new()

const player_scene = preload("res://scenes/player/player.tscn")

var peer_mapping: Dictionary = {}

func _unhandled_input(event):
	if Input.is_action_just_released("ui_cancel"):
		get_tree().quit()


func _on_host_button_button_up():
	main_menu.hide()
	
	enet_peer.create_server(PORT)
	
	multiplayer.multiplayer_peer = enet_peer
	
	multiplayer.peer_connected.connect(add_player)
	
	var host_id = multiplayer.get_unique_id()
	self.add_player(host_id)
	
	self.upnp_setup()


func _on_join_button_button_up():
	main_menu.hide()
	
	enet_peer.create_client(address_entry.text, PORT)
	multiplayer.multiplayer_peer = enet_peer

func add_player(peer_id):
	var new_player = player_scene.instantiate()
	new_player.name = str(peer_id)
	self.add_child(new_player)


func upnp_setup():
	var upnp = UPNP.new()
	
	var discover_result = upnp.discover()
	assert(discover_result == UPNP.UPNP_RESULT_SUCCESS, \
		"UPNP Discover Failed! Error %s" % discover_result)

	assert(upnp.get_gateway() and upnp.get_gateway().is_valid_gateway(), \
		"UPNP Invalid Gateway!")

	var map_result = upnp.add_port_mapping(PORT)
	assert(map_result == UPNP.UPNP_RESULT_SUCCESS, \
		"UPNP Port Mapping Failed! Error %s" % map_result)
	
	print("Success! Join Address: %s" % upnp.query_external_address())
		
	
	
