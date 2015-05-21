function creeper_get_animation()
	return {
		stand_START = 0,
		stand_END = 79,
		walk_START = 168,
		walk_END = 187,
	}
end

function creeper_action(self, dtime)
	local ANIM_STAND = 1
	local ANIM_WALK  = 2
	local animation_speed = 30
	local animation_speed_mod = 30
	local attack_speed = 3
	local walk_speed = 1.5
	local damage = 2
	local jump_y = 5
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
					if minetest.get_modpath("mobtalker") and self.love ~= nil then
						if self.love <= 0 then
							self.chase = true
						end
					else
						self.chase = true
					end
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
						self.jump_timer = 0
						local p = {x=NPC.x + self.direction.x,y=NPC.y,z=NPC.z + self.direction.z}
						local n = minetest.get_node_or_nil(p)
						p.y = p.y+1
						local n2 = minetest.get_node_or_nil(p)
						local def = nil
						local def2 = nil
						if n and n.name then
							def = minetest.registered_items[n.name]
						end
						if n2 and n2.name then
							def2 = minetest.registered_items[n2.name]
						end
						if def and def.walkable and def2 and not def2.walkable and not def.groups.fences and n.name ~= "default:fence_wood" then
							self.object:setvelocity({x=self.object:getvelocity().x*2.2,y=jump_y,z=self.object:getvelocity().z*2.2})
						end
					end
				end
			elseif not object:is_player() then
				self.state = 1
			end
		end
	end
end

-- From TNT
local cid_data = {}
local radius = tonumber(minetest.setting_get("tnt_radius") or 3)
local loss_prob = {
	["default:cobble"] = 3,
	["default:dirt"] = 4,
}
minetest.after(0, function()
	for name, def in pairs(minetest.registered_nodes) do
		cid_data[minetest.get_content_id(name)] = {
			name = name,
			drops = def.drops,
			flammable = def.groups.flammable,
		}
	end
end)

local function rand_pos(center, pos, radius)
	pos.x = center.x + math.random(-radius, radius)
	pos.z = center.z + math.random(-radius, radius)
end

local function eject_drops(drops, pos, radius)
	local drop_pos = vector.new(pos)
	for _, item in pairs(drops) do
		local count = item:get_count()
		local max = item:get_stack_max()
		if count > max then
			item:set_count(max)
		end
		while count > 0 do
			if count < max then
				item:set_count(count)
			end
			rand_pos(pos, drop_pos, radius)
			local obj = minetest.add_item(drop_pos, item)
			if obj then
				obj:get_luaentity().collect = true
				obj:setacceleration({x=0, y=-10, z=0})
				obj:setvelocity({x=math.random(-3, 3), y=10,
						z=math.random(-3, 3)})
			end
			count = count - max
		end
	end
end

local function add_drop(drops, item)
	item = ItemStack(item)
	local name = item:get_name()
	if loss_prob[name] ~= nil and math.random(1, loss_prob[name]) == 1 then
		return
	end

	local drop = drops[name]
	if drop == nil then
		drops[name] = item
	else
		drop:set_count(drop:get_count() + item:get_count())
	end
end

local function destroy(drops, pos, cid)
	if minetest.is_protected(pos, "") then
		return
	end
	local def = cid_data[cid]
	minetest.dig_node(pos)
	if def then
		local node_drops = minetest.get_node_drops(def.name, "")
		for _, item in ipairs(node_drops) do
			add_drop(drops, item)
		end
	end
end


local function calc_velocity(pos1, pos2, old_vel, power)
	local vel = vector.direction(pos1, pos2)
	vel = vector.normalize(vel)
	vel = vector.multiply(vel, power)

	-- Divide by distance
	local dist = vector.distance(pos1, pos2)
	dist = math.max(dist, 1)
	vel = vector.divide(vel, dist)

	-- Add old velocity
	vel = vector.add(vel, old_vel)
	return vel
end

local function entity_physics(pos, radius)
	-- Make the damage radius larger than the destruction radius
	radius = radius * 2
	local objs = minetest.get_objects_inside_radius(pos, radius)
	for _, obj in pairs(objs) do
		local obj_pos = obj:getpos()
		local obj_vel = obj:getvelocity()
		local dist = math.max(1, vector.distance(pos, obj_pos))

		if obj_vel ~= nil then
			obj:setvelocity(calc_velocity(pos, obj_pos,
					obj_vel, radius * 10))
		end

		local damage = (5 / dist) * radius
		obj:set_hp(obj:get_hp() - damage)
	end
end

local function add_effects(pos, radius)
	minetest.add_particlespawner({
		amount = 128,
		time = 1,
		minpos = vector.subtract(pos, radius / 2),
		maxpos = vector.add(pos, radius / 2),
		minvel = {x=-20, y=-20, z=-20},
		maxvel = {x=20,  y=20,  z=20},
		minacc = vector.new(),
		maxacc = vector.new(),
		minexptime = 1,
		maxexptime = 3,
		minsize = 8,
		maxsize = 16,
		texture = "tnt_smoke.png",
	})
end


local function explode(pos, radius)
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
					cid ~= c_boom then
				destroy(drops, p, cid)
			end
		end
		vi = vi + 1
	end
	end
	end

	return drops
end

function creeper_boom(pos)
	minetest.sound_play("creeper_explode", {pos=pos, gain=1.5, max_hear_distance=2*64})
	minetest.set_node(pos, {name="tnt:boom"})
	minetest.get_node_timer(pos):start(0.5)
	local drops = explode(pos, radius)
	entity_physics(pos, radius)
	eject_drops(drops, pos, radius)
	add_effects(pos, radius)
end
