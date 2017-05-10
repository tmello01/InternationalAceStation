socket = socket or require "socket"
local function shuffleTable( t )
    local rand = math.random 
    assert( t, "shuffleTable() expected a table, got nil" )
    local iterations = #t
    local j
    
    for i = iterations, 2, -1 do
        j = rand(i)
        t[i], t[j] = t[j], t[i]
    end
end
local function randomString( charset, len )
	local endstr = ""
	for i = 1, len do
		local rnd = love.math.random(1,#charset)
		endstr = endstr .. charset:sub(rnd,rnd)
	end
	return endstr
end
ui.state = "Menu"

SHOWCHARMS = false
SHOWDECKCHARMS = false

Game = {
	IsAdmin = function()
		return Game.ConnectMode == "Offline" or Game.ConnectMode == "Host"
	end,	
	GetNetworkAddress = function()
		--The address and port are completely arbitrary.
		local sock = socket.udp()
		sock:setpeername("192.168.1.122","3102")
		--[[
			Will return networkAddress, port
		]]--
		return sock:getsockname()
	end,
	InitializeCard = function(suit, value, x, y, flipped, tweentox, tweentoy, deckgroup, nid)
		if Game.IsAdmin() then
			local nid = nid or Game.GenerateNetworkID()
			
			local tweento = (tweentox ~= nil or tweentoy ~= nil)
			card:new({suit = suit, value = value, x = x, y = y, deckgroup = deckgroup, flipped = flipped, networkID = nid, tweentox = tweentox, tweentoy = tweentoy, tweento = tweento}):topDrawOrder()
			Game.SendToClients( "NewCard", {
				s = suit,
				v = value,
				x = x,
				y = y,
				f = flipped,
				n = nid,
				t = tweentox or nil,
				ty = tweentoy or nil
			})
		else
			Game.SendToHost("NewCard", {
				s = suit,
				v = value,
				x = x,
				y = y,
				f = flipped,
				t = tweentox or nil,
				ty = tweentoy or nil,
			})
		end
	end,
	InitializeDeck = function(x, y, cards, tweentox, tweentoy, deckgroup)
		if Game.IsAdmin() then
			local nid = Game.GenerateNetworkID()
			local cards = cards or {}
			local tweento = (tweentox ~= nil or tweentoy ~= nil)
			deck:new({x=x,y=y,cards=cards,networkID = nid, deckgroup = deckgroup, tweentox = tweentox, tweentoy = tweentoy, tweento = tweento}):topDrawOrder()
			Game.SendToClients("NewDeck", {
				x = x,
				y = y,
				n = nid,
				c = cards,
				t = tweentox or nil,
				ty = tweentoy or nil,
				d = deckgroup
			})
		else
			Game.SendToHost("NewDeck", {
				x = x,
				y = y,
				c = cards,
				t = tweentox or nil,
				ty = tweentoy or nil,
				d = deckgroup
			})
		end
	end,
	GenerateNetworkID = function()
		local uniqueid = false
		local id
		local charset = "0123456789abcdef"
		repeat
			uniqueid = true
			id = randomString( charset, 8 )
			for i, v in pairs( Game.Objects ) do
				if v.id == id then
					uniqueid = false
				end
			end
		until uniqueid == true
		return id
	end,
	ConnectMode = "Offline",
	ServerInfo = {
		IP = "",
		Port = 22222
	},
	InternalServer = {
		Server = "", --to be initialized later
		Objects = {

		},
		Clients = {},
	},
	InternalClient = {
		Client = socket.udp()
	},
	SendToHost = function( head, contents )

		return (Game.InternalClient.Client and Game.InternalClient.Client:sendto( Game.PackMessage( head, contents ), Game.ServerInfo.IP, Game.ServerInfo.Port ))
	end,
	SendToClients = function( head, contents )
		if Game.InternalServer.Server then
			for i, v in pairs( Game.InternalServer.Clients ) do
				Game.InternalServer.Server:sendto( Game.PackMessage( head, contents ), v.ip, v.port )
			end
		end
	end,
	PackMessage = function( head, content )
		return table.serialize({h=head,c=content})
	end,
	UnpackMessage = function( msg )
		--[[
			Right now this is a huge security risk but for now I couldn't be arsed.
		]]--
		return loadstring(msg)()
	end,
	Objects = {},
	Zones = {},
	Players = {},
	Selection = {},
	SelectionCanvas = love.graphics.newCanvas(),
	Globals = {
		Gamestate = "Table",
		CardWidth = 38,
		CardHeight = 61,
	},
	Identity = love.filesystem.getIdentity(),
	Images = {},
	Sounds = {
		ButtonForward = love.audio.newSource("assets/sounds/button-forward.wav"),
		ButtonBackward = love.audio.newSource("assets/sounds/button-backward.wav"),
		ButtonNew = love.audio.newSource("assets/sounds/button-high.wav"),
		CardPlace = {
			love.audio.newSource("assets/sounds/cardPlace1.wav"),
			love.audio.newSource("assets/sounds/cardPlace2.wav"),
			love.audio.newSource("assets/sounds/cardPlace3.wav"),
			love.audio.newSource("assets/sounds/cardPlace4.wav"),
		},
		CardSlide = {
			love.audio.newSource("assets/sounds/cardSlide1.wav"),
			love.audio.newSource("assets/sounds/cardSlide2.wav"),
			love.audio.newSource("assets/sounds/cardSlide3.wav"),
			love.audio.newSource("assets/sounds/cardSlide4.wav"),
			love.audio.newSource("assets/sounds/cardSlide5.wav"),
			love.audio.newSource("assets/sounds/cardSlide6.wav"),
			love.audio.newSource("assets/sounds/cardSlide7.wav"),
			love.audio.newSource("assets/sounds/cardSlide8.wav"),
		},
	},
	Scale = {
		x = 1280/love.graphics.getWidth(),
		y = 720/love.graphics.getHeight()
	},
	Template = "",
	SaveTemplate = function( templateName )

		if ui.state == "NewTemplate" then
			local env = Game.Objects
			local saveinfo = {
				deckgroups = {},
				decks = {},
				cards = {},
			}
			for i, v in pairs( env ) do
				if v.type == "deckgroup" then
					table.insert( saveinfo.deckgroups, {
						id = v.id,
						preset = v.preset,
						cards = v.cards,
						allowrepeats = false,
					})
				elseif v.type == "deckTemplate" then
					
					local cards = {}
					for k, z in pairs( v.cards ) do
						table.insert( cards, {
							suit = z.suit,
							value = z.value,
							flipped = z.flipped,
							deckgroup = v.deckgroup
						})
					end
					table.insert( saveinfo.decks, {
						x = v.x,
						y = v.y,
						cards = cards,
						deckgroup = v.deckgroup,
					})
				elseif v.type == "cardTemplate" then
					table.insert( saveinfo.cards, {
						x = v.x,
						y = v.y,
						suit = v.suit,
						value = v.value,
						flipped = v.flipped,
						deckgroup = v.deckgroup
					})
				end
			end
			local templateName = templateName or "UntitledTemplate"
			print("Saving to" .. "/templates/" .. templateName )
			if not love.filesystem.isDirectory("/templates/") then
				love.filesystem.createDirectory("/templates/")
				print("created templates directory")
			end
			if not love.filesystem.isDirectory("/user/") then
				print("created user directory")
				love.filesystem.createDirectory("/user/")
				love.filesystem.createDirectory("/user/templates/")
			end
			love.filesystem.write("/templates/"..templateName..".lua", table.serialize( saveinfo )) 
		end
	end,
	LoadTemplate = function(template, toGame)
		if love.filesystem.isFile("/templates/"..template..".lua") then

			local templateData = love.filesystem.load("/templates/"..template..".lua")()

			if not toGame then
				--Loading template to be edited in the template builder--
				local cardsToPlace = {}
				for i, v in ipairs( templateData.cards ) do
					Game.InitializeCard(v.suit, v.value, v.x, v.y, v.flipped, nil, nil, v.deckgroup)
				end
				for i, v in ipairs( templateData.decks ) do
					--[[deckTemplate:new({
						x = v.x,
						y = v.y,
						cards = v.cards,
						deckgroup = v.deckgroup
					})-]]
					Game.InitializeDeck(v.x, v.y, v.cards, nil, nil, v.deckgroup)
				end
			else
				--Loading templated to be played with--
				for _, deckgroup in pairs( templateData.deckgroups ) do
					local cardsToPlace = {}
					local suits = {
						c = "clubs",
						d = "diamonds",
						h = "hearts",
						s = "spades",
						clubs = "c",
						diamonds = "d",
						hearts = "hearts",
						spades = "spades",
					}
					for suitname, suit in pairs( deckgroup.preset ) do
						for _, card in pairs( suit ) do
							print(card)
							table.insert(cardsToPlace, suitname:sub(1,1)..card)
						end
					end
					--if deckgroup.shuffled then
						shuffleTable(cardsToPlace)
					--end

					
					for _, obj in ipairs( templateData.cards ) do
						if obj.deckgroup == deckgroup.id then
							local suit = obj.suit
							local value = obj.value
							local flipped = obj.flipped
							local CardToRemove = 1
							if suit == "any" then
								suit = suits[cardsToPlace[1]:sub(1,1)]
							else
								for i=1, #cardsToPlace do
									if cardsToPlace:sub(1,1) == suit then
										suit = suits[cardsToPlace[i]:sub(1,1)]
										CardToRemove = i
										break
									end
								end
							end
							if value == "any" then
								value = cardsToPlace[1]:sub(2,3)
							else
								for i=1, #cardsToPlace do
									if cardsToPlace:sub(2,3) == value and cardsToPlace:sub(1,1) == suits[suit] then
										CardToRemove = i
										break
									end
								end
							end
							Game.InitializeCard(suit, value, obj.x, obj.y, flipped)
							table.remove(cardsToPlace, CardToRemove)
						end
					end
					for _, obj in ipairs( templateData.decks ) do
						if obj.deckgroup == deckgroup.id then
							--if deckgroup.shuffled then
								shuffleTable(cardsToPlace)
							--end
							local cards = {}
							for _, newcard in pairs( obj.cards ) do
								local suit = newcard.suit
								local value = newcard.value
								local flipped = newcard.flipped
								local CardToRemove = 1
								if suit == "any" then
									suit = suits[cardsToPlace[1]:sub(1,1)]
								else
									for i=1, #cardsToPlace do
										if cardsToPlace:sub(1,1) == suit then
											suit = suits[cardsToPlace[i]:sub(1,1)]
											CardToRemove = i
											break
										end
									end
								end
								if value == "any" then
									value = cardsToPlace[1]:sub(2,3)
								else
									for i=1, #cardsToPlace do
										if cardsToPlace:sub(2,3) == value and cardsToPlace:sub(1,1) == suits[suit] then
											CardToRemove = i
											break
										end
									end
								end
								table.insert( cards, {
									suit = suit,
									value = value,
									flipped = flipped,
								})
								table.remove(cardsToPlace, CardToRemove)
							end
							Game.InitializeDeck( obj.x, obj.y, cards )
						end
					end
				end
			end
			Game.Template = template
		end
	end,

	Font = love.graphics.newFont( 16 ),

	getState = function() return Game.Globals.Gamestate end,
}

local a, b = Game.GetNetworkAddress()
Game.UniqueNetworkID = a..":"..b

Cards = {}
for i, v in pairs( love.filesystem.getDirectoryItems( "assets/images/cards/" ) ) do
	Cards[v] = {}
	for k, z in pairs( love.filesystem.getDirectoryItems( "assets/images/cards/" .. v ) ) do
		Cards[v][z:sub(1,-5)] = love.graphics.newImage( "assets/images/cards/" .. v .. "/" .. z )
		Cards[v][z:sub(1,-5)]:setFilter("nearest", "nearest")
	end
end
chipsAndColors = {}
--[[for i, v in pairs(love.filesystem.getDirectoryItems(" assets/images/chips/singles")) do
	chipsAndColors[v] = {}
	for k, z in pairs( love.filesystem.getDirectoryItems("assets/images/"))
--]]
WindowsTouchID = os.clock()

--Random useful functions--
function math.clamp(low, n, high) return math.min(math.max(n, low), high) end
function hex2rgb(hex)
	hex = hex:gsub("#","")
	return {tonumber("0x"..hex:sub(1,2)), tonumber("0x"..hex:sub(3,4)), tonumber("0x"..hex:sub(5,6))}
end
function string.split (str, sep) -- Split string
	local return_array = {}
	for v in string.gmatch(str, "([^"..sep.."]+)") do
		return_array[#return_array+1] = v
	end
	return return_array
end
function string.fromHex (str) -- FF32FF32 -> string
	local nStr = ""
	for i=1, #str/2 do
		local nDex = (i-1)*2
		local nnStr = string.char(tonumber(str:sub(nDex+1,nDex+2),16))
		nStr=nStr..nnStr
	end
	return nStr
end

--Load font awesome dictionary
local dictionaryContents = require("fontAwesome") -- Place in the dictionary or load it from a file. Whichever works best.
dictLines = string.split(dictionaryContents,"\n") -- You can get a string splitting function from stack overflow for lua.
fontAwesome = {}
for i=1, #dictLines do
	local lineSplit = string.split(dictLines[i],":")
	fontAwesome[lineSplit[1]]=string.fromHex(lineSplit[2])
end


DeckPresets = {
	Standard52Deck = {
		diamonds = {
			"2", "3", "4", "5", "6", "7", "8", "9", "10", "j", "q", "k", "a",
		},
		spades = {
			"2", "3", "4", "5", "6", "7", "8", "9", "10", "j", "q", "k", "a",
		},
		hearts = {
			"2", "3", "4", "5", "6", "7", "8", "9", "10", "j", "q", "k", "a",
		},
		clubs = {
			"2", "3", "4", "5", "6", "7", "8", "9", "10", "j", "q", "k", "a",
		},
	},
	SpadesOnly = {
		spades = {
			"2", "3", "4", "5", "6", "7", "8", "9", "10", "j", "q", "k", "a",
		},
	},
	ClubsOnly = {
		clubs = {
			"2", "3", "4", "5", "6", "7", "8", "9", "10", "j", "q", "k", "a",
		},
	},
	HeartsOnly = {
		hearts = {
			"2", "3", "4", "5", "6", "7", "8", "9", "10", "j", "q", "k", "a",
		},
	},
	DiamondsOnly = {
		diamonds = {
			"2", "3", "4", "5", "6", "7", "8", "9", "10", "j", "q", "k", "a",
		},
	},
}


Tweens = {
	Data = {
		ShowAdminPanel = {
			x = love.graphics.getWidth()-love.graphics.getWidth()*0.075
		},
		HideAdminPanel = {
			x = love.graphics.getWidth()*.75
		},
		ShowCharmsPanel = {
			x = -75,
		},
		HideCharmsPanel = {
			x = 0,
		}
	}
}

Tweens.Final = {
	ShowAdminPanel = {
		active = false,
		t = tween.new( 0.5, Tweens.Data.ShowAdminPanel, {x=love.graphics.getWidth()*.75}, "inOutExpo"),
		oncomplete = function()
			Tweens.Data.ShowAdminPanel.x = 0
			AdminPanel.x = love.graphics.getWidth()*.75
		end,
	},
	HideAdminPanel = {
		active = false,
		t = tween.new( 0.5, Tweens.Data.HideAdminPanel, {x=love.graphics.getWidth()-love.graphics.getWidth()*0.075}, "inOutExpo"),
		oncomplete = function()
			Tweens.Data.HideAdminPanel.x = 0
			AdminPanel.x = love.graphics.getWidth()-love.graphics.getWidth()*0.075
		end,
	},
	ShowCharmsPanel = {
		active = false,
		t = tween.new(0.4, Tweens.Data.ShowCharmsPanel, {x=0}, "inOutExpo"),
		oncomplete = function()
			Tweens.Data.ShowCharmsPanel.x = 0
		end
	},
	HideCharmsPanel = {
		active = false,
		t = tween.new(0.4, Tweens.Data.HideCharmsPanel, {x=-75}, "inOutExpo"),
		oncomplete = function()
			Tweens.Data.HideCharmsPanel.x = 0

			SHOWCHARMS = false
		end
	}
}