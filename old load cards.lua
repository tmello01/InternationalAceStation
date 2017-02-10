LoadTemplate = function(template, toGame)
		if toGame then
			if love.filesystem.isFile("/templates/"..template..".lua") then
				local template = love.filesystem.load("/templates/"..template..".lua")()
				if template.deckgroups then
					for i, v in pairs(template.deckgroups) do
						local allowedvalues = v.preset
						local function getNumSuits()
							local numsuits = 0
							for n,b in pairs( allowedvalues ) do
								if #b > 0 then
									numsuits = numsuits + 1
								end
							end
							print("number of suits: " .. numsuits)
							return numsuits
						end
						
						for k, z in ipairs( template.cards ) do
							if z.deckgroup == v.id then
								local suit = z.suit
								local value = z.value
								if suit == "any" then
									local c = love.math.random(1,getNumSuits())
									local count = 1
									for i, v in pairs( allowedvalues ) do
										if count == c then
											suit = i
											break
										end
										count = count + 1
									end
								end
								if value == "any" then
									remval = love.math.random(1,#allowedvalues[suit])
									value = allowedvalues[suit][remval]
								end
								for allowedsuitname, allowedsuit in pairs( allowedvalues ) do
									for key, val in pairs( allowedsuit ) do
										print( value, val, allowedsuitname, suit )
										if value == val and allowedsuitname == suit then
											--print("removing card:" .. allowedsuitname.." " ..val)
											--print( table.serialize(allowedvalues[allowedvaluesdsuitname]), key, val )
											print(allowedvalues[suit][key])
											table.remove(allowedvalues[suit],key)
											break
										end
									end
								end
								--print("new card:", value, suit)
								card:new({
									suit = suit,
									value = tostring(value),
									flipped = z.flipped,
									x = z.x,
									y = z.y,
								})
							end
						end

						for k, z in ipairs( template.decks ) do
							if z.deckgroup == v.id then
								local cards = {}
								for p, card in ipairs( z.cards ) do
									local suit = card.suit
									local value = card.value
									if suit == "any" then
										local c = love.math.random(1,getNumSuits())
										local count = 1
										for h, _ in pairs( allowedvalues ) do
											if count == c then
												suit = h
												break
											end
											count = count + 1
										end
									end
									if value == "any" then
										remval = love.math.random(1,#allowedvalues[suit])
										value = allowedvalues[suit][remval]
									end
									for allowedsuitname, allowedsuit in pairs( allowedvalues ) do
										for key, val in pairs( allowedsuit ) do
											print( value, val, allowedsuitname, suit )
											if value == val and allowedsuitname == suit then
												--print("removing card:" .. allowedsuitname.." " ..val)
												--print( table.serialize(allowedvalues[allowedvaluesdsuitname]), key, val )
												print(allowedvalues[suit][key])
												table.remove(allowedvalues[suit],key)
												break
											end
										end
									end
									table.insert(cards, {
										suit = suit,
										value = value,
										flipped = card.flipped,
									})
								end
								deck:new({
									x = z.x,
									y = z.y,
									cards = cards,
								})
							end
						end
						
					end
				end
			end
		else
			--Load to the template builder--
			if love.filesystem.isFile("/templates/"..template..".lua") then
				local template = love.filesystem.load("/templates/"..template..".lua")()
				for objName, objType in pairs( template ) do
					
				end
			end
		end
	end,