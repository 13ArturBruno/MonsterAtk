
local composer = require( "composer" )

local scene = composer.newScene()

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------

local physics = require( "physics" )
physics.start()
physics.setGravity( 0, 0 )


-- Initialize variables
local score = 0
local lives = 1
local died = false
local monstersTable = {}
local gameLoopTimer
local scoreText
local livesText

local backGroup
local mainGroup
local uiGroup


local function updateText()
	livesText.text = "Lives: " .. lives
	scoreText.text = "Score: " .. score
end


local function createMonsters()

		local newMonster = display.newImageRect(mainGroup, "_img/veni.png", 150, 150)
	   	table.insert( monstersTable, newMonster)
	   	physics.addBody( newMonster, "dynamic", { radius=50, bounce=0.8 } )
	   	newMonster.myName = "monster"

	   	local whereFrom = math.random(1)

		    if ( whereFrom == 1 ) then
			        newMonster.x = display.contentWidth + 300
			        newMonster.y = math.random(60,740)
			        newMonster:setLinearVelocity(-200, 0)
			end
end


local function Laser()
 
	    local newLaser = display.newImageRect(mainGroup, "_img/laser.png", 30, 20 )
	    physics.addBody( newLaser, "dynamic", { isSensor=true } )
	    newLaser.isBullet = true
	    newLaser.myName = "laser"
	    newLaser.x = ship.x
		newLaser.y = ship.y
		newLaser:toBack()
		
		transition.to( newLaser, { x = 1240, time=500,
	        onComplete = function() display.remove( newLaser ) end
	    } )
end


local function dragShip( event )
 	
	 	local ship = event.target
		local phase = event.phase

		if ( "began" == phase ) then
	        display.currentStage:setFocus( ship )
	        ship.touchOffsetY = event.y - ship.y

	    elseif ( "moved" == phase ) then
	        ship.y = event.y - ship.touchOffsetY
	    
	    elseif ( "ended" == phase or "cancelled" == phase ) then
	        display.currentStage:setFocus( nil )
	    
	    end
	    return true  -- Prevents touch propagation to underlying objects
end


local function gameLoop()

	createMonsters()

	for i = #monstersTable, 1, -1 do
        local thisMonster = monstersTable[i]
 
        if ( 
             thisMonster.y < -100 or
             thisMonster.y > display.contentHeight + 100 )
        then
            display.remove( thisMonster )
            table.remove( monstersTable, i )
        end
    end

end


local function restoreShip()

	ship.isBodyActive = false
	ship.x = -70
	ship.y = display.contentCenterY

	-- Fade in the ship
	transition.to( ship, { alpha=1, time=800,
		onComplete = function()
			ship.isBodyActive = true
			died = false
		end
	} )
end


local function endGame()
	composer.setVariable( "finalScore", score )
	composer.gotoScene( "highscores", { time=800, effect="crossFade" } )
end


local function onCollision( event )

	if ( event.phase == "began" ) then

		local obj1 = event.object1
		local obj2 = event.object2

		if ( ( obj1.myName == "laser" and obj2.myName == "monster" ) or
			 ( obj1.myName == "monster" and obj2.myName == "laser" ) )
		then
			-- Remove both the laser and monster
			display.remove( obj1 )
			display.remove( obj2 )

			for i = #monstersTable, 1, -1 do
				if ( monstersTable[i] == obj1 or monstersTable[i] == obj2 ) then
					table.remove( monstersTable, i )
					break
				end
			end

			-- Increase score
			score = score + 100
			scoreText.text = "Score: " .. score

		elseif ( ( obj1.myName == "ship" and obj2.myName == "monster" ) or
				 ( obj1.myName == "monster" and obj2.myName == "ship" ) )
		then
			if ( died == false ) then
				died = true

				-- Update lives
				lives = lives - 1
				livesText.text = "Lives: " .. lives

				if ( lives == 0 ) then
					display.remove( ship )
					timer.performWithDelay( 1000, endGame )

				else
					ship.alpha = 0
					timer.performWithDelay( 1000, restoreShip )
				end
			end
		end
	end
end


-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create( event )

	local sceneGroup = self.view
	-- Code here runs when the scene is first created but has not yet appeared on screen

	physics.pause()  -- Temporarily pause the physics engine

	-- Set up display groups
	backGroup = display.newGroup()  -- Display group for the background image
	sceneGroup:insert( backGroup )  -- Insert into the scene's view group

	mainGroup = display.newGroup()  -- Display group for the ship, monsters, lasers, etc.
	sceneGroup:insert( mainGroup )  -- Insert into the scene's view group

	uiGroup = display.newGroup()    -- Display group for UI objects like the score
	sceneGroup:insert( uiGroup )    -- Insert into the scene's view group
	
	-- Load the background
	local city1 = display.newImage(backGroup, "_img/city1.png")
		city1.x = 525
		city1.y = display.contentCenterY
		city1.width = 1390
		city1.height = 770


	local city2 = display.newImage(backGroup, "_img/city2.png")
		city2.x = 1915
		city2.y = display.contentCenterY
		city2.width = 1394
		city2.height = 770
	

	    ship = display.newImageRect(mainGroup, "_img/ship.png", 100, 150)
		ship.x = -30
		ship.y = display.contentCenterY
		physics.addBody( ship, { radius=30, isSensor=true } )
		ship.myName = "ship"


		city1.enterFrame = scrollCity
		Runtime:addEventListener("enterFrame",city1)

		city2.enterFrame = scrollCity
		Runtime:addEventListener("enterFrame",city2)

		-- Display lives and score
		livesText = display.newText( uiGroup, "Lives: " .. lives, 200, 80, native.systemFont, 36 )
		scoreText = display.newText( uiGroup, "Score: " .. score, 400, 80, native.systemFont, 36 )

		ship:addEventListener( "tap", Laser )
		ship:addEventListener( "touch", dragShip )
end


-- show()
function scene:show( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is still off screen (but is about to come on screen)

	elseif ( phase == "did" ) then
		-- Code here runs when the scene is entirely on screen
		physics.start()
		Runtime:addEventListener( "collision", onCollision )
		gameLoopTimer = timer.performWithDelay( 400, gameLoop, 0 )
	end
end


-- hide()
function scene:hide( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is on screen (but is about to go off screen)
		timer.cancel( gameLoopTimer )
	elseif ( phase == "did" ) then
		-- Code here runs immediately after the scene goes entirely off screen
		Runtime:removeEventListener( "collision", onCollision )
		physics.pause()
		composer.removeScene( "game" )
	end
end


-- destroy()
function scene:destroy( event )

	local sceneGroup = self.view
	-- Code here runs prior to the removal of scene's view

end


-- -----------------------------------------------------------------------------------
-- Scene event function listeners
-- -----------------------------------------------------------------------------------
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )
-- -----------------------------------------------------------------------------------

return scene
