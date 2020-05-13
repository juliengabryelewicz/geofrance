
local composer = require( "composer" )
local json = require( "json" )

local scene = composer.newScene()

-- Initialize variables

local city = ""
local score = 0
local limitTime = 60
local index = 1

local cityText
local scoreText
local timeText

local background

local dataCity = system.pathForFile( "data/cities.json", system.ResourceDirectory)

local jsonContent
local posError
local msgError

local chooseLocation


local function updateText()
	cityText.text = "Ville: " .. city
	scoreText.text = "Score: " .. score
end

local function getLocation()
    city = jsonContent.cities[index].city
    updateText()
end

local function addScore(coordx, coordy)
	local absx = math.abs(coordx - jsonContent.cities[index].x)
	local absy = math.abs(coordy - jsonContent.cities[index].y)
	print( "absx " .. tostring(absx))
  	print( "absy: " .. tostring(absy) )
  	if (absx + absy < 200) then
		score = score + math.abs(300 - math.round((absx+absy)/2))
	end 
end

local function endGame()
	composer.setVariable( "finalScore", score )
	composer.gotoScene( "highscores", { time=800, effect="crossFade" } )
end

local function disableLocation()
	background:removeEventListener( "tap", chooseLocation )
end

function chooseLocation(event)
	local coordx = event.x - background.x + background.width*.5
	local coordy = event.y - background.y + background.height*.5
	print( "X coordinate: " .. tostring(coordx))
	print( "Y coordinate: " .. tostring(coordy) )
	addScore(coordx, coordy)
	if not jsonContent.cities[index+1] then
		updateText()
		disableLocation()
		timer.performWithDelay( 2000, endGame )
	else
		index = index + 1
		getLocation()
	end
end


local function updateTime(event)
 
    limitTime = limitTime - 1
    local minutes = math.floor( limitTime / 60 )
    local seconds = limitTime % 60
    local timeDisplay = string.format( "%02d:%02d", minutes, seconds )
    if timeText then
    	timeText.text = timeDisplay
	end
	if limitTime == 0 then
		disableLocation()
		timer.performWithDelay( 2000, endGame )
	end
end

local countDownTimer = timer.performWithDelay( 1000, updateTime, limitTime )

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------




-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create( event )

	local sceneGroup = self.view
	-- Code here runs when the scene is first created but has not yet appeared on screen


	-- Set up display groups
	backGroup = display.newGroup()  -- Display group for the france map picture
	sceneGroup:insert( backGroup )  -- Insert into the scene's view group

	uiGroup = display.newGroup()    -- Display group for UI objects like the score
	sceneGroup:insert( uiGroup )    -- Insert into the scene's view group

	-- Display cities and score
	timeText = display.newText( uiGroup, "01:00", 200, 80, native.systemFont, 36 )
	scoreText = display.newText( uiGroup, "Score: " .. score, 400, 80, native.systemFont, 36 )
	cityText = display.newText( uiGroup, "Ville: " .. city, display.contentCenterX, 160, native.systemFont, 36 )

	background = display.newImageRect( backGroup, "assets/image_france.png", 500, 500 )
	background.x = display.contentCenterX
	background.y = display.contentCenterY

	background:addEventListener( "tap", chooseLocation )

	jsonContent, posError, msgError = json.decodeFile( dataCity )
	if not jsonContent then
	    print( "Failed at "..tostring(posError)..": "..tostring(msgError) )
	else
	    print( "Success" )
	end

	getLocation()
end


-- show()
function scene:show( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is still off screen (but is about to come on screen)

	elseif ( phase == "did" ) then
		-- Code here runs when the scene is entirely on screen

	end
end


-- hide()
function scene:hide( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is on screen (but is about to go off screen)

	elseif ( phase == "did" ) then
		-- Code here runs immediately after the scene goes entirely off screen
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
