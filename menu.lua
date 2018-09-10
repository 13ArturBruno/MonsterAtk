
local composer = require( "composer" )

local scene = composer.newScene()

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------

-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create( event )


	local background = display.newImageRect("menu/bg.png", 1355, 755)
	background.x = display.contentCenterX
	background.y = display.contentCenterY

	local function gotoGame()
		composer.gotoScene( "game" )
	end

	local playButton = display.newImageRect("menu/start.png", 200, 200 )
	      playButton.x = display.contentCenterX + 200
	      playButton.y = display.contentCenterY + 200

	playButton:addEventListener( "tap", gotoGame )
end


-- -----------------------------------------------------------------------------------
-- Scene event function listeners
-- -----------------------------------------------------------------------------------
scene:addEventListener( "create", scene )
--scene:addEventListener( "show", scene )
--scene:addEventListener( "hide", scene )
--scene:addEventListener( "destroy", scene )
-- -----------------------------------------------------------------------------------

return scene
