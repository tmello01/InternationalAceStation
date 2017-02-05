local values = {"a","2","3","4","5","6","7","8","9","10","j","q","k"}
local suits = { "diamonds", "clubs", "hearts", "spades" }
local splashes = {
	"Give me some space!",
	"This game just launched!",
	"Woaaahhhhh....",
	"The view is awesome from here!",
	"I can see my house from here!",
	"I'm telling you, the earth is flat!",
	"There's no way the earth is flat!",
	"I forgot my keys at home!",
	"Breaking the speed limit by 17,985mp/h!",
	"Circumnavigating in 100 minutes or less!",
	"All the people look like ants from here!",
	"Did I leave the stove on?",
}
local function makeMainMenu()
	
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
	SplashText = MainMenu:add("text", {
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
		ui.state = "ChooseGame"
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
		sound = Game.Sounds.ButtonBackward,
	})
	QuitButton.onclick = function()
		love.event.quit()
	end

end

local function makeGameTypePanel()

	GameSelection = ui.new({
		background = hex2rgb("#1976D2"),
		w = love.graphics.getWidth(),
		h = love.graphics.getHeight(),
		foreground = { 255, 255, 255 },
		state = "ChooseGame",
	})

	local middle = math.ceil(love.graphics.getHeight()/2)
	GameSelection:add("button", {
		y = middle-105,
		h = 100,
		background = { 255, 255, 255 },
		foreground = hex2rgb("#1976D2"),
		w = love.graphics.getWidth()/2,
		text = "HOST GAME",
		font = ui.font(30,"Roboto-Bold"),
		align = "center",
	}).onclick = function()
		GameSelection.substate = "HostGame"
		Game.Mode = "HOST"
	end
	GameSelection:add("button", {
		y = middle+5,
		h = 100,
		background = { 255, 255, 255 },
		foreground = hex2rgb("#1976D2"),
		w = love.graphics.getWidth()/2,
		text = "JOIN GAME",
		font = ui.font(30,"Roboto-Bold"),
		align = "center",
	}).onclick = function()
		GameSelection.substate = "JoinGame"
		Game.Mode = "JOIN"
	end
	GameSelection:add("button", {
		y = middle + 115,
		background = { 255, 255, 255 },
		foreground = hex2rgb("#1976D2"),
		text = "Cancel",
		h = 50,
		font = ui.font(20,"Roboto-Bold"),
		sound = Game.Sounds.ButtonBackward,
		align = "center"
	}).onclick = function()
		ui.state = "Menu"
	end


	GameSelection:add("text", {
		text = "CHOOSE A GAME TYPE",
		foreground = { 255, 255, 255 },
		align = "center",
		font = ui.font(40, "Roboto-Bold"),
		y = 20,
		substate = "HostGame",
	})
	Sandbox = GameSelection:add("radio", {
		group = "Template",
		size = 35,
		font = ui.font(30),
		align = "center",
		foreground = { 255, 255, 255 },
		label = "Sandbox",
		y = 85,
		active = true,
		substate = "HostGame",
	})
	Solitaire = GameSelection:add("radio", {
		group = "Template",
		size = 35,
		font = ui.font(30),
		align = "center",
		foreground = { 255, 255, 255 },
		foregroundinactive = hex2rgb("#64B5F6"),
		selectable = false,
		y = 135,
		label = "Solitaire",
		substate = "HostGame",
	})

	GameSelection:add("text", {
		text = "ROOM SETTINGS",
		align = "center",
		y = 250,
		font = ui.font(30),
		foreground = { 255, 255, 255 },
		substate = "HostGame",
	})

	SinglePlayer = GameSelection:add("radio", {
		group = "ServerClient",
		size = 35,
		font = ui.font(30),
		align = "center",
		foreground = { 255, 255, 255 },
		y = 300,
		label = "Single player",
		active = true,
		substate = "HostGame",
	})

	MultiPlayer = GameSelection:add("radio", {
		group = "ServerClient",

		foregroundinactive = hex2rgb("#64B5F6"),
		selectable = false,
		size = 35,
		font = ui.font(30),
		align = "center",
		foreground = { 255, 255, 255 },
		y = 350,
		label = "Host Room",
		substate = "HostGame",
	})

	GameSelection:add("button", {
		align = "center",
		background = {255, 255, 255},
		font = ui.font(30,"Roboto-Bold"),
		text = "Create Game!",
		sound = Game.Sounds.ButtonNew,
		foreground = hex2rgb("#1976D2"),
		substate = "HostGame",
		w = love.graphics.getWidth()/2,
		y = 425
	}).onclick = function()
		ui.state = "Main"
	end

	GameSelection:add("button", {
		align = "center",
		background = {255, 255, 255},
		font = ui.font(24,"Roboto-Bold"),
		text = "Cancel",
		sound = Game.Sounds.ButtonBackward,
		foreground = hex2rgb("#1976D2"),
		substate = "HostGame",
		w = love.graphics.getWidth()/3,
		h = 75,
		y = 535
	}).onclick = function()
		GameSelection.substate = "Main"
	end


end

local function makeGameAdminPanel()

	
	local HiddenSize = love.graphics.getWidth()*0.075
	local PanelW = love.graphics.getWidth()/4

	AdminPanel = ui.new({w=PanelW, h = love.graphics.getHeight(), x = love.graphics.getWidth()-HiddenSize, substate="Hidden"})
	AdminPanel:add("text", {text = "ADD ITEMS", align="center", y = 45, font = ui.font(25)})
	FlipCards = AdminPanel:add("radio", {label = "Flip cards?", y = 100+math.floor(AdminPanel.w/2), align="center"})
	RandomDeck = AdminPanel:add("radio", {label = "Random deck?", active = true, y = 140+math.floor(AdminPanel.w/2), align="center"})
	AdminPanel:add("button", {
		w = math.ceil(AdminPanel.w/2),
		h = math.floor(AdminPanel.w/2),
		y = 80,
		background = {33,150,243},
		foreground = {255, 255, 255},
		text = "Card",
		sound = Game.Sounds.ButtonNew,
	}).onclick = function()
		card:new({
			x = love.math.random(0, love.graphics.getWidth()*0.75
				),
			y = love.math.random(0, love.graphics.getHeight()-100),
			suit = suits[love.math.random(1,4)],
			value = values[love.math.random(1,13)],
			flipped = FlipCards.active,
		})
	end
	AdminPanel:add("button", {
		x = math.ceil(AdminPanel.w/2),
		y = 80,
		w = math.floor(AdminPanel.w/2),
		h = math.floor(AdminPanel.w/2),
		background = {56, 142, 60},
		foreground = {255, 255, 255},
		text = "Deck",
		sound = Game.Sounds.ButtonNew,
	}).onclick = function()
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
	AdminPanel:add("button", {
		w = AdminPanel.w,
		background = hex2rgb("#B71C1C"),
		foreground = { 255, 255, 255 },
		text = "Return to Menu",
		h = 75,
		y = AdminPanel.h - 75,
	}).onclick = function()
		AdminPanel.substate = "Quit"
	end
	AdminPanel:add("button", {
		w = 35,
		h = 35,
		x = AdminPanel.w-35,
		background = hex2rgb("#B71C1C"),
		font = ui.font(16, "FontAwesome"),
		text = fontAwesome['fa-times'],
		sound = Game.Sounds.ButtonBackward,
	}).onclick = function()
		AdminPanel.substate = "Hidden"
		--AdminPanel.x = love.graphics.getWidth()-love.graphics.getWidth()*0.075
		Tweens.Final.HideAdminPanel.active = true
	end
	AdminPanel:add("button", {
		w = AdminPanel.w,
		h = 50,
		y = AdminPanel.h-125,
		background = hex2rgb("#E53935"),
		text = "Clear Board",
	}).onclick = function()
		Game.Objects = {}
	end
	AdminPanel:add("button", {
		w = HiddenSize,
		h = AdminPanel.h,
		background = {210, 210, 210},
		foreground = {0, 0, 0},
		text = fontAwesome['fa-angle-double-left'],
		font = ui.font(30, "FontAwesome"),
		substate = "Hidden",
	}).onclick = function()
		AdminPanel.substate = "Main"
		--AdminPanel.x = love.graphics.getWidth()-love.graphics.getWidth()/4
		Tweens.Final.ShowAdminPanel.active = true
	end
	AdminPanel:add("text", {
		x = 10,
		y = 10,
		font = ui.font(35, "Roboto-Bold"),
		text = "Quit?",
		align = "center",
		substate = "Quit"
	})
	AdminPanel:add("text", {
		text = "Are you sure you want to quit? All of your progress will be lost.",
		y = 100,
		align = "center",
		substate = "Quit",
		font = ui.font(25),
	})
	AdminPanel:add("button", {
		w = AdminPanel.w,
		h = 75,
		y = AdminPanel.h-75,
		background = hex2rgb("#F44336"),
		text = "QUIT",
		font = ui.font(18),
		substate = "Quit",
		sound = Game.Sounds.ButtonBackward,
	}).onclick = function()
		AdminPanel.substate = "Hidden"
		AdminPanel.x = love.graphics.getWidth()-HiddenSize
		ui.state = "Menu"
		Game.Objects = {}
		SplashText.text = "\"" .. splashes[love.math.random(1,#splashes)] .. "\""
	end
	AdminPanel:add("button",{
		w = AdminPanel.w,
		h = 125,
		y = AdminPanel.h-200,
		background = hex2rgb("#2196F3"),
		font = ui.font(18),
		text = "CANCEL",
		substate = "Quit",
	}).onclick = function()
		AdminPanel.substate = "Main"
	end

end

local function makeTemplateBasePanel()
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
		text = fontAwesome['fa-angle-double-left'],
		font = ui.font(30, "FontAwesome"),
	})
	ShowTemplatePanel.onclick = function()
		TemplateAdminPanel.substate = "Main"
		TemplateAdminPanel.x = love.graphics.getWidth()*.75
	end
	HideTemplatePanel = TemplateAdminPanel:add("button", {
		background = hex2rgb("#F44336"),
		w = 35,
		h = 35,
		x = TemplateAdminPanel.w-35,
		foreground = { 255, 255, 255 },
		text = fontAwesome['fa-times'],
		font = ui.font(20, "FontAwesome"),
		sound = Game.Sounds.ButtonBackward,
	})
	HideTemplatePanel.onclick = function()
		TemplateAdminPanel.substate = "Hidden"
		TemplateAdminPanel.x = love.graphics.getWidth() - love.graphics.getWidth()*0.075
	end
	TemplateName = TemplateAdminPanel:add("textinput", {
		w = TemplateAdminPanel.w - 25,
		y = 75,
		align = "center",
		font = ui.font(20),
		placeholder = "Template Name",
	}),
	TemplateAdminPanel:add("text", {
		text = "ADD ITEMS",
		font = ui.font(20),
		align="center",
		y = 140,
	})
	NewTemplateDeckButton = TemplateAdminPanel:add("button", {
		w = TemplateAdminPanel.w/2,
		h = TemplateAdminPanel.w/2,
		text = "Add Deck",
		y = 170,
	})
	NewTemplateDeckButton.onclick = function()
		TemplateAdminPanel.substate = "NewDeck"
	end

end

local function makeTemplateDeckPanel()
	BackButton = TemplateAdminPanel:add("button", {
		w = ui.font(30, "FontAwesome"):getHeight()+10,
		h = ui.font(30, "FontAwesome"):getHeight()+10,
		background = hex2rgb("#F44336"),
		foreground = {255, 255, 255},
		text = fontAwesome['fa-times'],
		font = ui.font(30,"FontAwesome"),
		substate = "NewDeck",
		x = TemplateAdminPanel.w - ui.font(30, "FontAwesome"):getHeight()-10,
		sound = Game.Sounds.ButtonBackward,
	})
	BackButton.onclick = function()
		TemplateAdminPanel.substate = "Main"
	end
	TemplateAdminPanel:add("text", {
		font = ui.font( 22, "Roboto-LightItalic" ),
		text = "DECK PRESETS", 
		align = "center",
		y = 75,
		substate = "NewDeck",
	})
	Standard52Deck = TemplateAdminPanel:add("radio", {
		x = 10,
		font = ui.font(18),
		label = "Standard 52 Card",
		y = 115,
		group = "DeckSelection",
		active = true,
		substate = "NewDeck",
	})
	SpadesOnly = TemplateAdminPanel:add("radio", {
		x = 10,
		font = ui.font(18),
		label = "Spades Only",
		y = 145,
		group = "DeckSelection",
		substate = "NewDeck",
	})
	HeartsOnly = TemplateAdminPanel:add("radio", {
		x = 10,
		font = ui.font(18),
		label = "Hearts Only",
		y = 175,
		group = "DeckSelection",
		substate = "NewDeck",
	})
	DiamondsOnly = TemplateAdminPanel:add("radio", {
		x = 10,
		font = ui.font(18),
		label = "Diamonds Only",
		y = 205,
		group = "DeckSelection",
		substate = "NewDeck",
	})
	ClubsOnly = TemplateAdminPanel:add("radio", {
		x = 10,
		font = ui.font(18),
		label = "Clubs Only",
		y = 235,
		group = "DeckSelection",
		substate = "NewDeck",
	})
	CreatePresetButton = TemplateAdminPanel:add("button", {
		align = "center", 
		y = 275, 
		background = hex2rgb("#2196F3"),
		h = 50,
		w = TemplateAdminPanel.w*.75,
		text = "Custom Presets",
		substate="NewDeck",
	})
	TemplateAdminPanel:add("text", {
		font = ui.font( 22, "Roboto-LightItalic" ),
		text = "DECK SETTINGS", 
		align = "center",
		y = 350,
		substate = "NewDeck",
	})
	ShuffleDeck = TemplateAdminPanel:add("radio", {
		x = 10,
		y = 390,
		font = ui.font(18),
		label = "Shuffle Cards",
		active = true,
		substate = "NewDeck",
	})
	FlipDeck = TemplateAdminPanel:add("radio", {
		x = 10,
		y = 430,
		font = ui.font(18),
		label = "Flip Cards",
		active = true,
		substate = "NewDeck",
	})
	CreateDeckButton = TemplateAdminPanel:add("button", {
		y = TemplateAdminPanel.h-100,
		h = 100,
		background = hex2rgb("#43A047"),
		font = ui.font(20, "Roboto-Bold"),
		w = TemplateAdminPanel.w,
		substate="NewDeck",
		text = "Create Deck!",
		sound = Game.Sounds.ButtonNew,
	})
	CreateDeckButton.onclick = function()
		local selection = ui.getRadioGroup("DeckSelection")
		local c = {}
		local deckgroup = os.time()
		if selection == Standard52Deck then
			for i = 1, 52 do
				table.insert( c, {
					value = "any",
					suit = "any", 
					flipped = FlipDeck.active,
					deckgroup = deckgroup
				})
			end
		elseif selection == ClubsOnly then
			for i = 1, 13 do
				table.insert(c, {
					value = "any",
					suit = "clubs",
					flipped = FlipDeck.active,
					deckgroup = deckgroup
				})
			end
		end

		deckTemplate:new({cards=c,shuffled = ShuffleDeck.active, deckgroup = deckgroup})
		TemplateAdminPanel.substate = "Main"
	end
end


function makeMenus()
	makeMainMenu()
	makeGameTypePanel()
	makeGameAdminPanel()
	makeTemplateBasePanel()
	makeTemplateDeckPanel()
end