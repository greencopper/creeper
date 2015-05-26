creeper = {}

local damage = 2
local mobtalker_mod = minetest.get_modpath("mobtalker")

dofile(minetest.get_modpath("creeper").."/function.lua")

-- entity setting
minetest.register_entity("creeper:creeper",{
	hp_max = 20,
	physical = true,
	collisionbox = {-0.3,-0.7,-0.3, 0.3,0.8,0.3},
	visual = "mesh",
	mesh = "character.b3d",
	player_anim = 0,
	timer = 0,
	turn_timer = 0,
	vec = 0,
	yaw = 0,
	yawwer = 0,
	newyaw = 0,
	state = 1,
	jump_timer = 0,
	door_timer = 0,
	attacker = "",
	attacking_timer = 0,
	makes_footstep_sound = false,
	hurt = false,
	present_timer = 0,
	turn_speed = 0,
	turn = false,
	chase = false,
	hiss = false,
	-- MobTalker
	love = {},
	count = {},
	route = {},
	talk = false,
	on_activate = function(self,staticdata)
		self.anim = creeper_get_animation()
		self.object:setacceleration({x=0,y=-10,z=0})
		self.state = math.random(1,2)
		self.turn_speed = 0.1
		self.yaw = math.random(0,6) * math.random()
		self.visualx = 1
		self.object:set_properties({
			textures = {"creeper.png"},
			visual_size = {x=1, y=1},
		})
		if mobtalker_mod then
			mobtalker.setstatic(self,staticdata)
			mobtalker.register_name("creeper","Cupa")
		end
	end,
	on_step = function(self, dtime)
		if mobtalker_mod then
			if not self.talk then
				creeper_action(self, dtime)
			end
		else
			creeper_action(self, dtime)
		end
	end,
	on_punch = function(self,puncher)
		minetest.sound_play("creeper_hurt", {pos=self.object:getpos(), gain=1.5, max_hear_distance=6})
		self.object:set_hp(self.object:get_hp()-damage)
		if mobtalker_mod then
			mobtalker.punch(self,puncher)
		end
	end,
	on_rightclick = function(self,clicker)
		if mobtalker_mod then
			mobtalker.rightclick(self,clicker,"creeper","mobtalker_creeper")
		end
	end,
	get_staticdata = function(self)
		if mobtalker_mod then
			return mobtalker.savestatic(self)
		end
	end,
})
dofile(minetest.get_modpath("creeper").."/item.lua")
dofile(minetest.get_modpath("creeper").."/spawn.lua")
if mobtalker_mod then
	dofile(minetest.get_modpath("creeper").."/mobtalker.lua")
end
