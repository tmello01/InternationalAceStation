function makeMenus()

	local values = {"a","2","3","4","5","6","7","8","9","10","j","q","k"}
	local suits = { "diamonds", "clubs", "hearts", "spades" }
	local HiddenSize = love.graphics.getWidth()*0.075
	local PanelW = love.graphics.getWidth()/4
	local splashes = {
		"Give me some space!",
		"This game just launched!",
		"Woaaahhhhh....",
		"The view is awesome!",
		"I can see my house from here!",
		"I'm telling you, the earth is flat!",
		"There's no way the earth is flat!",
		"I forgot my keys at home!",
		"Breaking the speed limit by 17,985mp/h!",
		"Circumnavigating in 100 minutes or less!",
		"All the people look like ants from here!",
		"I can see his wall from here!",
	}

	AdminPanel = ui.new({w=PanelW, h = love.graphics.getHeight(), x = love.graphics.getWidth()-HiddenSize, substate="Hidden"})
	AdminPanel:add("text", {text = "MANAGE GAME", x = 10, y=10, font = ui.font(35)})
	AdminPanel:add("text", {text = "Add Items", align="center", y = 55, font = ui.font(20)})
	FlipCards = AdminPanel:add("radio", {label = "Flip cards?", y = 100+math.floor(AdminPanel.w/2), align="center"})
	RandomDeck = AdminPanel:add("radio", {label = "Random deck?", active = true, y = 140+math.floor(AdminPanel.w/2), align="center"})
	NewCardButton = AdminPanel:add("button", {
		w = math.floor(AdminPanel.w/2),
		h = math.floor(AdminPanel.w/2),
		y = 80,
		background = {33,150,243},
		foreground = {255, 255, 255},
		text = "Card",
	})
	NewCardButton.onclick = function()
		card:new({
			x = love.math.random(0, love.graphics.getWidth()*0.75
				),
			y = love.math.random(0, love.graphics.getHeight()-100),
			suit = suits[love.math.random(1,4)],
			value = values[love.math.random(1,13)],
			flipped = FlipCards.active,
		})
	end
	NewDeckButton = AdminPanel:add("button", {
		x = math.ceil(AdminPanel.w/2),
		y = 80,
		w = math.floor(AdminPanel.w/2),
		h = math.floor(AdminPanel.w/2),
		background = {56, 142, 60},
		foreground = {255, 255, 255},
		text = "Deck",
	})
	NewDeckButton.onclick = function()
		if RandomDeck.active then --we'll fix this later.
			local c = {}
			for i = 1, love.math.random( 20, 30 ) do
				c[#c+1] = {
					suit = suits[love.math.random(1,4)],
					value = values[love.math.random(1,13)],
					flipped = FlipCards.active,
				}
			end
			deck:new({cards=c, x = love.math.random(0,200), y = love.math.random(0, 200)})
		else
			local c = {}
			local values = {"a","2","3","4","5","6","7","8","9","10","j","q","k"}
			local suits = { "diamonds", "clubs", "hearts", "spades" }
			for i, v in pairs( suits ) do
				for k, z in pairs( values ) do
					table.insert( c, {
						value = z,
						suit = v,
						flipped = FlipCards.active
					})
				end
			end
			deck:new({cards=c, x = love.math.random(0,200), y = love.math.random(0, 200)})
		end
	end
	ToMainMenu = AdminPanel:add("button", {
		w = AdminPanel.w,
		background = hex2rgb("#B71C1C"),
		foreground = { 255, 255, 255 },
		text = "Return to Menu",
		h = 75,
		y = AdminPanel.h - 75,
	})
	ToMainMenu.onclick = function()
		ui.state = "Menu"
	end
	HideMenuButton = AdminPanel:add("button", {
		w = 50,
		h = 50,
		x = AdminPanel.w-50,
		background = hex2rgb("#B71C1C"),
		text = "x",
	})
	HideMenuButton.onclick = function()
		AdminPanel.substate = "Hidden"
		--AdminPanel.x = love.graphics.getWidth()-love.graphics.getWidth()*0.075
		Tweens.Final.HideAdminPanel.active = true
	end
	ClearButton = AdminPanel:add("button", {
		w = AdminPanel.w,
		h = 50,
		y = AdminPanel.h-125,
		background = hex2rgb("#E53935"),
		text = "Clear Board",
	})
	ClearButton.onclick = function()
		Game.Objects = {}
	end
	ShowMenuButton = AdminPanel:add("button", {
		w = HiddenSize,
		h = AdminPanel.h,
		background = {210, 210, 210},
		foreground = {0, 0, 0},
		text = "<<<",
		substate = "Hidden",
	})
	ShowMenuButton.onclick = function()
		AdminPanel.substate = "Main"
		--AdminPanel.x = love.graphics.getWidth()-love.graphics.getWidth()/4
		Tweens.Final.ShowAdminPanel.active = true
	end

	local ww, wh = love.graphics.getWidth(), love.graphics.getHeight()
	PresetDecksPanel = ui.new({w = ww/2, h = wh/2, x = ww/4, y = wh/4, state = "NewDeck"})
	PresetDecksPanel:add("text", {text="Preset Decks", align="center", y = 10, font = ui.font(26)})
	Standard = PresetDecksPanel:add("button", {
		y = 50,
		w = PresetDecksPanel.w/4,
		background = hex2rgb("#9C27B0"),
		text = "Standard",
	})
	Standard.onclick = function()
		ui.state = "Main"
		local values = {"a","2","3","4","5","6","7","8","9","10","j","q","k"}
		local suits = { "diamonds", "clubs", "hearts", "spades" }
		local cards = { }
		for i, v in pairs(suits) do
			for k, z in pairs( values ) do
				table.insert( cards, {
					suit = v,
					value = z,
					flipped = false,
				})
			end
		end
		deck:new({cards=cards})
	end
	StandardFlipped = PresetDecksPanel:add("button", {
		y = 50,
		x = PresetDecksPanel.w/4,
		w = PresetDecksPanel.w/4,
		background = hex2rgb("#F44336"),
		text = "Standard [f]",
	})
	StandardFlipped.onclick = function()
		print("clicked")
		ui.state = "Main"
		local values = {"a","2","3","4","5","6","7","8","9","10","j","q","k"}
		local suits = { "diamonds", "clubs", "hearts", "spades" }
		local cards = { }
		for i, v in pairs(suits) do
			for k, z in pairs( values ) do
				table.insert( cards, {
					suit = v,
					value = z,
					flipped = true,
				})
			end
		end
		deck:new({cards=cards})
	end



	MainMenu = ui.new({
		state = "Menu",
		w = love.graphics.getWidth(),
		h = love.graphics.getHeight(),
		background = { 255, 255, 255 },
	})
	MainMenu:add("text", {
		foreground = hex2rgb("#2196F3"),
		align="center",
		y = 100,
		text = "International Ace Station",
		font = ui.font(64),
	})
	MainMenu:add("text", {
		foreground = hex2rgb("#64B5F6"),
		align="center",
		y = 160,
		font = ui.font(36, "Roboto-LightItalic"),
		text = "\"" .. splashes[love.math.random(1,#splashes)] .. "\"",
	})
	StartButton = MainMenu:add("button", {
		background = hex2rgb("#2196F3"),
		foreground = { 255, 255, 255 },
		text = "Start Game",
		w = love.graphics.getWidth()/2,
		align = "center",
		y = 225,
		font = ui.font(20),
	})
	StartButton.onclick = function()
		ui.state = "Main"
	end
	NewSceneButton = MainMenu:add("button", {
		background = hex2rgb("#2196F3"),
		foreground = { 255, 255, 255 },
		text = "New Game Template",
		w = love.graphics.getWidth()/2,
		align = "center",
		y = 350,
		font = ui.font(20)
	})
	NewSceneButton.onclick = function()
		ui.state = "NewTemplate"
	end
	QuitButton = MainMenu:add("button", {
		background = hex2rgb("#2196F3"),
		foreground = { 255, 255, 255 },
		text = "Quit Game", 
		w = love.graphics.getWidth()/2,
		align = "center",
		y = 475,
		font = ui.font(20),
	})
	QuitButton.onclick = function()
		love.event.quit()
	end

	TemplateAdminPanel = ui.new({
		w = love.graphics.getWidth()/4,
		x = love.graphics.getWidth() - love.graphics.getWidth()*0.075,
		h = love.graphics.getHeight(),
		background = { 255, 255, 255 },
		foreground = { 0, 0, 0 },
		state = "NewTemplate",
		substate = "Hidden",
	})
	ShowTemplatePanel = TemplateAdminPanel:add("button", {
		w = love.graphics.getWidth()*0.075,
		substate = "Hidden",
		h = love.graphics.getHeight(),
		text = "<<<",
	})
	ShowTemplatePanel.onclick = function()
		TemplateAdminPanel.substate = "Main"
		TemplateAdminPanel.x = love.graphics.getWidth()*.75
	end
	HideTemplatePanel = TemplateAdminPanel:add("button", {
		w = TemplateAdminPanel.w,
		h = 75,
		y = TemplateAdminPanel.h-75,
		text = "Hide Panel >>>"
	})
	HideTemplatePanel.onclick = function()
		TemplateAdminPanel.substate = "Hidden"
		TemplateAdminPanel.x = love.graphics.getWidth() - love.graphics.getWidth()*0.075
	end
	TemplateName = TemplateAdminPanel:add("textinput", {
		w = TemplateAdminPanel.w - 25,
		y = 10,
		align = "center",
		font = ui.font(20),
		placeholder = "Template Name",
	}),
	TemplateAdminPanel:add("text", {
		text = "ADD ITEMS",
		font = ui.font(20),
		align="center",
		y = 65,
	})
	NewTemplateDeckButton = TemplateAdminPanel:add("button", {
		w = TemplateAdminPanel.w/2,
		h = TemplateAdminPanel.w/2,
		text = "Add Deck",
		y = 95,
	})
	NewTemplateDeckButton.onclick = function()
		TemplateAdminPanel.substate = "NewDeck"
	end

	TemplateAdminPanel:add("text", {
		text = "ADD DECK", 
		font = ui.font(26),
		y = 10,
		substate = "NewDeck",
		x = 10
	})
	B = TemplateAdminPanel:add("button", {
		substate = "NewDeck",
		background = hex2rgb("#F44336"),
		w = 50,
		h = 50,
		x = TemplateAdminPanel.w-50,
		foreground = { 255, 255, 255 },
		text = "x",
		font = ui.font(20)
	})
	B.onclick = function()
		TemplateAdminPanel.substate = "Main"
	end
	CardAmtInput = TemplateAdminPanel:add("textinput", {
		w = TemplateAdminPanel.w - 25,
		font = ui.font(18),
		placeholder = "Amount of Cards",
		maxlength = 3,
		align = "center",
		substate = "NewDeck",
		y =	60,
	})
	TemplateFlippedCards = TemplateAdminPanel:add("radio", {
		label = "Cards Flipped?",
		align = "center",
		y = 115,
		font = ui.font(18),
		substate = "NewDeck",
	})
	TemplateAllowDuplicates = TemplateAdminPanel:add("radio", {
		label = "Allow duplicates?",
		align = "center",
		y = 150,
		font = ui.font(18),
		substate = "NewDeck",
	})
	TemplateAllowDuplicates.onchange = function()
		if not TemplateAllowDuplicates.active then
			if tonumber(CardAmtInput.text) > 52 then
				CardAmtInput.text = "52"
			end
		end
	end

	ConfirmNewDeck = TemplateAdminPanel:add("button", {
		w = TemplateAdminPanel.w,
		h = 100,
		y = TemplateAdminPanel.h-100,
		background = hex2rgb("#43A047"),
		foreground = { 255, 255, 255 },
		text = "Create Deck",
		substate = "NewDeck"
	})
	ConfirmNewDeck.onclick = function()
		local c = {}
		local lim = tonumber(CardAmtInput.text) or 10
		for i=1, lim do
			table.insert( c, {
				value = "any",
				suit = "any",
				flipped = TemplateFlippedCards.active,
			})
		end
		deckTemplate:new({cards=c})
		TemplateAdminPanel.substate = "Main"
	end

end