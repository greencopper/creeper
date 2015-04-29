minetest.register_craftitem("creeper:spawnegg",{
	description = "Creeper Spawn Egg",
	inventory_image = "creeper_spawnegg.png",
	stack_max = 64,
	on_place = function(itemstack, placer, pointed_thing)
		if pointed_thing.type == "node" then
			local p = pointed_thing.above
			p.y = p.y+1
			minetest.env:add_entity(p,"creeper:creeper")
			if not minetest.setting_getbool("creative_mode") then itemstack:take_item() end
			return itemstack
		end
	end,
})
