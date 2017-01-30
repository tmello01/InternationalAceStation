local assets = { Main = { } }

local startDir = "assets"

local function getFileContents(dir)
	for i, v in pairs( love.filesystem.getDirectoryItems( dir ) ) do
		assets.Main[dir] = {}
		if love.filesystem.isFile( dir.."/"..v ) then
			local ext = v:sub(-4)
			print( dir, v )
			assets.Main[dir][v] = v
		else
			getFileContents(dir.."/"..v)
		end
	end
end
getFileContents(startDir)
print( table.serialize( assets ) )

return assets