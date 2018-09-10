-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------

-- Your code here


local composer = require( "composer" )

local scene = composer.newScene()

function scene:create( event )

	--requires

	local physics = require "physics"
	physics.start( )

	physics.setGravity( 0, 0 )

	display.setStatusBar( display.HiddenStatusBar )



	--background

	local monstersTable = {}
	local gameLoopTimer

	local function updateText()
    	scoreText.text = "Score: " .. score
	end

	local city1 = display.newImage("city1.png")
		city1.x = 525
		city1.y = display.contentCenterY
		city1.width = 1390
		city1.height = 770


	local city2 = display.newImage("city2.png")
		city2.x = 1915
		city2.y = display.contentCenterY
		city2.width = 1394
		city2.height = 770


	local function scrollCity( self, event )
		if  self.x < -860 then
			self.x = 1905
		else 
			self.x = self.x - 3
		end
	end

	city1.enterFrame = scrollCity
	Runtime:addEventListener("enterFrame",city1)

	city2.enterFrame = scrollCity
	Runtime:addEventListener("enterFrame",city2)


	--ship

	local ship = display.newImage("ship.png", 200, 200)
	ship.x = -70
	ship.y = display.contentCenterY
	physics.addBody( ship, "dinamic", {density=.1, bounce=0.1, friction=.2, radius=12} )

	--local buttonUp = display.newImage( "control/butup.png")
	--buttonUp.width = 140
	--buttonUp.height = 80
	--buttonUp.x = 100
--	buttonUp.y = display.contentCenterY + 180
	--buttonUp.alpha = .6

	--local buttonDown = display.newImage( "control/butdown.png")
	--buttonDown.width = 140
--	buttonDown.height = 80
--	buttonDown.x = 120
--	buttonDown.y = display.contentCenterY + 300
--	buttonDown.alpha = .6



	--movement ship
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
	ship:addEventListener( "touch", dragShip )




	--laser
	local function Laser()
 
    local newLaser = display.newImageRect( "laser.png", 30, 20 )
    physics.addBody( newLaser, "dynamic", { isSensor=true } )
    newLaser.isBullet = true
    newLaser.myName = "laser"

    newLaser.x = ship.x + 21
    newLaser.y = ship.y
	
	transition.to( newLaser, { x = 1240, time=500,
        onComplete = function() display.remove( newLaser ) end
    } )

	end
	ship:addEventListener( "tap", Laser )


	--creating monsters
	local function createMonsters()

		local newMonster = display.newImageRect("veni.png", 150, 150)
	   	table.insert( monstersTable, newMonster)
	   	physics.addBody( newMonster, "dynamic", { radius=70, bounce=0.8 } )
	   	newMonster.myName = "monster"

	   	local whereFrom = math.random(1)

		    if ( whereFrom == 51 ) then
		        	newMonster.x = 400
	       			newMonster.y = math.random( 500 )
	                newMonster:setLinearVelocity( math.random( 40,120 ), math.random( -20,60 ) )
			elseif ( whereFrom == 2 ) then
			        newMonster.x = math.random( display.contentWidth )
			        newMonster.y = -60
			        newMonster:setLinearVelocity( math.random( -40,40 ), math.random( 40,120 ) )
			elseif ( whereFrom == 1 ) then
			        newMonster.x = display.contentWidth + 300
			        newMonster.y = math.random(40,740)
			        newMonster:setLinearVelocity(-200, 0)
			end
	newMonster:applyTorque( math.random( -6,6 ) )
	end

	local function gameLoop()

		createMonsters()
	
	end
	gameLoopTimer = timer.performWithDelay( 500, gameLoop, 0 )


	--colision
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

	        end
	    end
	end
	Runtime:addEventListener( "collision", onCollision )

end
scene:addEventListener( "create", scene )
return scene













