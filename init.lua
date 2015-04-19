local attack_speed = 3
local walk_speed = 1.5
local animation_speed = 30
minetest.register_entity("creeper:smoke",{
	physical = true,
	visual_size = {x=0.05, y=0.05},
	collisionbox = {-0.05,-0.05,-0.05,0.05,0.05,0.05},
	visual = "sprite",
	textures = {"creeper_smoke.png"},
	shrink = false,
	on_step = function(self, dtime)
		self.object:setvelocity({x=0, y=0.5, z=0})
		self.object:setacceleration({x=0, y=9.8, z = 0})
		self.timer = self.timer + dtime
		self.visual_size.x = self.visual_size.x + 0.025
		self.visual_size.y = self.visual_size.x
		if self.timer > 1 then
			self.object:remove()
		end
	end,
	timer = 0,
})
minetest.register_entity("creeper:smoke2",{
	physical = true,
	visual_size = {x=1, y=1},
	collisionbox = {-0.05,-0.05,-0.05,0.05,0.05,0.05},
	visual = "sprite",
	textures = {"creeper_smokew.png"},
	ft = true,
	on_step = function(self, dtime)
		self.timer = self.timer + dtime
		if self.timer > 1.5 and self.ft==true then
			self.object:setvelocity({x=0, y=0, z = 0})   
			self.object:setacceleration({x=0, y=2, z = 0})
			self.ft = false
		end
		if self.timer > 3 then
			self.object:remove()
		end	
	end,
	timer = 0,
})
minetest.register_entity("creeper:explosion",{
	physical = true,
	visual_size = {x=1, y=1},
	collisionbox = {-0.05,-0.05,-0.05,0.05,0.05,0.05},
	visual = "sprite",
	anim_step =0,
	timer = 0,
	animation_frames = 8,
	on_step = function(self, dtime)
		self.timer = self.timer + dtime
		if self.timer > 2 then
			self.object:remove()
		end
		local pos = self.object:getpos()
		self.object:setpos({x=pos.x+math.random(-1,1),y=pos.y+math.random(-1,1),z=pos.z+math.random(-1,1)})
		self.visual_size.x = math.random(2)
		self.visual_size.y = self.visual_size.x
		self.anim_step = (self.anim_step+1)%self.animation_frames
		self.object:setacceleration({x=math.random(-2,2), y=math.random(-2,2), z=math.random(-2,2)})
		self.object:set_properties({
		textures = {"creeper_explosion.png^[verticalframe:"..self.animation_frames..":"..self.anim_step.."]"},
		})
	end,
})
-- animation
function creeper_get_animation(model)
	return {
		stand_START = 0,
		stand_END = 79,
		sit_START = 81,
		sit_END = 160,
		lay_START = 162,
		lay_END = 166,
		walk_START = 168,
		walk_END = 187,
		mine_START = 189,
		mine_END = 198,
		walk_mine_START = 200,
		walk_mine_END = 219
	}
end

local ANIM_STAND = 1
local ANIM_WALK  = 2

local cid_data = {}
minetest.after(0, function()
	for name, def in pairs(minetest.registered_nodes) do
		cid_data[minetest.get_content_id(name)] = {
			name = name,
			drops = def.drops,
			flammable = def.groups.flammable,
		}
	end
end)

-- destroy
local function creeper_destroy(drops,pos,cid)
	minetest.remove_node(pos)
	if minetest.is_protected(pos, "") then
		return
	end
	local def = cid_data[cid]
	if def and def.flammable then
		minetest.set_node(pos, fire_node)
	else
		minetest.remove_node(pos)--[[
		if def then
			local node_drops = minetest.get_node_drops(def.name, "")
			for _, item in ipairs(node_drops) do
				add_drop(drops, item)
			end
		end]]--
	end
	radius = 6
	local objs = minetest.get_objects_inside_radius(pos,radius)
	for _, obj in pairs(objs) do
		local obj_pos = obj:getpos()
		local dist = math.max(1, vector.distance(pos, obj_pos))
		local damage = (4 / dist) * radius
		obj:set_hp(obj:get_hp() - damage)
	end
end
-- modelset
function creeper_update_visuals(self)
	visual = "creeper.x"
	self.object:set_properties({
		textures = {"creeper.png"},
		visual_size = {x=1, y=1},
	})
end
-- boom
creeper_boom = function(pos)
	local radius = 3
	local pos = vector.round(pos)
	local vm = VoxelManip()
	local pr = PseudoRandom(os.time())
	local p1 = vector.subtract(pos, radius)
	local p2 = vector.add(pos, radius)
	local minp, maxp = vm:read_from_map(p1, p2)
	local a = VoxelArea:new({MinEdge = minp, MaxEdge = maxp})
	local data = vm:get_data()
	local drops = {}
	local p = {}
	local c_air = minetest.get_content_id("air")
	local c_tnt = minetest.get_content_id("tnt:tnt")
	local c_tnt_burning = minetest.get_content_id("tnt:tnt_burning")
	local c_gunpowder = minetest.get_content_id("tnt:gunpowder")
	local c_gunpowder_burning = minetest.get_content_id("tnt:gunpowder_burning")
	local c_boom = minetest.get_content_id("tnt:boom")
	local c_fire = minetest.get_content_id("fire:basic_flame")

	for z = -radius, radius do
	for y = -radius, radius do
	local vi = a:index(pos.x + (-radius), pos.y + y, pos.z + z)
	for x = -radius, radius do
		if (x * x) + (y * y) + (z * z) <=
				(radius * radius) + pr:next(-radius, radius) then
			local cid = data[vi]
			p.x = pos.x + x
			p.y = pos.y + y
			p.z = pos.z + z
			if cid == c_tnt or cid == c_gunpowder then
				burn(p)
			elseif cid ~= c_tnt_burning and
					cid ~= c_gunpowder_burning and
					cid ~= c_air and
					cid ~= c_fire and
					cid ~= c_boom then
				creeper_destroy(drops, p, cid)
			end
		end
		vi = vi + 1
	end
	end
	end

	return drops
end
-- entity setting
creeper = {
	hp_max = 20,
	physical = true,
	collisionbox = {-0.3,-0.7,-0.3, 0.3,0.8,0.3},
	visual = "mesh",
	mesh = "creeper.x",
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
	visualx = 1,
	chase = false,
	hiss = false,
}
creeper.on_activate = function(self)
	self.anim = creeper_get_animation(visual)
	self.object:setacceleration({x=0,y=-10,z=0})
	self.state = math.random(1,2)
	self.turn_speed = 0.1
	self.yaw = math.random(0,6) * math.random()
	self.visualx = 1
	creeper_update_visuals(self)
end
creeper.on_punch = function(self, puncher)
	local damage = 2
	minetest.sound_play("creeper_hurt", {pos=self.object:getpos(), gain=1.5, max_hear_distance=2*64})
	self.object:set_hp(self.object:get_hp()-damage)
end
creeper.on_step = function(self, dtime)
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
			prop = {
				visual_size = {x=self.visualx, y=1},
			}
			self.object:set_properties(prop)
			self.hiss = true
		end
	else
		if self.visualx > 1 then
			self.visualx = self.visualx - 0.05
			prop = {
				visual_size = {x=self.visualx, y=1},
			}
			self.object:set_properties(prop)
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
				NPC = self.object:getpos()
				PLAYER = object:getpos()
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
			self.anim = creeper_get_animation(visual)
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
			self.anim = creeper_get_animation(visual)
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
			self.anim = creeper_get_animation(visual)
			self.object:set_animation({x=self.anim.walk_START,y=self.anim.walk_END}, animation_speed_mod,0)
			self.player_anim = ANIM_WALK
		end
		for  _,object in ipairs(minetest.env:get_objects_inside_radius(self.object:getpos(), 2)) do
			if object:is_player() then
				if object:get_hp() > 0 then
					if self.visualx >= 2 then
						self.object:remove()
						creeper_boom(self.object:getpos(), 0)
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
								self.anim = creeper_get_animation(visual)
								self.object:set_animation({x=self.anim.stand_START,y=self.anim.stand_END}, animation_speed_mod,0)
								self.player_anim = ANIM_STAND
							end
							return
						end
					end
					NPC = self.object:getpos()
					PLAYER = object:getpos()
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
					if self.direction ~= nil then
						if self.door_timer > 2 then
							local is_a_door = minetest.env:get_node({x=self.object:getpos().x + self.direction.x,y=self.object:getpos().y,z=self.object:getpos().z + self.direction.z}).name
							if is_a_door == "doors:door_wood_t_1" then
								minetest.env:punch_node({x=self.object:getpos().x + self.direction.x,y=self.object:getpos().y-1,z=self.object:getpos().z + self.direction.z})
								self.door_timer = 0
							end
							local is_in_door = minetest.env:get_node(self.object:getpos()).name
							if is_in_door == "doors:door_wood_t_1" then
								minetest.env:punch_node(self.object:getpos())
							end
						end
					end
				--return
				end
			elseif not object:is_player() then
				self.state = 1
			end
		end
	end
end
minetest.register_entity("creeper:creeper",creeper)

-- Egg
minetest.register_craftitem("creeper:spawnegg", {
	description = "Creeper Spawn Egg",
	inventory_image = "creeper_spawnegg.png",
	stack_max = 64,
	on_place = function(itemstack,placer,pointed)
		pos = pointed.above
		pos.y = pos.y + 1
		minetest.env:add_entity(pointed.above,"creeper:creeper")
	end,

})
-- Spawn
creeper = {}
creeper.spawning_creeper = {}
function creeper:register_spawn(name,nodes,max_light,min_light,chance,active_object_count,max_height,spawn_func)
	creeper.spawning_creeper[name] = true
	minetest.register_abm({
		nodenames = nodes,
		neighbors = {"air"},
		interval = 30,
		chance = chance,
		action = function(pos, node, _, active_object_count_wider)
			if active_object_count_wider > active_object_count then
				return
			end
			if not creeper.spawning_creeper[name] then
				return
			end
			pos.y = pos.y+1
			if not minetest.env:get_node_light(pos) then
				return
			end
			if minetest.env:get_node_light(pos) > max_light then
				return
			end
			if minetest.env:get_node_light(pos) < min_light then
				return
			end
			if pos.y > max_height then
				return
			end
			if minetest.env:get_node(pos).name ~= "air" then
				return
			end
			pos.y = pos.y+1
			if minetest.env:get_node(pos).name ~= "air" then
				return
			end
			if spawn_func and not spawn_func(pos, node) then
				return
			end
			minetest.env:add_entity(pos, name)
		end
	})
end
creeper:register_spawn("creeper:creeper",{"default:dirt_with_grass"},5,-1,10000,5,31000)
