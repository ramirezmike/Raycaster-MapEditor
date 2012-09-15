map = { 
 1,1,1,1,    
 1,0,0,1,    
 1,0,0,1,
 1,1,1,1
 }

editorBlockSize = 20
editorBlockSpace = 20
selectedTexture = 1

function saveMapToDisk(map)
    local mapString = "map = {"
    for i = 1, #map - 1 do
        mapString = mapString .. tostring(map[i]) .. ","
    end
    mapString = mapString .. tostring(map[#map]) .. "} \n return map"

    local file = (io.open("map01.lua", "w"))
    file:write(mapString)
    file:close()
end

function love.mousepressed(x, y, button)
    if button == 'r' then
        changeSelectedTexture()
    end
end

function changeSelectedTexture()
    selectedTexture = selectedTexture + 1
    if (selectedTexture == numberOfImages+1) then
        selectedTexture = 0
    end
end

function drawDebug()
    love.graphics.setColor(0,0,0)
    love.graphics.print("Current FPS: "..tostring(love.timer.getFPS()), 10, 10)
    love.graphics.print("Map L/W    : "..tostring(mapSize), 10, 25)
    love.graphics.print("# of Blocks: "..tostring(mapSize*mapSize), 10, 40)
    love.graphics.print("SelTexture : "..tostring(selectedTexture), 10, 55)
--    love.graphics.print("selWallX   : "..tostring(positionXFromArrayIndex(selectedWall)), 10, 70)
 --   love.graphics.print("selWallY   : "..tostring(math.floor(positionYFromArrayIndex(selectedWall) + 0.5)), 10, 85)
end

function love.update(dt)
    if love.mouse.isDown('l') then
        local x, y = love.mouse.getPosition()
        mouseInBox(x,y)
    end
    if love.keyboard.isDown('up') then
        increaseMapSize()
    end
    if love.keyboard.isDown('down') then
        decreaseMapSize()
    end
end

function love.keypressed(key, unicode)
    if key == 's' then
        saveMapToDisk(map)
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
    if (mx > bx and mx < bx + bw) and (my > by and my < by + bh) then
        return true
    else
        return false
    end
end

function mouseInBox(x, y)
    for i=1,#map do
        local bx = positionXFromArrayIndex(i)*editorBlockSpace 
        local by = positionYFromArrayIndex(i)*editorBlockSpace
        if (boxCollision(x,y,bx,by,editorBlockSize,editorBlockSize)) then changeBoxTexture(i) end
    end    
end

function changeBoxTexture(i)
  map[i] = selectedTexture 
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

function setQuads(numberOfImages)
    QUADS[0] = love.graphics.newQuad(0, 0, editorBlockSize, editorBlockSize, tileSize, tileSize)
    print (numberOfImages)
    for i=1,numberOfImages+1 do
        QUADS[i] = love.graphics.newQuad(0,0 + ((i-1)*tileSize),editorBlockSize,editorBlockSize,tileSize,tileSize*numberOfImages)
    end
end

QUADS = {}
tileSize = 64
wallsImgs = love.graphics.newImage("walls.png")
emptyWall = love.graphics.newImage("empty.png")
numberOfImages = (wallsImgs:getHeight()/tileSize)
spriteBatch = love.graphics.newSpriteBatch( wallsImgs, 9000)
emptySpriteBatch = love.graphics.newSpriteBatch( emptyWall, 9000)
setQuads(numberOfImages)


mapSize = 4
windowWidth = love.graphics.getWidth()
windowHeight = love.graphics.getHeight()
screenScale = 0.5
screenWidth = windowWidth / screenScale
screenHeight = windowHeight / screenScale

function love.load()
   love.graphics.setMode(1280,800, true, true)
   love.mouse.setVisible(true)
   love.graphics.setColorMode("replace")
end

function love.draw()
    for i=0,mapSize-1 do
        for j=0,mapSize-1 do
            local index = indexFromCoordinates(j,i)
            if (map[index] == 0) then
                love.graphics.drawq(emptyWall,QUADS[map[index]],j*editorBlockSpace,i*editorBlockSpace,0,1,1)
            else
                love.graphics.drawq(wallsImgs,QUADS[map[index]],j*editorBlockSpace,i*editorBlockSpace,0,1,1)
            end
        end
    end
    love.graphics.setColorMode("modulate")
    drawDebug()
    love.graphics.setColorMode("replace")
end
