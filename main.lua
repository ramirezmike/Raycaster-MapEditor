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

    local file = (io.open("map02.lua", "w"))
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
    if (selectedTexture == numberOfImages) then
        selectedTexture = 0
    end
end


function love.update(dt)
    if love.mouse.isDown('l') then
        local x, y = love.mouse.getPosition()
        mouseInBox(x,y)
    end
end

function love.keypressed(key, unicode)
    if key == '+' or key == 'up' then
       increaseMapSize() 
    end

    if key == '-' or key == 'down' then
       decreaseMapSize()
    end

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
--        print ("THIS IS BX: ".. bx)
 --       print ("THIS IS X: ".. x)
  --      print ("THIS IS BY: ".. by)
   --     print ("THIS IS Y: ".. y)
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
    for i=1,numberOfImages do
        QUADS[i] = love.graphics.newQuad(0,0 + ((i)*tileSize),editorBlockSize,editorBlockSize,tileSize,tileSize*numberOfImages)
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
end
