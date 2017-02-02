--Touch manager!--

local tm = {}
local managers = {}

function tm.start( obj, id )
	for i, v in pairs( managers ) do
		print( '[tm]', id, obj, v.object )
		if v.object == obj then
			local time = v.time.timer
			print( time )
			if time > 0 and time < 0.3 then
				print("[tm] OnDoubleTap")
				v.object:onDoubleTap()
				managers[v.id] = nil
				print( managers[v.id])
				return
			end
		end
	end
	print("[tm] making new manager")
	local id = #managers+1
	managers[id] = {
		object = obj,
		id = id,
		time = timer:new( 0.7 ),
		touchid = id,
	}
end

function tm.update( dt )
	for i, v in pairs( managers ) do
		if v.time:update(dt) then
			if touch.hasTouch( v.id ) then
				v.object:onHold()
			end
			managers[v.id] = nil
		end
	end
end

function tm.remove( id )
	for i, v in pairs( managers ) do
		if v.touchid == id then
			v = nil
			managers[i] = nil
			return
		end
	end
end

function tm.hasId( id )
	for i, v in pairs( managers ) do
		if v.id == id then
			return true
		end
	end
	return false
end

function tm.drag( id )
	for i, v in pairs( managers ) do
		if v.id == id then
			print("[tm] Drag")
			v.obj:onDrag()
			tm.remove( id )
			return
		end
	end
end

return tm