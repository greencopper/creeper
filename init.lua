creeper = {}
local attack_speed = 3
local walk_speed = 1.5
local animation_speed = 30
local animation_speed_mod = 30
local ANIM_STAND = 1
local ANIM_WALK  = 2
local damage = 2
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
	on_punch = function(self)
		minetest.sound_play("creeper_hurt", {pos=self.object:getpos(), gain=1.5, max_hear_distance=6})
		self.object:set_hp(self.object:get_hp()-damage)
	end,
	on_step = function(self, dtime)
		self.timer = self.timer + 0.01
		self.turn_timer = self.turn_timer + 0.01
		self.jump_timer = self.jump_timer + 0.01
		if self.timer > math.random(2,5) then
			if math.random() > 0.8 then
				self.state = 1
			else
				self.state = 2
			end
			self.timer = 0
			if self.object:getvelocity().y ~= 0 then
				self.state = 2
			end
		end
		if self.yaw > 6 then
			self.yaw = 0
		elseif self.yaw < 0 then
			self.yaw = 6
		end
		if self.turn == "right" then
			self.yaw = self.yaw + self.turn_speed
			self.object:setyaw(self.yaw)
		elseif self.turn == "left" then
			self.yaw = self.yaw - self.turn_speed
			self.object:setyaw(self.yaw)
		end
		for  _,object in ipairs(minetest.env:get_objects_inside_radius(self.object:getpos(), 12)) do
			if object:is_player() then
				self.state = 3
			end
		end
		if self.chase == true then
			if self.visualx < 2 then
				if self.hiss == false then
					minetest.sound_play("hiss", {pos=self.object:getpos(), gain=1.5, max_hear_distance=2*64})
				end
				self.visualx = self.visualx + 0.05
				self.object:set_properties({visual_size = {x=self.visualx, y=1}})
				self.hiss = true
			end
		else
			if self.visualx > 1 then
				self.visualx = self.visualx - 0.05
				self.object:set_properties({visual_size = {x=self.visualx, y=1}})
				self.hiss = false
			end
		end
		--set this to false so it only goes up when creeper is next to player
		self.chase = false
		--STANDING
		if self.state == 1 then
			self.yawwer = true
			for  _,object in ipairs(minetest.env:get_objects_inside_radius(self.object:getpos(), 3)) do
				if object:is_player() then
					self.yawwer = false
					local NPC = self.object:getpos()
					local PLAYER = object:getpos()
					self.vec = {x=PLAYER.x-NPC.x, y=PLAYER.y-NPC.y, z=PLAYER.z-NPC.z}
					self.yaw = math.atan(self.vec.z/self.vec.x)+math.pi^2
					if PLAYER.x > NPC.x then
						self.yaw = self.yaw + math.pi
					end
					self.yaw = self.yaw - 8.3
					self.object:setyaw(self.yaw)
				end
			end
			if self.turn_timer > math.random(2,5) then
				local select_turn = math.random(1,3)
				if select_turn == 1 then
					self.turn = "left"
				elseif select_turn == 2 then
					self.turn = "right"
				elseif select_turn == 3 then
					self.turn = "straight"
				end
				self.turn_timer = 0
				self.turn_speed = 0.05 * math.random()
			end
			self.object:setvelocity({x=0,y=self.object:getvelocity().y,z=0})
			if self.player_anim ~= ANIM_STAND then
				self.anim = creeper_get_animation()
				self.object:set_animation({x=self.anim.stand_START,y=self.anim.stand_END}, animation_speed_mod,0)
				self.player_anim = ANIM_STAND
			end
		end
		--WALKING
		if self.state == 2 then
			self.direction = {x = math.sin(self.object:getyaw())*-1, y = -10, z = math.cos(self.object:getyaw())}
			if self.direction ~= nil then
				self.object:setvelocity({x=self.direction.x*walk_speed,y=self.object:getvelocity().y,z=self.direction.z*walk_speed})
			end
			if self.turn_timer > math.random(2,5) then
				local select_turn = math.random(1,3)
				if select_turn == 1 then
					self.turn = "left"
				elseif select_turn == 2 then
					self.turn = "right"
				elseif select_turn == 3 then
					self.turn = "straight"
				end
				self.turn_timer = 0
				self.turn_speed = 0.05 * math.random()
			end
		
			if self.player_anim ~= ANIM_WALK then
				self.anim = creeper_get_animation()
				self.object:set_animation({x=self.anim.walk_START,y=self.anim.walk_END}, animation_speed_mod,0)
				self.player_anim = ANIM_WALK
			end
			--change dir if not moving
			local speed = self.object:getvelocity()
			if self.turn_timer > 1 then
				if speed.x == 0 or speed.z == 0 or minetest.registered_nodes[minetest.env:get_node({x=self.object:getpos().x + self.direction.x,y=self.object:getpos().y+0.2,z=self.object:getpos().z + self.direction.z}).name].walkable then
					local select_turn = math.random(1,2)
					if select_turn == 1 then
						self.turn = "left"
					elseif select_turn == 2 then
						self.turn = "right"
					end
					self.turn_timer = 0
					self.turn_speed = 0.05 * math.random()
					self.jump_timer = 0
				end
			end
			--jump
			if self.direction ~= nil then
				if self.jump_timer > 0.45 then
					if minetest.registered_nodes[minetest.env:get_node({x=self.object:getpos().x + self.direction.x,y=self.object:getpos().y-0.35,z=self.object:getpos().z + self.direction.z}).name].walkable then
						self.object:setvelocity({x=self.object:getvelocity().x,y=5,z=self.object:getvelocity().z})
						self.jump_timer = 0
					end
				end
			end
		
		end
		if self.state == 3 then
			self.turn = "straight"
			if self.player_anim ~= ANIM_WALK then
				self.anim = creeper_get_animation()
				self.object:set_animation({x=self.anim.walk_START,y=self.anim.walk_END}, animation_speed_mod,0)
				self.player_anim = ANIM_WALK
			end
			for  _,object in ipairs(minetest.env:get_objects_inside_radius(self.object:getpos(), 2)) do
				if object:is_player() then
					if object:get_hp() > 0 then
						if self.visualx >= 2 then
							self.object:remove()
							creeper_boom(self.object:getpos())
							minetest.sound_play("tnt_explode", {pos=self.object:getpos(), gain=1.5, max_hear_distance=2*64})
						end
						self.chase = true
					end
				end
			end
			for  _,object in ipairs(minetest.env:get_objects_inside_radius(self.object:getpos(), 12)) do
				if object:is_player() then
					if object:get_hp() > 0 then
						for _,object in ipairs(minetest.env:get_objects_inside_radius(self.object:getpos(), 2)) do
							if object:is_player() then
								self.object:setvelocity({x=0,y=self.object:getvelocity().y,z=0})
								if self.player_anim ~= ANIM_STAND then
									self.anim = creeper_get_animation()
									self.object:set_animation({x=self.anim.stand_START,y=self.anim.stand_END}, animation_speed_mod,0)
									self.player_anim = ANIM_STAND
								end
								return
							end
						end
						local NPC = self.object:getpos()
						local PLAYER = object:getpos()
						self.vec = {x=PLAYER.x-NPC.x, y=PLAYER.y-NPC.y, z=PLAYER.z-NPC.z}
						self.yaw = math.atan(self.vec.z/self.vec.x)+math.pi^2
						if PLAYER.x > NPC.x then
							self.yaw = self.yaw + math.pi
						end
						self.yaw = self.yaw - 2
						self.object:setyaw(self.yaw)
						self.direction = {x = math.sin(self.yaw)*-1, y = 0, z = math.cos(self.yaw)}
						if self.direction ~= nil then
							self.object:setvelocity({x=self.direction.x*2.5,y=self.object:getvelocity().y,z=self.direction.z*2.5})
						end
						--jump over obstacles
						if self.jump_timer > 0.3 then
							if minetest.env:get_node({x=self.object:getpos().x + self.direction.x,y=self.object:getpos().y-1,z=self.object:getpos().z + self.direction.z}).name ~= "air" then
								self.object:setvelocity({x=self.object:getvelocity().x,y=5,z=self.object:getvelocity().z})
								self.jump_timer = 0
							end
						end
					--return
					end
				elseif not object:is_player() then
					self.state = 1
				end
			end
		end
	end,
})
dofile(minetest.get_modpath("creeper").."/item.lua")
dofile(minetest.get_modpath("creeper").."/spawn.lua")
