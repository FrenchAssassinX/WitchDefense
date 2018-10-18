-- Cette ligne permet d'afficher des traces dans la console pendant l'éxécution
io.stdout:setvbuf('no')

-- Empèche Love de filtrer les contours des images quand elles sont redimentionnées
-- Indispensable pour du pixel art
love.graphics.setDefaultFilter("nearest")

-- Cette ligne permet de déboguer pas à pas dans ZeroBraneStudio
if arg[#arg] == "-debug" then require("mobdebug").start() end

--Permet d'empêcher la fonction math.random de ne pas avoir le même résultat trop de fois
math.randomseed(love.timer.getTime())

-- Permet de calculer l'angle de tir des ennemis
function math.angle(x1,y1, x2,y2) return math.atan2(y2-y1, x2-x1) end

function collide(a1, a2)
  if (a1==a2) then return false end
  local dx = a1.x - a2.x
  local dy = a1.y - a2.y
  if (math.abs(dx) < a1.image:getWidth()+a2.image:getWidth()) then
    if (math.abs(dy) < a1.image:getHeight()+a2.image:getHeight()) then
      return true
    end
  end
  return false
end

function CreateSprite(pImage, pX, pY)
  sprite = {}
  sprite.x = pX
  sprite.y = pY
  sprite.image = love.graphics.newImage("images/"..pImage..".png")
  sprite.delete = false
  sprite.width = sprite.image:getWidth()
  sprite.height = sprite.image:getHeight()
  table.insert(sprites, sprite)
  return sprite
end 

function CreateShoot(pType, pImage, pX, pY, pSpeedX, pSpeedY)
  local shoot = CreateSprite(pImage, pX, pY)
  shoot.type = pType
  shoot.speedX = pSpeedX
  shoot.speedY = pSpeedY
  table.insert(shoots, shoot)
end

function CreateEnemy(pImage, pX, pY, pSpeedX, pSpeedY, pType)
  local enemy = CreateSprite(pImage, pX, pY)
  enemy.speedX = pSpeedX
  enemy.speedY = pSpeedY
  enemy.type = pType
  enemy.bSleep = true
  enemy.chronotir = 0
  table.insert(enemies, enemy)
end

function loadGame()
  hero = {}
  enemies = {}
  shoots = {}
  sprites = {}
  kills = {}

  -- Niveau 25x19
  level = {
    {2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2},
    {2,9,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,3,2},
    {2,8,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,4,2},
    {2,8,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,4,2},
    {2,8,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,4,2},
    {2,8,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,4,2},
    {2,8,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,4,2},
    {2,8,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,4,2},
    {2,8,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,4,2},
    {2,8,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,4,2},
    {2,8,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,4,2},
    {2,8,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,4,2},
    {2,8,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,4,2},
    {2,8,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,4,2},
    {2,8,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,4,2},
    {2,8,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,4,2},
    {2,8,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,4,2},
    {2,7,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,5,2},
    {2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2}
  }
  
  -- Images des tuiles
  local n
  imgTiles = {}
  for n=1, 10 do
    imgTiles[n] = love.graphics.newImage("images/tuile_"..n..".png")
  end
  
  -- Caméra
  camera = {}
  camera.x = 0

  -- Ecran courant
  screen_current = "menu"

  imgMenu = love.graphics.newImage("images/menu.png")
  imgGameOver = love.graphics.newImage("images/gameOver.png")
  imgVictory = love.graphics.newImage("images/victory.png")
  imgHelp = love.graphics.newImage("images/help.png")
  imgCredits = love.graphics.newImage("images/credits.png")

  --Sons
  soundShootHeros = love.audio.newSource("sons/fireball.wav", "static")
  soundShootSkull = love.audio.newSource("sons/skullShoot.wav", "static")
  soundDieSkull = love.audio.newSource("sons/skullDie.wav", "static")
  soundDieHero = love.audio.newSource("sons/heroDie.wav", "static")
  soundDieArcher = love.audio.newSource("sons/archerDie.wav", "static")
  --Musiques
  musicBattle = love.audio.newSource("musiques/musicBattle.wav", "stream")
  musicGameOver = love.audio.newSource("musiques/musicGameOver.wav", "static")
  musicWin = love.audio.newSource("musiques/musicWin.wav", "static")
  musicMenu = love.audio.newSource("musiques/musicMenu.wav", "static")
end

function love.load()
  loadGame()
  
  love.window.setTitle("Witch Defense")
  love.window.setMode(800, 608)
  
  screen_width = love.graphics.getWidth()
  screen_height = love.graphics.getHeight()
  
  hero = CreateSprite("hero", screen_width, screen_height)
  
  heroShoot = false
  chronoShootHero = 0
  
  -- Création des ennemis
  local n
  local nbEnemies
  local posYEnemy
  local widthEnemy = screen_width + screen_width
  local posWidthEnnemi
  nbEnemies = math.random(5, 10)
    
  for n=1, nbEnemies do
    local touchingEnemy = false
    posWidthEnnemi = math.random(screen_width, widthEnemy)
    posYEnemy = math.random(1, screen_height) 
    posWidthEnnemi2 = math.random(screen_width, widthEnemy)
    posYEnemy2 = math.random(1, screen_height) 
    if collide(enemy, enemy) then
      touchingEnemy = true
    end
    if touchingEnemy == false then
      enemy = CreateEnemy("archer", posWidthEnnemi, posYEnemy, 1, 1, 1)
      --enemy = CreateEnemy("chevalier", posWidthEnnemi2, posHeightEnnemi2, 1, 1, 2)
    end
  end
  
  StartGame()
end

function UpdateGame()
  musicBattle:play()
  
  --camera.x = camera.x + 1
  difficulty = 0
  nbEnemies = 0
  if difficulty == 0 then
    nbEnemies = math.random(5, 10)
  elseif difficulty == 1 then
    nbEnemies = math.random(15, 20)
  elseif difficulty == 2 then
    nbEnemies = math.random(20, 25)
  elseif difficulty == 3 then
    nbEnemies = math.random(35, 40)
  end
  
  nbCol = #level[1]
  map_width = nbCol * 32
  if camera.x < map_width * -1 then
    camera.x = 0
  end
  
  -- Déplacement héros
  if hero.y >= 0 then
    if love.keyboard.isDown("z") then
      hero.y = hero.y - 3
    end
  end
  if hero.x >= 0 then
    if love.keyboard.isDown("q") then
      hero.x = hero.x - 3
    end
  end
  if hero.y <= screen_height then
    if love.keyboard.isDown("s") then
      hero.y = hero.y + 3
    end
  end
  if hero.x <= screen_width then
    if love.keyboard.isDown("d") then
      hero.x = hero.x + 3
    end
  end
  
  if heroShoot == true then
    chronoShootHero = chronoShootHero - 1
    if chronoShootHero <= 0 then 
      CreateShoot("hero", "yellowShoot", hero.x, hero.y, 10, 0, false)
      soundShootHeros:play()
      heroShoot = false
      print("Chronotir : "..chronoShootHero)
      chronoShootHero = 12
    end
  end
  
  if #enemies <= 0 then 
    local n
    local posYEnemy
    local widthEnemy = screen_width + screen_width
    local posWidthEnnemi
      
    for n=1, nbEnemies do
      local touchingEnemy = false
      posWidthEnnemi = math.random(screen_width, widthEnemy)
      posYEnemy = math.random(1, screen_height) 
      if collide(enemy, enemy) then
        touchingEnemy = true
      end
      if touchingEnemy == false then
        enemy = CreateEnemy("archer", posWidthEnnemi, posYEnemy, 1, 1, 1)
        --enemy = CreateEnemy("chevalier", posWidthEnnemi, posHeightEnnemi, 1, 1, 2)
      end
    end
  end
  
  local n  
  --Traitement tir
  for n=#shoots, 1, -1 do
    
    --Déplacement
    local myShoot = shoots[n]
    myShoot.x = myShoot.x + myShoot.speedX
    myShoot.y = myShoot.y + myShoot.speedY
    
    -- Collision
    if myShoot.x > screen_width or myShoot.x < 0 or myShoot.y > screen_height or myShoot.y < 0 then
      myShoot.delete = true
      table.remove(shoots, n)
    end
    
    if myShoot.type == "enemy" then
      if collide(hero, myShoot) then
        myShoot.delete = true
        hero.delete = true
        soundDieHero:play()
        musicGameOver:play()
        screen_current = "gameOver"
      end
    end
    
    if myShoot.type == "hero" then
      local myEnemy
      for myEnemy=#enemies, 1, -1 do
        local enemy = enemies[myEnemy]
        if collide(enemy, myShoot) then
          myShoot.delete = true
          table.remove(shoots, n)
          enemy.delete = true
          table.remove(enemies, myEnemy)
          soundDieArcher:play()
          table.insert(kills, myEnemy)
        end
      end
    end
  end
  
  --Suppression tir
  for n=#sprites, 1, -1 do
    if sprites[n].delete == true then 
      table.remove(sprites, n)
    end
  end
  
  --Déplacement des ennemis
  for n=#enemies, 1, -1 do
    local enemy = enemies[n]
    if enemy.type == 1 then
      enemy.x = enemy.x - enemy.speedX
    end
      
    -- Réveil des ennemis lors de leur apparition à l'écran
    if enemy.x < screen_width then
      enemy.bSleep = false
    end
    
    if enemy.bSleep == false then
      enemy.chronotir = enemy.chronotir - 1
      if enemy.type == 1 then
        if enemy.chronotir <= 0 then 
          enemy.chronotir = math.random(50, 100)
          local speedX, speedY, angle
          angle = math.angle(enemy.x, enemy.y, hero.x, hero.y)
          speedX = 10 * math.cos(angle)
          speedY = 10 * math.sin(angle)
          CreateShoot("enemy","redShoot", enemy.x, enemy.y, speedX, speedY, true)
          soundShootSkull:play()
        end
      end
    end
    
    -- Collision ennemi
    if enemy.x < 0 then 
      enemy.delete = true
      table.remove(enemies, n)
    elseif collide (hero, enemy) then
      hero.delete = true
      enemy.delete = true
      table.remove(enemies, n)
      soundDieArcher:play()
      soundDieHero:play()
      musicGameOver:play()
      screen_current = "gameOver"
    end
  end
  
  -- Gestion de la difficulté et de la victoire
  if #kills > 20 and #kills < 39 then
    difficulty = 1
  elseif #kills > 40 and #kills < 59 then
    difficulty = 2
  elseif #kills > 60 and #kills < 99 then
    difficulty = 3
  elseif #kills >= 100 then
    musicWin:play()
    screen_current = "victory"
  end

end

function love.update(dt)
  if screen_current == "game" then 
    UpdateGame()
  end
end

function StartGame()
  hero.x = 20
  hero.y = screen_height/2
  
  camera.x = 0
end

function DrawGame()
  musicMenu:stop()
  
  -- Dessin niveau
  nbLines = #level
  local line,col
  local x,y
  
  -- x et y indique la position à partir de laquelle on affiche le niveau, ici tout en haut à gauche
  x = 0
  y = 0
  for line=1, nbLines do
    for col=1, 25 do
      -- Dessin tuile en avançant de 32 pixels
      local myTile = level[line][col]
      if myTile > 0 then
        love.graphics.draw(imgTiles[myTile], x, y, 0, 1, 1)
      end
      x = x + 32
    end
    --Changement de ligne à la fin du parcours des colonnes
    x = 0
    y = y + 32
  end
  
  -- Parcours du tableau sprites et affichage des éléments 
  local n 
  for n=1, #sprites do 
    local mySprite = sprites[n]
    love.graphics.draw(mySprite.image, mySprite.x, mySprite.y, 0, 2, 2, mySprite.width/2, mySprite.height/2)
  end
    
  -- Compte nb sprite
  --love.graphics.print("Nb sprites : "..#sprites.." Nb tirs : "..#shoots.." Nb ennemis : "..#ennemys.." Nb ennemis tués : "..#kills)
  love.graphics.print("SCORE : "..#kills)
end

function DrawMenu()
  love.graphics.draw(imgMenu, 0, 0)
  musicMenu:play()
end

function DrawGameOver()
  musicBattle:stop()
  love.graphics.draw(imgGameOver, 0, 0)
end

function DrawVictory()
  musicBattle:stop()
  love.graphics.draw(imgVictory, 0, 0)
end

function DrawCredits()
  love.graphics.draw(imgCredits, 0, 0)
end

function DrawHelp()
  love.graphics.draw(imgHelp, 0, 0)
end

function love.draw()
  if screen_current == "menu" then 
    DrawMenu()
  elseif screen_current == "game" then 
    DrawGame()
  elseif screen_current == "gameOver" then 
    DrawGameOver()
  elseif screen_current == "victory" then
    DrawVictory()
  elseif screen_current == "credits" then
    DrawCredits()
  elseif screen_current == "help" then
    DrawHelp()
  end
end

function love.keypressed(key)
  --print(key)
  if screen_current == "menu" then
    if key == "space" then 
      screen_current = "game"
    elseif key == "h" then
      screen_current = "help"
    elseif key == "c" then
      screen_current = "credits"
    end
  elseif screen_current == "game" then
    if key == "space" then
      heroShoot = true
    end
  elseif screen_current == "gameOver" or screen_current == "victory" then
    if key == "r" then
      love.load()
      screen_current = "game"
    elseif key == "m" then
      love.load()
    end
  elseif screen_current == "credits" or screen_current == "help" then
    if key == "escape" then
      screen_current = "menu"
    end
  end
end
  