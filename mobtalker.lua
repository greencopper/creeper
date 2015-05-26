-- Local
local mobname = "creeper"
local pself = {}
mobtalker.register_name("creeper","Cupa")

-- intllib
local S
if minetest.get_modpath("intllib") then
	S = intllib.Getter()
else
	S = function(s) return s end
end

-- Return Form
local function talk_form(player,love,route,count)
	local function form(text,def)
		return xform(mobname,text,def)
	end
	if love == 0 and route == 0 and count == 0 then
		return form(S("Sssssssss....."))
	elseif love == 1 and route == 0 and count == 0 then
		return form(S("Whoa～HELP!"),{face="tired"})
	--Select1
	elseif love == 1 and route == 0 and count == 1 then
		return form(S("CCCAT!!! G..GET IT AWAY FROM ME!!!!!"),{
			choose1="It's next to you!",
			choose2="What cat?",
			choose3="Does it looks like this one I just caught?"
		})
	--Route1
	elseif love == 1 and route == 1 and count == 0 then
		return form(S("Arhh!!Do...Don't!!Whoa!"),{face="angry"})
	--Route2
	elseif love == 1 and route == 2 and count == 0 then
		return form(S("Really?Is that monster gone?"),{face="shy"})
	elseif love == 2 and route == 2 and count == 0 then
		return form(S("Thanks for saving my life, mister.\nPhew, thought I couldn't make it."),{face="happy"})
	elseif love == 2 and route == 2 and count == 1 then
		return form(S("Yeah, forget to introduce myself.\nName's Cupa, nice to meet you."))
	elseif love == 2 and route == 2 and count == 2 then
		return form(S("And you are?"))
	elseif love == 2 and route == 2 and count == 3 then
		return form(S("Just call me %s."):format(player:get_player_name()),{name=player:get_player_name()})
	elseif love == 2 and route == 2 and count == 4 then
		return form(S("%s? What a nice name."):format(player:get_player_name()))
	elseif love == 2 and route == 2 and count == 5 then
		return form(S("Heh, you should see your blushing face, red as redstone."),{proceed_name="creeper_end"})
	--Route3
	elseif love == 1 and route == 3 and count == 0 then
		return form(S("So you are afraid of cat....KeKeKe....."),{name=player:get_player_name()})
	elseif love == 1 and route == 3 and count == 0 then
		return form(S("Wa.wait what?::I warn you, if...if you have any cute ideas, the..they will have to glue you back together, IN HELL!"),{face="tired"})
	elseif love == 1 and route == 3 and count == 1 then
		return form(S("Ok,ok, no harm's done.::I suddenly have an urge want to keep that cat."),{name=player:get_player_name()})
	elseif love == 1 and route == 3 and count == 2 then
		return form(S("You...You do it on purpose..\nWhoa!Get that away!Jerk!"),{face="angry"})
	elseif love == 1 and route == 3 and count == 3 then
		return form(S("Pff...Did anyone told you you have a comedian's face?"),{name=player:get_player_name()})
	elseif love == 1 and route == 3 and count == 4 then
		return form(S("You..you will pay for that!\nI hate you!"))
	elseif love == 1 and route == 3 and count == 5 then
		return form(S("Heh, you should see your blushing face, red as redstone."))
	--Route2-2
	elseif love == 4 and route == 0 and count == 0 then
		return form(S("Morning!\nGood dream last night? If you know what I mean.\nI've been doing some patrol last night."))
	elseif love == 4 and route == 0 and count == 1 then
		return form(S("Hey...This...this is awkward...\nAre you singl\nNo, are you a confirmed bachelo\nDamn it, eh, do you live by youself?"))
	elseif love == 4 and route == 0 and count == 2 then
		return form(S("Yeah, so?"),{name=player:get_player_name()})
	elseif love == 4 and route == 0 and count == 3 then
		return form(S("Um...\nNo,I mean..the house is comfy.\nAnd I thought there are others."))
	elseif love == 4 and route == 0 and count == 4 then
		return form(S("Yeah, surplus of resource plus too much youth to waste."),{name=player:get_player_name()})
	elseif love == 4 and route == 0 and count == 5 then
		return form(S("So..... You won't move in a near future, will you?"))
	elseif love == 4 and route == 0 and count == 6 then
		return form(S("Yeah, got an arrow at my knee, doesn't plan for any expedition."),{name=player:get_player_name()})
	elseif love == 4 and route == 0 and count == 7 then
		return form(S("Hehehe.."))
	elseif love == 4 and route == 0 and count == 8 then
		return form(S("(I got a bad feeling about this....)"),{name=player:get_player_name()})
	--Route3-2
	elseif love == 3 and route == 0 and count == 0 then
		return form(S("You again?\nI will have my revenge!"))
	elseif love == 3 and route == 0 and count == 1 then
		return form(S("Go ahead.\nMake my day.\nI even brought your pal, kitty, to cheer you up."),{name=player:get_player_name()})
	elseif love == 3 and route == 0 and count == 2 then
		return form(S("Uh..uh..\nOKay, okay, you don't need to release the kraken...I surrender....\n(Soon, I will have my revenge....)"))
	elseif love == 3 and route == 0 and count == 3 then
		return form(S("Come on!::Don't you want some comeback?"),{name=player:get_player_name()})
	elseif love == 3 and route == 0 and count == 4 then
		return form(S("I was kidding!Why so serius.\nOr you just can't afford a joke?"))
	elseif love == 3 and route == 0 and count == 5 then
		return form(S("Of course no problem.I'm generous.\nBTW,who you are?"),{name=player:get_player_name()})
	elseif love == 3 and route == 0 and count == 6 then
		return form(S("Who am I?\nAre you blind?\nI'm a creeper!"))
	elseif love == 3 and route == 0 and count == 7 then
		return form(S("A proper name, not a species."),{name=player:get_player_name()})
	elseif love == 3 and route == 0 and count == 8 then
		return form(S("Erh..nope."))
	elseif love == 3 and route == 0 and count == 9 then
		return form(S("Do you know my cows are better liar than you?"),{name=player:get_player_name()})
	elseif love == 3 and route == 0 and count == 10 then
		return form(S("Get stuffed! No means NO!"))
	elseif love == 3 and route == 0 and count == 11 then
		return form(S("Oh,would you look at that, kitty's coming."),{name=player:get_player_name()})
	elseif love == 3 and route == 0 and count == 12 then
		return form(S("Eh...erh....ARRHHH!!!!\nI don't know your name too!!!"))
	else
		return form(S("Hehe, you should see your blushing face, red as redstone."))
	end
end

-- Global
function mobtalker_creeper(self,clicker)
	local c = clicker:get_player_name()
	self.talk = true
	pself[clicker] = self
	self.object:setvelocity({x=0,y=0,z=0})
	minetest.show_formspec(c,mobname..":form",talk_form(clicker,self.love[c],self.route[c],self.count[c]))
end

-- Event
minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname == mobname..":form" then
		local entity = pself[player]
		local p = player:get_player_name()
		local love = entity.love[p]
		local route = entity.route[p]
		local count = entity.count[p]
		local talk = entity.talk
		local proceed = fields.creeper_proceed
		local choose1 = fields.creeper_choose1
		local choose2 = fields.creeper_choose2
		local choose3 = fields.creeper_choose3
		entity.talk = false
		if love == 0 and route == 0 and count == 0 and proceed then
			entity.love[p] = 1
		elseif love == 1 and route == 0 and count == 0 and proceed then
			entity.count[p] = 1
		--Route1
		elseif love == 1 and route == 0 and count == 1 and choose1 then
			entity.count[p] = 0
			entity.route[p] = 1
			minetest.after(0.15,function()
				mobtalker_creeper(entity,player)
			end)
		elseif love == 1 and route == 1 and count == 0 and proceed then
			player:set_hp(player:get_hp()-3)
			entity.object:remove()
		--Route2
		elseif love == 1 and route == 0 and count == 1 and choose2 then
			entity.count[p] = 0
			entity.route[p] = 2
			minetest.after(0.15,function()
				mobtalker_creeper(entity,player)
			end)
		elseif love == 1 and route == 2 and count == 0 and proceed then
			entity.love[p] = 2
		elseif love == 2 and route == 2 and count <= 4 and proceed then
			entity.count[p] = entity.count[p] + 1
			if entity.count[p] < 5 then
				minetest.after(0.15,function()
					mobtalker_creeper(entity,player)
				end)
			else
				minetest.after(600,function()
					entity.love[p] = 4
					entity.route[p] = 0
					entity.count[p] = 0
				end)
			end
		--Route3
		elseif love == 1 and route == 0 and count == 1 and choose3 then
			entity.count[p] = 0
			entity.route[p] = 3
			minetest.after(0.15,function()
				mobtalker_creeper(entity,player)
			end)
		elseif love == 1 and route == 3 and count <= 4 and proceed then
			entity.count[p] = entity.count[p] + 1
			if entity.count[p] == 5 then
				player:set_hp(player:get_hp()-1)
			elseif entity.count[p] < 5 then
				minetest.after(0.15,function()
					mobtalker_creeper(entity,player)
				end)
			else
				minetest.after(600,function()
					entity.love[p] = 3
					entity.route[p] = 0
					entity.count[p] = 0
				end)
			end
		--Route2-2
		elseif love == 4 and route == 0 and count <= 7 and proceed then
			entity.count[p] = entity.count[p] + 1
			if entity.count[p] <= 8 then
				minetest.after(0.15,function()
					mobtalker_creeper(entity,player)
				end)
			end
		--Route3-2
		elseif love == 3 and route == 0 and count <= 11 and proceed then
			if entity.count[p] == 0 then
				player:set_hp(player:get_hp()-1)
			end
			entity.count[p] = entity.count[p] + 1
			if entity.count[p] <= 12 then
				minetest.after(0.15,function()
					mobtalker_creeper(entity,player)
				end)
			end
		end
	end
end)
