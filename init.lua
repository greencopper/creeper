creeper = {}
local damage = 2
if minetest.get_modpath("mobtalker") then
	creeper_talk = {}
	creeper_talking = {}
	creeper_love = {}
end
dofile(minetest.get_modpath("creeper").."/function.lua")

-- entity setting
minetest.register_entity("creeper:creeper",{
	hp_max = 20,
	physical = true,
	collisionbox = {-0.3,-0.7,-0.3, 0.3,0.8,0.3},
	visual = "mesh",
	mesh = "creeper.b3d",
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
	on_activate = function(self)
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
	end,
	on_rightclick = function(self,clicker)
		if minetest.get_modpath("mobtalker") and clicker:get_wielded_item():get_name() == "mobtalker:mobtalker" then
			mobtalker_creeper(self,clicker)
		elseif minetest.setting_getbool("creative_mode") then
			mobtalker_creeper(self,clicker)
		end
	end,
	on_punch = function(self,puncher)
		minetest.sound_play("creeper_hurt", {pos=self.object:getpos(), gain=1.5, max_hear_distance=6})
		self.object:set_hp(self.object:get_hp()-damage)
		if minetest.get_modpath("mobtalker") then
			creeper_talking[puncher:get_player_name()] = false
			creeper_love[puncher:get_player_name()] = creeper_love[puncher:get_player_name()] - 1
		end
	end,
	on_step = function(self, dtime)
		if minetest.get_modpath("mobtalker") then
			if not creeper_talk[self] then
				creeper_action(self, dtime)
			else
				self.object:set_animation({x=self.anim.stand_START,y=self.anim.stand_END},30,0)
			end
		else
			creeper_action(self, dtime)
		end
	end,
})
dofile(minetest.get_modpath("creeper").."/item.lua")
dofile(minetest.get_modpath("creeper").."/spawn.lua")
