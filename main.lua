local red = 85
local blue = 170
local green = 255

spriteMode = false
spawnMode = false
SPRITES = {}
PLAYER = {
    x = 2,
    y = 2
}
spriteCount = 1

map = { 
 1,1,1,1,    
 1,0,0,1,    
 1,0,0,1,
 1,1,1,1
 }

editorBlockSize = 20
editorBlockSpace = 30
selectedTexture = 1
windowWidth = love.graphics.getWidth()
windowHeight = love.graphics.getHeight()
screenScale = 0.5
screenWidth = windowWidth / screenScale
screenHeight = windowHeight / screenScale

mapX = 100 
mapY = 100 

function saveMapToDisk(map)
    local mapString = "map = {"
    for i = 1, #map - 1 do
        mapString = mapString .. tostring(map[i]) .. ","
    end
    mapString = mapString .. tostring(map[#map]) .. "}"

    for i=1,#SPRITES do
        local sprite = SPRITES[i]
        mapString = mapString .. "\n SPRITES[" .. i .. "] = {"
        mapString = mapString .. "x = " .. sprite.x
        mapString = mapString .. ",y = " .. sprite.y
        mapString = mapString .. ",img = " .. sprite.img
        mapString = mapString .. ",visible = " .. tostring(sprite.visible) 
        mapString = mapString .. ",block = " .. tostring(sprite.block)
        mapString = mapString .. ",speed = " .. tostring(sprite.speed) 
        mapString = mapString .. ",dir = " .. tostring(sprite.dir) 
        mapString = mapString .. ",rot = " .. tostring(sprite.rot) 
        mapString = mapString .. ",hit = " .. "false" 
        mapString = mapString .. ",hitPause = " .. "0.1" 
        mapString = mapString .. ",moveSpeed = " .. tostring(sprite.moveSpeed) 
        mapString = mapString .. ",rotSpeed = " .. tostring(sprite.rotSpeed) 
        mapString = mapString .. ",totalStates = " .. tostring(sprite.totalStates) 
        mapString = mapString .. ",state = " .. tostring(sprite.state) 
        mapString = mapString .. ",wallPositionX = " .. "0" 
        mapString = mapString .. ",wallPositionY = " .. "0" 
        mapString = mapString .. ",objType = " .. "sprite" 
        mapString = mapString .. ",frameTimer = " .. tostring(sprite.frameTimer) 
        mapString = mapString .. ",walkAnimationSpeed = " .. tostring(sprite.walkAnimationSpeed) 
        mapString = mapString .. "}"
    end

    mapString = mapString .. "\n SPAWNPOINT = { x = " .. PLAYER.x .. ", y = " .. PLAYER.y .. "}"
    
    mapString = mapString .. "\n return map"

    local file = (io.open("map01.lua", "w"))
    print (mapString)
    file:write(mapString)
    file:close()
end

function loadMapFromDisk(mapName)
    local e = love.filesystem.exists("map01.lua")
    if (e) then 
        chunk = love.filesystem.load(mapName)
        map = chunk()
        mapSize = math.sqrt(#map) 
    end
end

function changeSelectedTexture()
    selectedTexture = selectedTexture + 1
    if (selectedTexture == numberOfImages+1) then
        selectedTexture = 0
    end
end

function drawDebug()
    love.graphics.setColor(0,30,90)
    love.graphics.rectangle("fill",0,0,120,80)
    love.graphics.setColor(255,255,255)
    love.graphics.print("Current FPS: "..tostring(love.timer.getFPS()), 10, 10)
    love.graphics.print("Map L/W    : "..tostring(mapSize), 10, 25)
    love.graphics.print("# of Blocks: "..tostring(mapSize*mapSize), 10, 40)
    love.graphics.print("SelTexture : "..tostring(selectedTexture), 10, 55)
--    love.graphics.print("selWallX   : "..tostring(positionXFromArrayIndex(selectedWall)), 10, 70)
 --   love.graphics.print("selWallY   : "..tostring(math.floor(positionYFromArrayIndex(selectedWall) + 0.5)), 10, 85)
end

function love.update(dt)
    if love.mouse.isDown('l') then
        if (not spriteMode) then
            local x, y = love.mouse.getPosition()
            mouseInBox(x,y)
        end
    end
    if love.keyboard.isDown('up') then
        increaseMapSize()
    end
    if love.keyboard.isDown('down') then
        decreaseMapSize()
    end
    if love.keyboard.isDown('right') then
        editorBlockSpace = editorBlockSpace + 1
        editorBlockSize = editorBlockSize + 1
    end
    if love.keyboard.isDown('left') then
        editorBlockSpace = editorBlockSpace - 1
        editorBlockSize = editorBlockSize - 1
    end
    if love.keyboard.isDown('w') then
        mapY = mapY-10
    end
    if love.keyboard.isDown('s') then
        mapY = mapY+10
    end
    if love.keyboard.isDown('a') then
        mapX = mapX-10
    end
    if love.keyboard.isDown('d') then
        mapX = mapX+10
    end
    red = red + 1
    blue = blue + 1
    green = green + 1
   
    if red > 255 then red = -255 end
    if green > 255  then green = -255 end
    if blue > 255 then blue = -255 end
end

function love.mousepressed(x, y, button)
    if button == 'r' then
        changeSelectedTexture()
    end
    if button == "l" then
        local x, y = love.mouse.getPosition()
        mouseInBox(x,y)
    end
end

function love.keypressed(key, unicode)
    if key == 'o' then
        saveMapToDisk(map)
    end
    if key == 'l' then
        loadMapFromDisk("map01.lua")
    end
    if key == 'v' then
        spriteMode = not(spriteMode) 
    end
    if key == 'm' then
            local x, y = love.mouse.getPosition()
            setSpawnPoint(x, y)
    end
end

function increaseMapSize()
    map = {}
    mapSize = mapSize + 1
    generateMapWithSize(mapSize)
end

function decreaseMapSize()
    map = {}
    mapSize = mapSize - 1
    if (mapSize < 3) then mapSize = 3 end
    generateMapWithSize(mapSize)
end

function generateMapWithSize(size)
    map = {}
    for i=1,size do
        map[i] = 1
    end
    for i=1,mapSize- 1 do
        i = i * mapSize + 1
        map[i] = 1 
        for j = 2,mapSize-1 do
            i = i + 1
            map[i] = 0
        end
        i = i + 1
        map[i] = 1
    end
    for i=(mapSize*mapSize)-mapSize,(mapSize*mapSize) do
        map[i] = 1
    end
end

function boxCollision(mx, my, bx, by, bw, bh)
    if (mx > bx + mapX and mx < mapX + bx + bw) and (my > by + mapY and my < mapY + by + bh) then
        return true
    else
        return false
    end
end

function mouseInBox(x, y)
    for i=1,#map do
        local bx = positionXFromArrayIndex(i)*editorBlockSpace 
        local by = positionYFromArrayIndex(i)*editorBlockSpace
        if (boxCollision(x,y,bx,by,editorBlockSize,editorBlockSize)) then
            if (not spriteMode) then changeBoxTexture(i) end
            if (spriteMode) then addSprite(i) end
        end
    end    
end

function changeBoxTexture(i)
  map[i] = selectedTexture 
end

function addSprite(i)
    SPRITES[spriteCount] = {
        x = positionXFromArrayIndex(i), 
        y = positionYFromArrayIndex(i), 
        img = selectedTexture,
        visible = false,
        block = true,
        speed = 0,
        dir = 0,
        rot = 0,
        moveSpeed = 0.05,
        rotSpeed = 3,
        totalStates = 12,
        frameTimer = 0,
        walkAnimationSpeed = 5,
        state = 0
    }
    spriteCount = spriteCount + 1
end

function indexFromCoordinates(x,y)
    index = 1 + (math.floor(y)*mapSize) + (math.floor(x))
    return index
end

function positionXFromArrayIndex(index)
    local x = (index % mapSize)-1
    if (x==-1) then x = mapSize-1 end
    return x
end

function positionYFromArrayIndex(index)
    local y = ((index-1) / mapSize)
    y = math.floor(y)
    return y
end

function setSpawnPoint(x,y)
    for i=1,#map do
        local bx = positionXFromArrayIndex(i)*editorBlockSpace 
        local by = positionYFromArrayIndex(i)*editorBlockSpace
        if (boxCollision(x,y,bx,by,editorBlockSize,editorBlockSize)) then
            PLAYER.x = bx/editorBlockSpace
            PLAYER.y = by/editorBlockSpace 
        end
    end    
end

function setQuads(numberOfImages)
    SPRITEQUAD[0] = love.graphics.newQuad(0,0,editorBlockSize,editorBlockSize,10,10)
    QUADS[0] = love.graphics.newQuad(0, 0, editorBlockSize, editorBlockSize, tileSize, tileSize)
    for i=1,numberOfImages+1 do
        QUADS[i] = love.graphics.newQuad(0,0 + ((i-1)*tileSize),editorBlockSize,editorBlockSize,tileSize,tileSize*numberOfImages)
    end
end

QUADS = {}
SPRITEQUAD = {}
tileSize = 64
wallsImgs = love.graphics.newImage("walls.png")
emptyWall = love.graphics.newImage("empty.png")
spriteImage = love.graphics.newImage("sprite.png")
numberOfImages = (wallsImgs:getHeight()/tileSize)
spriteBatch = love.graphics.newSpriteBatch( wallsImgs, 9000)
emptySpriteBatch = love.graphics.newSpriteBatch( emptyWall, 9000)
setQuads(numberOfImages)


mapSize = math.sqrt(#map) 

function love.load()
   love.graphics.setMode(1280,800, true, true)
   love.mouse.setVisible(true)
   love.graphics.setColorMode("replace")
   loadMapFromDisk("map01.lua")
end

function love.draw()
    love.graphics.setColor(math.abs(red),math.abs(green),math.abs(blue))
    love.graphics.rectangle( "fill",
     0,0,screenWidth,screenHeight
    )
    for i=0,mapSize-1 do
        for j=0,mapSize-1 do
            local index = indexFromCoordinates(j,i)
            if (map[index] == 0) then
                love.graphics.drawq(emptyWall,QUADS[map[index]],j*editorBlockSpace+mapX,mapY+i*editorBlockSpace,0,1,1)
            else
                love.graphics.drawq(wallsImgs,QUADS[map[index]],mapX+j*editorBlockSpace,mapY+i*editorBlockSpace,0,1,1)
            end
        end
    end
    for i=1,#SPRITES do
        local sprite = SPRITES[i]
        love.graphics.drawq(spriteImage,SPRITEQUAD[0],sprite.x*editorBlockSpace+mapX,mapY+sprite.y*editorBlockSpace,0,1,1)
    end

    love.graphics.setColorMode("modulate")
    drawDebug()
    love.graphics.setColorMode("replace")
end
