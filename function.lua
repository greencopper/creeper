local cid_data = {}
function creeper_get_animation()
	return {
		stand_START = 0,
		stand_END = 79,
		walk_START = 168,
		walk_END = 187,
	}
end
-- Destroy
local function creeper_destroy(pos,cid)
	-- Drop
	local nodename = minetest.env:get_node(pos).name
	local drop = minetest.get_node_drops(nodename, "")
	for _,item in ipairs(drop) do
		if type(item) == "string" then
			local obj = minetest.env:add_item(pos, item)
			if obj == nil then
				return
			end
			obj:get_luaentity().collect = true
			obj:setacceleration({x=0, y=-10, z=0})
			obj:setvelocity({x=math.random(0,6)-3, y=10, z=math.random(0,6)-3})
		else
			for i=1,item:get_count() do
				local obj = minetest.env:add_item(pos, item:get_name())
				if obj == nil then
					return
				end
				obj:get_luaentity().collect = true
				obj:setacceleration({x=0, y=-10, z=0})
				obj:setvelocity({x=math.random(0,6)-3, y=10, z=math.random(0,6)-3})
			end
		end
	end
	-- Remove
	if minetest.is_protected(pos, "") then
		return
	end
	local def = cid_data[cid]
	minetest.remove_node(pos)
	local radius = 6
	local objs = minetest.get_objects_inside_radius(pos,radius)
	for _, obj in pairs(objs) do
		local obj_pos = obj:getpos()
		local dist = math.max(1, vector.distance(pos, obj_pos))
		local damage = (4 / dist) * radius
		obj:set_hp(obj:get_hp() - damage)
	end
end
-- Boom
creeper_boom = function(pos)
	local radius = 3
	local pos = vector.round(pos)
	local vm = VoxelManip()
	local pr = PseudoRandom(os.time())
	local p1 = vector.subtract(pos,radius)
	local p2 = vector.add(pos, radius)
	local minp, maxp = vm:read_from_map(p1, p2)
	local data = vm:get_data()
	local p = {}
	local c_air = minetest.get_content_id("air")
	local a = VoxelArea:new({MinEdge = minp, MaxEdge = maxp})
	for z = -radius, radius do
	for y = -radius, radius do
	for x = -radius, radius do
		local vi = a:index(pos.x+(-radius),pos.y+y,pos.z+z)
		if (x * x) + (y * y) + (z * z) <=
				(radius * radius) + pr:next(-radius, radius) then
			local cid = data[vi]
			p.x = pos.x + x
			p.y = pos.y + y
			p.z = pos.z + z
			if cid ~= c_air then
				creeper_destroy(p, cid)
			end
		end
		vi = vi + 1
	end
	end
	end
	minetest.add_particlespawner(
		100, --amount
		0.1, --time
		{x=pos.x-3, y=pos.y-3, z=pos.z-3}, --minpos
		{x=pos.x+3, y=pos.y+3, z=pos.z+3}, --maxpos
		{x=-0, y=-0, z=-0}, --minvel
		{x=0, y=0, z=0}, --maxvel
		{x=-0.5,y=5,z=-0.5}, --minacc
		{x=0.5,y=5,z=0.5}, --maxacc
		0.1, --minexptime
		1, --maxexptime
		8, --minsize
		15, --maxsize
		false, --collisiondetection
		"creeper_smoke.png" --texture
	)
end
