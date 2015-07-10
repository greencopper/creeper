creeper = {}

dofile(minetest.get_modpath("creeper").."/tnt_function.lua")
dofile(minetest.get_modpath("creeper").."/spawn.lua")

local def = {
	hp_max = 20,
	physical = true,
	collisionbox = {-0.3,-0.7,-0.3, 0.3,0.8,0.3},
	visual = "mesh",
	mesh = "character.b3d",
	textures = {"creeper.png"},
	makes_footstep_sound = true,
	automatic_rotate = true,

	-- Original
	animation = {
		stand_START = 0,
		stand_END = 79,
		walk_START = 168,
		walk_END = 187
	},
	walk_speed = 1.5,
	jump_height = 5,
	animation_speed = 30
}

def.on_activate = function(self,staticdata)
	self.yaw = 0
	self.anim = 1
	self.timer = 0
	self.visualx = 1
	self.turn_timer = 0
	self.turn_speed = 0
	self.state = math.random(1,2)
	
	local obj = self.object
	obj:setacceleration({x=0,y=-10,z=0})
end

def.on_step = function(self, dtime)
	local ANIM_STAND = 1
	local ANIM_WALK  = 2
	
	local pos = self.object:getpos()
	local inside = minetest.get_objects_inside_radius(pos,10)
	local walk_speed = self.walk_speed
	local animation = self.animation
	local anim_speed = animation_speed
	
	self.timer = self.timer+0.01
	self.turn_timer = self.turn_timer+0.01
	
	if not self.chase and self.timer > math.random(2,5) then
		if math.random() > 0.8 then
			self.state = "stand"
		elseif self.object:getvelocity().y ~= 0 then
			self.state = "walk"
		else
			self.state = "walk"
		end
		self.timer = 0
	end

	if self.yaw > 6 then
		self.yaw = 0
	elseif self.yaw < 0 then
		self.yaw = 6
	end

	if self.turn == "right" then
		self.yaw = self.yaw+self.turn_speed
		self.object:setyaw(self.yaw)
	elseif self.turn == "left" then
		self.yaw = self.yaw-self.turn_speed
		self.object:setyaw(self.yaw)
	end
	
	if self.chase and self.visualx < 2 then
		if self.hiss == false then
			minetest.sound_play("creeper_hiss",{pos=pos,gain=1.5,max_hear_distance=2*64})
		end
		self.visualx = self.visualx+0.05
		self.object:set_properties({
			visual_size = {x=self.visualx,y=1}
		})
		self.hiss = true
	elseif self.visualx > 1 then
		self.visualx = self.visualx-0.05
		self.object:set_properties({
			visual_size = {x=self.visualx,y=1}
		})
		self.hiss = false
	end
	
	self.chase = false
	
	for  _,object in ipairs(inside) do
		if object:is_player() then
			self.state = "chase"
		end
	end

	if self.state == "stand" then
		if self.turn_timer > math.random(2,5) then
			local random = math.random(1,3)
			if random == 1 then
				self.turn = "left"
			elseif random == 2 then
				self.turn = "right"
			else
				self.turn = "straight"
			end
			self.turn_timer = 0
			self.turn_speed = 0.05*math.random()
		end
		self.object:setvelocity({x=0,y=self.object:getvelocity().y,z=0})
		if self.anim ~= ANIM_STAND then
			self.object:set_animation({x=animation.stand_START,y=animation.stand_END},anim_speed,0)
			self.anim = ANIM_STAND
		end
	end

	if self.state == "walk" then
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
		if self.anim ~= ANIM_WALK then
			self.object:set_animation({x=animation.walk_START,y=animation.walk_END},anim_speed,0)
			self.anim = ANIM_WALK
		end

		local speed = self.object:getvelocity()
		if self.turn_timer > 1 then
			local direction = self.direction
			local npos = {x=pos.x+direction.x,y=pos.y+0.2,z=pos.z+direction.z}
			if speed.x == 0 or speed.z == 0
			or minetest.registered_nodes[minetest.get_node(npos).name].walkable then
				local select_turn = math.random(1,2)
				if select_turn == 1 then
					self.turn = "left"
				elseif select_turn == 2 then
					self.turn = "right"
				end
				self.turn_timer = 0
				self.turn_speed = 0.05*math.random()
			end
		end
		-- Jump
		if self.direction ~= nil then
			local direction = self.direction
			local npos = {x=pos.x+direction.x,y=pos.y-0.35,z=pos.z+direction.z}
			if minetest.registered_nodes[minetest.get_node(npos).name].walkable then
				local velocity = self.object:getvelocity()
				self.object:setvelocity({x=velocity.x,y=self.jump_height,z=velocity.z})
			end
		end
	end
	if self.state == "chase" then
		local inside_2 = minetest.get_objects_inside_radius(pos,2)
		
		self.turn = "straight"
		if self.anim ~= ANIM_WALK then
			self.object:set_animation({x=animation.walk_START,y=animation.walk_END},anim_speed,0)
			self.anim = ANIM_WALK
		end
		for  _,object in ipairs(inside_2) do
			if object:is_player() and object:get_hp() ~= 0 then
				self.chase = true
				if self.visualx >= 2 then
					self.object:remove()
					creeper.boom(pos)
					minetest.sound_play("creeper_explode",{pos=pos,gain=1.5,max_hear_distance=2*64})
				end
			end
		end
		for  _,object in ipairs(inside) do
			if object:is_player() and object:get_hp() ~= 0 then
				local velocity = self.object:getvelocity()
				
				for _,object in ipairs(inside_2) do
					if object:is_player() then
						self.object:setvelocity({x=0,y=velocity.y,z=0})
						if self.anim ~= ANIM_STAND then
							self.object:set_animation({x=animation.stand_START,y=animation.stand_END},anim_speed,0)
							self.anim = ANIM_STAND
						end
						return
					end
				end
				local ppos = object:getpos()
				self.vec = {x=ppos.x-pos.x,y=ppos.y-pos.y,z=ppos.z-pos.z}
				self.yaw = math.atan(self.vec.z/self.vec.x)+math.pi^2
				if ppos.x > pos.x then
					self.yaw = self.yaw+math.pi
				end
				self.yaw = self.yaw-2
				self.object:setyaw(self.yaw)
				self.direction = {x=math.sin(self.yaw)*-1,y=0,z=math.cos(self.yaw)}
				
				local direction = self.direction
				self.object:setvelocity({x=direction.x*2.5,y=velocity.y,z=direction.z*2.5})

				-- Jump
				local spos = {x=pos.x+direction.x,y=pos.y,z=pos.z+direction.z}
				local node = minetest.get_node_or_nil(spos)
				spos.y = spos.y+1
				local node2 = minetest.get_node_or_nil(spos)
				local def,def2 = {}
				if node and node.name then
					def = minetest.registered_items[node.name]
				end
				if node2 and node2.name then
					def2 = minetest.registered_items[node2.name]
				end
				if def and def.walkable
				and def2 and not def2.walkable
				and def.drawtype ~= "fencelike" then
					self.object:setvelocity({
						x=velocity.x*2.2,
						y=self.jump_height,
						z=velocity.z*2.2
					})
				end
			end
		end
	end
	if minetest.get_item_group(minetest.get_node(pos).name,"water") ~= 0 then
		self.object:setacceleration({x=0,y=1,z=0})
		local velocity = self.object:getvelocity()
		if self.object:getvelocity().y > 5 then
			self.object:setvelocity({x=0,y=velocity.y-velocity.y/2,z=0})
		else
			self.object:setvelocity({x=0,y=velocity.y+1,z=0})
		end
	else
		self.object:setacceleration({x=0,y=-10,z=0})
	end
end

minetest.register_entity("creeper:creeper",def)

minetest.register_craftitem("creeper:spawnegg",{
	description = "Creeper Spawn Egg",
	inventory_image = "creeper_spawnegg.png",
	stack_max = 64,
	on_place = function(itemstack,placer,pointed_thing)
		if pointed_thing.type == "node" then
			local pos = pointed_thing.above
			pos.y = pos.y+1
			minetest.add_entity(pos,"creeper:creeper")
			if not minetest.setting_getbool("creative_mode") then
				itemstack:take_item()
			end
			return itemstack
		end
	end
})
