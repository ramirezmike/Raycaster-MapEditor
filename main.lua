map = { 

 2,2,3,3,    
 2,2,3,3,    
 2,0,4,4,
 2,2,2,2
 }

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
    if button == "l" then
       print ("MOUSE") 
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
    for i=1,mapSize*mapSize do
        map[i] = 0
    end
end

function decreaseMapSize()
    map = {}
    mapSize = mapSize - 1
    if (mapSize < 3) then mapSize = 3 end
    for i=1,mapSize*mapSize do
        map[i] = 0
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
        local bx = positionXFromArrayIndex(i)*40 
        local by = positionYFromArrayIndex(i)*40
--        print ("THIS IS BX: ".. bx)
 --       print ("THIS IS X: ".. x)
  --      print ("THIS IS BY: ".. by)
   --     print ("THIS IS Y: ".. y)
        if (boxCollision(x,y,bx,by,25,25)) then changeTexture(i) end
    end    
end

function changeTexture(i)
  map[i] = map[i] + 1 
  if (map[i] > numberOfImages-1) then map[i] = 0 end
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
    QUADS[0] = love.graphics.newQuad(0, 0, 25, 25, tileSize, tileSize)
    for i=1,numberOfImages do
        QUADS[i] = love.graphics.newQuad(0,0 + ((i)*tileSize),25,25,tileSize,tileSize*numberOfImages)
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
   love.graphics.setMode(640,480, false, true)
   love.mouse.setVisible(true)
end

function love.draw()
    for i=0,mapSize-1 do
        for j=0,mapSize-1 do
            local index = indexFromCoordinates(j,i)
            if (map[index] == 0) then
                love.graphics.drawq(emptyWall,QUADS[map[index]],j*40,i*40,0,1,1)
            else
                love.graphics.drawq(wallsImgs,QUADS[map[index]],j*40,i*40,0,1,1)
            end
            print (map[index])
        end
    end
end
