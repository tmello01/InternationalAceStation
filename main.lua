--[=[

	  _____       _                        _   _                   _ 
	 |_   _|     | |                      | | (_)                 | |
	   | |  _ __ | |_ ___ _ __ _ __   __ _| |_ _  ___  _ __   __ _| |
	   | | | '_ \| __/ _ \ '__| '_ \ / _` | __| |/ _ \| '_ \ / _` | |
	  _| |_| | | | ||  __/ |  | | | | (_| | |_| | (_) | | | | (_| | |
	 |___/\|_| |_|\__\___|_|  |_| |_|\__,_|\__|_|\___/|_| |_|\__,_|_|
	    /  \   ___ ___                                               
	   / /\ \ / __/ _ \                                              
	  / ____ \ (_|  __/                                              
	 /_/____\_\___\___|   _                                          
	  / ____| |      | | (_)                                         
	 | (___ | |_ __ _| |_ _  ___  _ __                               
	  \___ \| __/ _` | __| |/ _ \| '_ \                              
	  ____) | || (_| | |_| | (_) | | | |                             
	 |_____/ \__\__,_|\__|_|\___/|_| |_|                             
                                       
	---------

	Special thanks to Simon Rahnasto for all his help. :)

	Programmed by Eric Bernard and Tyler Mello. 
	Art by Armen Eghian, Justin Stevens, Dylan Ross, Lore Bellavance, and Alex Mullin	

]=]--
soft = require "soft"
require "copy"
socket = socket or require "socket"
local http = require("socket.http")

local colors = {
	"#2196f3","#e91e63","#f44336","#4caf50","#ff9800","#ff5722","#009688","#ffeb3b",
}


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

CANMAKETOUCH = true

SHOWHAND = false
--hehe, show handy. it's supposed to be show hand y, but oh well
SHOWHANDY = soft:new(love.graphics.getHeight() - 15)
SHOWCHARMSX = soft:new(-75)
SHOWCHARMSX:setSpeed(0.1)

selections = {} --For storing location of selections
selectionCards = {} --For storing contents of selections

require "ser"
tween = require "tween"
require "camera"
timer = require "timer"
touch = require "touch"
ui = require "ui"
require "game"
require "menus"
card = require "assets/card"
deck = require "assets/deck"
deckTemplate = require "assets/deckTemplate"
cardTemplate = require "assets/cardTemplate"
deckgroupTemplate = require "assets/deckgroup"
utf8 = require "utf8"
local Windows = love.system.getOS() == "Windows"

love.graphics.setBackgroundColor( hex2rgb("#2E7D32") )


function love.load()
	
	makeMenus()

end

function love.update( dt )
	soft:update( dt )
	ui.update( dt )
	if Windows then
		if touch.hasTouch(WindowsTouchID) then
			local x, y = love.mouse.getPosition()
			touch.updatePosition(WindowsTouchID, x, y)
		end
	end


	--Update all the cards in the hand--
	local w = love.graphics.getWidth()/2
	local sx = love.graphics.getWidth()/4
	local cardsInHand = #Game.Hand
	for i, v in pairs( Game.Hand ) do
		for k, z in pairs( Game.Objects ) do
			if z.networkID == v and not z.dragged then
				z.x = sx + (40)*i
				z.y = SHOWHANDY:get() - 15
			end
		end
	end


	for i, v in pairs( Tweens.Final ) do
		if v.active then
			if v.t:update( dt ) then
				if v.oncomplete then v.oncomplete() end
				v.active = false
				v.t:reset()
			end
		end
	end
	if AdminPanel._substate == "Hidden" and Tweens.Final.HideAdminPanel.active then
		AdminPanel.x = Tweens.Data.HideAdminPanel.x
	elseif AdminPanel._substate == "Main" and Tweens.Final.ShowAdminPanel.active then
		AdminPanel.x = Tweens.Data.ShowAdminPanel.x
	end

	for _, v in pairs( Game.Objects ) do
		if v.update then v:update(dt) end
	end

	if Game.ConnectMode == "Host" then
		local data, ip, port = Game.InternalServer.Server:receivefrom()
		if data then
			data = Game.UnpackMessage(data)
			if data.h == "Connect" then
				Game.UpdateClientList()
				local tableContents = {}
				for i, v in pairs( Game.Objects ) do
					if v.type == "card" then
						table.insert( tableContents, {
							x = v.x,
							y = v.y,
							v = v.value,
							s = v.suit,
							f = v.flipped,
							n = v.networkID,
							t = "c",
						})
					elseif v.type == "deck" then
						table.insert( tableContents, {
							x = v.x,
							y = v.y,
							n = v.networkID,
							c = v.cards,
							t = "d",
						})
					end
				end
				Game.InternalServer.Server:sendto(Game.PackMessage("ConnectAttemptSuccess",tableContents),ip,port)
				table.insert(Game.InternalServer.Clients, {name = data.c.n, color = hex2rgb(colors[love.math.random(1,#colors)]), ip = ip, port = port})
			elseif data.h == "NewCard" then
				Game.InitializeCard( data.c.s, data.c.v, data.c.x, data.c.y, data.c.f, data.c.t, data.c.ty )
			elseif data.h == "NewDeck" then
				Game.InitializeDeck( data.c.x, data.c.y, data.c.c, data.c.t, data.c.ty )
			elseif data.h == "PUTINHAND" then
				for i, v in pairs( Game.Objects ) do
					if v.networkID == data.c.n and Game.UniqueNetworkID ~= data.c.o then
						v:removeSilent()
					end
					Game.SendToClients("PUTINHAND", data.c)
				end
			elseif data.h == "TAKEOUTHAND" then
				-- suit, value, x, y, flipped, tweentox, tweentoy, deckgroup, nid 
				Game.InitializeCard(data.c.s, data.c.v, data.c.x, data.c.y, data.c.f, nil, nil, nil, data.c.n)
			elseif data.h == "MOVE" then
				local nid = data.c.n;
				for i, v in pairs( Game.Objects ) do
					if v.networkID == nid then
						v.x = data.c.x
						v.y = data.c.y
						v:topDrawOrder()
						return
					end
				end
				Game.SendToClients( "MOVE", data.c )
			elseif data.h == "REMOVE" then
				local nid = data.c.n;
				for i, v in pairs( Game.Objects ) do
					if v.networkID == nid then
						v:remove()
						return
					end
				end
			elseif data.h == "FLIP" then
				local nid = data.c.n;
				for i, v in pairs( Game.Objects ) do
					if v.networkID == nid then
						v.flipped = data.c.f
						return
					end
				end
				Game.SendToClients( "FLIP", data.c )
			elseif data.h == "DRAWCARD" then
				for i, v in pairs( Game.Objects ) do
					if v.networkID == data.c.n then
						v:onSingleTap()
					end
				end
			elseif data.h == "STACK" then
				Game.InitializeDeck(data.c.x, data.c.y, data.c.c)
			elseif data.h == "PULSE" then
			elseif data.h == "STARTSELECT" then
				selections[data.c.o] = {
					x1 = data.c.x,
					y1 = data.c.y,
					x2 = data.c.x,
					y2 = data.c.y,
				}
				Game.SendToClients("STARTSELECT", data.c)
			elseif data.h == "MOVESELECT" then
				selections[data.c.o] = {
					x1 = data.c.sx,
					y1 = data.c.sy,
					x2 = data.c.x,
					y2 = data.c.y
				}
				Game.SendToClients("STARTSELECT", data.c)
			elseif data.h == "SHUFFLE" then
				for i, v in pairs( Game.Objects ) do
					if v.networkID == data.c.n then
						v.cards = data.c.c
						v.gotostart = tween.new(0.3, v, {x = data.c.x, y = data.c.y}, "inOutExpo")
						v.tweenback = true
					end
					Game.SendToClients( "SHUFFLE", data.c )
				end
			elseif data.h == "ENDSELECT" then
				selections[data.c.o] = nil
				Game.SendToClients("ENDSELECT", data.c)
			end
		end
	elseif Game.ConnectMode == "Client" then

		local data, ip, port = Game.InternalClient.Client:receivefrom()
		if data then
		
			print( data )
			data = Game.UnpackMessage( data )
			if data.h == "NewCard" then
				for i, v in pairs( Game.Objects ) do
					if v.networkID == data.c.n then
						return
					end
				end
				card:new({
					x = data.c.x,
					y = data.c.y,
					suit = data.c.s,
					value = data.c.v,
					flipped = data.c.f,
					networkID = data.c.n,
					tweentox = data.c.t,
					tweentoy = data.c.ty,
				}):topDrawOrder()
			elseif data.h == "NewDeck" then
				deck:new({
					x = data.c.x,
					y = data.c.y,
					networkID = data.c.n,
					cards = data.c.c,
					tweentox = data.c.t,
					tweentoy = data.c.ty,
				}):topDrawOrder()
			elseif data.h == "PUTINHAND" then
				if data.c.o ~= Game.UniqueNetworkID then
					for i, v in pairs( Game.Objects ) do
						if v.networkID == data.c.n then
							v:removeSilent()
						end
					end
				end
			elseif data.h == "TAKEOUTHAND" then
				--Game.InitializeCard(data.c.s, data.c.v, data.c.x, data.c.y, data.c.f, nil, nil, nil, data.c.n)
				card:new({
					suit = data.c.s,
					value = data.c.v,
					x = data.c.x,
					y = data.c.y,
					flipped = data.c.f,
					networkID = data.c.n
				}):topDrawOrder()
			elseif data.h == "STARTSELECT" then
				selections[data.c.o] = {
					x1 = data.c.x,
					y1 = data.c.y,
					x2 = data.c.x,
					y2 = data.c.y,
				}
			elseif data.h == "MOVESELECT" then
				selections[data.c.o] = {
					x1 = data.c.sx,
					y1 = data.c.sy,
					x2 = data.c.x,
					y2 = data.c.y
				}
			elseif data.h == "ENDSELECT" then
				selections[data.c.o] = nil
				print( #data.c.c, data.c.o )
				if #data.c.c > 0 and data.c.o ~= Game.UniqueNetworkID then
					for i, v in pairs( data.c.c ) do
						for k, z in pairs( Game.Objects ) do
							if z.networkID == v then
								z.netSelected = true
								z.owner = data.c.o
								z.dragx = z.x
								z.dragy = z.y
								selectionCards[data.c.o] = selectionCards[data.c.o] or {}
								table.insert( selectionCards[data.c.o], z.networkID )
							end
						end
					end
				end
			elseif data.h == "SHUFFLE" then
				for i, v in pairs( Game.Objects ) do
					if v.networkID == data.c.n then
						v.cards = data.c.c
						v.gotostart = tween.new(0.3, v, {x = data.c.x, y = data.c.y}, "inOutExpo")
						v.tweenback = true
						return
					end
				end
			elseif data.h == "UPDATEDECK" then
				local nid = data.c.n;
				for i, v in pairs( Game.Objects ) do
					if v.networkID == nid then
						v.cards = data.c.c
						return
					end
				end
			elseif data.h == "PULSE" then
				Game.SendToHost("PULSE", {})
			elseif data.h == "FLIP" then
				local nid = data.c.n;
				for i, v in pairs( Game.Objects ) do
					if v.networkID == nid then
						v.flipped = data.c.f
						return
					end
				end
			elseif data.h == "MOVE" then
				local nid = data.c.n;
				for i, v in pairs( Game.Objects ) do
					if v.networkID == nid then
						v.x = data.c.x
						v.y = data.c.y
						v:topDrawOrder()
						return
					end
				end
			elseif data.h == "REMOVE" then
				local nid = data.c.n;
				for i, v in pairs( Game.Objects ) do
					if v.networkID == nid then
						v:remove()
						return
					end
				end
			end
		end
	end

end

function love.draw()
	ui.draw()
	if SHOWCHARMS then
		local x = SHOWCHARMSX:get()
		love.graphics.setColor(42, 42, 42)
		love.graphics.rectangle("fill", x, 0, 75, love.graphics.getHeight())
		love.graphics.setColor(255, 255, 255)
		love.graphics.setFont(ui.font(50, "FontAwesome"))
		love.graphics.print(fontAwesome['fa-trash-o'], 15+x, 15 )
		if SHOWDECKCHARMS then
			love.graphics.print(fontAwesome['fa-random'], 15+x, love.graphics.getHeight()/2-35)
			love.graphics.print(fontAwesome['fa-arrows-h'], 15+x, love.graphics.getHeight()-95)
		end
	end
	
	if ui.state == "Main" then
		love.graphics.setColor( 42, 42, 42 )
		love.graphics.rectangle("fill", love.graphics.getWidth() / 4, SHOWHANDY:get(), love.graphics.getWidth()/2, 150)
		love.graphics.setColor( 255, 255, 255 )
	end
	for i, v in ipairs( Game.Objects ) do
		if v.draw then v:draw() end
	end
	
	if (#Game.Selection > 0) then
		Game.SelectionCanvas:renderTo(function()
			love.graphics.clear()
			for i, v in pairs( Game.Selection ) do
				for k, z in pairs( Game.Objects ) do
					if z.networkID == v then
						z:draw()
					end
				end
			end
		end)
		love.graphics.draw( Game.SelectionCanvas )
	end

	touch.draw()
	for i, v in pairs( selections ) do
		if i ~= Game.UniqueNetworkID then
			local x1 = math.min(v.x1, v.x2)
			local x2 = math.max(v.x1, v.x2)
			local y1 = math.min(v.y1, v.y2)
			local y2 = math.max(v.y1, v.y2)
			love.graphics.setColor( 0, 0, 0 )
			love.graphics.rectangle("line", x1, y1, x2-x1, y2-y1)
			love.graphics.setColor( 255, 255, 255 )
		end
	end
	ui.drawAbove()
	love.graphics.setFont(Game.Font)
end

--don't judge
function love.textinput( t )
   ui.textinput( t )
end

function love.keyreleased( key )
	ui.keyreleased( key )
end
function love.keypressed( key )
	ui.keypressed( key )
end


if Windows then
	function love.mousepressed( x, y, button )
		if button == 1 then
			ui.mousepressed( x, y, button )
			touch.remove( WindowsTouchID, x, y )
			
			WindowsTouchID = os.clock()
			touch.new( WindowsTouchID, x, y )
		end
	end

	function love.mousereleased( x, y, button )
		ui.mousereleased( x, y, button )
		touch.remove( WindowsTouchID, x, y )
	end
else
	function love.touchpressed( id, x, y )
		touch.remove( WindowsTouchID, x, y )
		
		WindowsTouchID = os.clock()
		touch.new( WindowsTouchID, x, y )
		ui.mousepressed( x, y, 1 )
	end

	function love.touchreleased( id, x, y )
		touch.remove( WindowsTouchID, x, y )
		ui.mousereleased( x, y, 1 )
	end

	function love.touchmoved( id, x, y )
		touch.updatePosition( WindowsTouchID, x, y )
	end
end