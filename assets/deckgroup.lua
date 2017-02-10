local deckgroup = {
	id = 0,
	preset = DeckPresets.Standard52Deck,
	type = "deckgroup",
	cards = 52,
	allowrepeats = false,
	shuffled = true,
}
deckgroup.__index = deckgroup

function deckgroup:new( data )
	local data = data or {}
	local self = setmetatable( data, deckgroup )
	table.insert( Game.Objects, self )
	return self
end

return deckgroup