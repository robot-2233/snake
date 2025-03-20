local snake = {}
local food = {}
local currentDirection = "right" -- 当前方向
local nextDirection = "right"    -- 下一个方向（用于缓冲输入）
local timer = 0
local speed = 0.1                -- 控制蛇的移动速度
local gridSize = 20              -- 网格大小
local gameOver = false

function love.load()
    love.window.setTitle("贪吃蛇")
    love.window.setMode(800, 600)

    -- 初始化蛇的位置（从屏幕中央开始）
    table.insert(snake, { x = 15, y = 15 })
    table.insert(snake, { x = 14, y = 15 })
    table.insert(snake, { x = 13, y = 15 })

    -- 初始化食物
    spawnFood()
end

-- 生成食物的随机位置
function spawnFood()
    food.x = math.random(0, love.graphics.getWidth() / gridSize - 1)
    food.y = math.random(0, love.graphics.getHeight() / gridSize - 1)
end

-- 检查方向是否合法（防止反向移动）
function isValidDirection(newDir, currentDir)
    if newDir == "right" and currentDir == "left" then return false end
    if newDir == "left" and currentDir == "right" then return false end
    if newDir == "up" and currentDir == "down" then return false end
    if newDir == "down" and currentDir == "up" then return false end
    return true
end

-- 更新游戏状态
function love.update(dt)
    if gameOver then
        return
    end

    timer = timer + dt

    -- 控制蛇的移动速度
    if timer >= speed then
        timer = 0

        -- 在移动之前，将 nextDirection 应用到 currentDirection
        if isValidDirection(nextDirection, currentDirection) then
            currentDirection = nextDirection
        end

        -- 保存蛇头的位置
        local head = { x = snake[1].x, y = snake[1].y }

        -- 根据当前方向更新蛇头位置
        if currentDirection == "right" then
            head.x = head.x + 1
        elseif currentDirection == "left" then
            head.x = head.x - 1
        elseif currentDirection == "up" then
            head.y = head.y - 1
        elseif currentDirection == "down" then
            head.y = head.y + 1
        end

        -- 检测是否撞墙
        if head.x < 0 or head.x >= love.graphics.getWidth() / gridSize or
            head.y < 0 or head.y >= love.graphics.getHeight() / gridSize then
            gameOver = true
            return
        end

        -- 检测是否撞到自己
        for i = 1, #snake do
            if head.x == snake[i].x and head.y == snake[i].y then
                gameOver = true
                return
            end
        end

        -- 将新蛇头插入到蛇的开头
        table.insert(snake, 1, head)

        -- 检查是否吃到食物
        if head.x == food.x and head.y == food.y then
            spawnFood()         -- 重新生成食物
        else
            table.remove(snake) -- 如果没吃到食物，移除尾部
        end
    end
end

-- 绘制游戏画面
function love.draw()
    -- 绘制背景
    love.graphics.setBackgroundColor(0.1, 0.1, 0.1)

    -- 绘制蛇
    love.graphics.setColor(0, 1, 0) -- 绿色
    for i = 1, #snake do
        love.graphics.rectangle("fill",
            snake[i].x * gridSize,
            snake[i].y * gridSize,
            gridSize - 2,
            gridSize - 2)
    end

    -- 绘制食物
    love.graphics.setColor(1, 0, 0) -- 红色
    love.graphics.rectangle("fill",
        food.x * gridSize,
        food.y * gridSize,
        gridSize - 2,
        gridSize - 2)

    -- 游戏结束提示
    if gameOver then
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf("游戏结束！按R重新开始", 0,
            love.graphics.getHeight() / 2,
            love.graphics.getWidth(), "center")
    end
end

-- 处理键盘输入
function love.keypressed(key)
    -- 控制蛇的移动方向（使用 nextDirection 缓冲输入）
    if key == "right" then
        nextDirection = "right"
    elseif key == "left" then
        nextDirection = "left"
    elseif key == "up" then
        nextDirection = "up"
    elseif key == "down" then
        nextDirection = "down"
    end

    -- 游戏结束后按R重新开始
    if gameOver and key == "r" then
        -- 重置游戏状态
        snake = {}
        table.insert(snake, { x = 15, y = 15 })
        table.insert(snake, { x = 14, y = 15 })
        table.insert(snake, { x = 13, y = 15 })
        currentDirection = "right"
        nextDirection = "right"
        timer = 0
        gameOver = false
        spawnFood()
    end
end
