-- gamestate.lua
local GameState = {
    currentStage = 1,
    snake = nil,
    food = {},
    activeBugs = {}
}

function GameState:init()
    self.snake = Snake:new()
    self:spawnFood()
end

function GameState:update(dt)
    self.snake:update(dt)
    self:checkCollisions()
    BugManager:applyBugs(self)
end

function GameState:nextStage()
    self.currentStage = self.currentStage + 1
    BugManager:activateRandomBug()
    self:resetLevel()
end