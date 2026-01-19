extends "res://npc/item.gd"

func interact(player):
	Global.has_staff_fire = true
	print("获得了火之魔法杖")
	super.interact(player)
