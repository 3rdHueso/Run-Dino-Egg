
-- Module/class for platfomer animal/blob
-- Use this as a template to build an in-game animal/blob

-- Define module
local M = {}

local composer = require( "composer" )

function M.new( instance )
	if not instance then error( "ERROR: Expected display object" ) end

	local color = composer.getVariable( "settedColor" )

	-- do this every frame
	local function enterFrame(event)
		
		if instance then
			-- eliminate the objects off out the left side of screen
			local x, y = instance:localToContent( 0, 0 )
			if x < -80 then	
				instance:translate( 12*135, 0 )
			end
		end
	end

	-- stop the sprite animation and enterframe listener
	function instance:stopTranslation()
		Runtime:removeEventListener( "enterFrame", enterFrame )
	end

	-- listeners for instance
	Runtime:addEventListener( "enterFrame", enterFrame )

	-- Return instance
	instance.name = "block"
	instance.type = "block"
	return instance
end

return M
