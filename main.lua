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
require "copy"
socket = socket or require "socket"
local http = require("socket.http")

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

	ui.update( dt )
	if Windows then
		if touch.hasTouch(WindowsTouchID) then
			local x, y = love.mouse.getPosition()
			touch.updatePosition(WindowsTouchID, x, y)
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
	if AdminPanel.substate == "Hidden" and Tweens.Final.HideAdminPanel.active then
		AdminPanel.x = Tweens.Data.HideAdminPanel.x
	elseif AdminPanel.substate == "Main" and Tweens.Final.ShowAdminPanel.active then
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
				table.insert(Game.InternalServer.Clients, {ip = ip, port = port})
			elseif data.h == "NewCard" then
				Game.InitializeCard( data.c.s, data.c.v, data.c.x, data.c.y, data.c.f, data.c.t, data.c.ty )
			elseif data.h == "NewDeck" then
				Game.InitializeDeck( data.c.x, data.c.y, data.c.c, data.c.t, data.c.ty )
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
			elseif data.h == "FLIP" then
				local nid = data.c.n;
				for i, v in pairs( Game.Objects ) do
					if v.networkID == nid then
						v.flipped = data.c.f
						return
					end
				end
			elseif data.h == "DRAWCARD" then
				for i, v in pairs( Game.Objects ) do
					if v.networkID == data.c.n then
						v:onSingleTap()
					end
				end
			elseif data.h == "STACK" then
				Game.InitializeDeck(data.c.x, data.c.y, data.c.c)
			end
		end
	elseif Game.ConnectMode == "Client" then

		local data, ip, port = Game.InternalClient.Client:receivefrom()
		if data then
		
			print( data )
			data = Game.UnpackMessage( data )
			if data.h == "NewCard" then
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
		local x = 0
		if Tweens.Final.ShowCharmsPanel.active then
			x = Tweens.Data.ShowCharmsPanel.x
		elseif Tweens.Final.HideCharmsPanel.active then
			x = Tweens.Data.HideCharmsPanel.x
		end
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
	for i, v in ipairs( Game.Objects ) do
		if v.draw then v:draw() end
	end
	
	if (#Game.Selection > 0) then
		Game.SelectionCanvas:renderTo(function()
			love.graphics.clear()
			for i, v in pairs( Game.Selection ) do
				v:draw()
			end
		end)
		love.graphics.draw( Game.SelectionCanvas )
	end

	touch.draw()
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