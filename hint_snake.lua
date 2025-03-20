-- main.lua
-- 新增配置模块（独立游戏参数）
local GameConfig = {
    cell_size = 20,         -- 格子像素大小
    grid_width = 30,        -- 横向格子数量
    grid_height = 20,       -- 纵向格子数量
    initial_speed = -2,      -- 初始速度（每秒移动次数）
    initial_length = 4,     -- 初始蛇长度
    wall_collision = true,  -- 是否开启墙碰撞
    self_collision = true   -- 是否开启自碰撞
}

local GameState = {
    snake = {
        body = {},
        direction = "right",
        next_direction = "right",
        move_timer = 0
    },
    food = { x = 0, y = 0 },
    score = 0,
    game_over = false,
    current_speed = GameConfig.initial_speed
}

-- LÖVE 回调函数
function love.load()
    math.randomseed(os.time())
    initialize_game()
end

function love.update(dt)
    if GameState.game_over then return end
    -- 使用计时器控制移动速度
    GameState.snake.move_timer = GameState.snake.move_timer + dt
    local move_interval = 1 / GameState.current_speed
    
    if GameState.snake.move_timer >= move_interval then
        GameState.snake.move_timer = 0
        update_snake_position()
        check_collisions()
    end
end

function love.draw()
    draw_grid()
    draw_snake()
    draw_food()
    draw_ui()
end

function love.keypressed(key)
    if key == "escape" then
        love.event.quit()
    elseif GameState.game_over and key == "space" then
        initialize_game()
    else
        handle_input(key)
    end
end

-- 游戏初始化
function initialize_game()
    -- 初始化蛇
    GameState.snake.body = {}
    for i = GameConfig.initial_length, 1, -1 do
        table.insert(GameState.snake.body, { x = i, y = 1 })
    end
    GameState.snake.direction = "right"
    GameState.snake.next_direction = "right"
    GameState.snake.move_timer = 0

    -- 初始化食物
    generate_food()

    -- 重置游戏状态
    GameState.score = 0
    GameState.game_over = false
    GameState.current_speed = GameConfig.initial_speed
end

-- 输入处理（新增方向缓冲机制）
function handle_input(key)
    local direction_map = {
        up = { disallow = "down", axis = "y" },
        down = { disallow = "up", axis = "y" },
        left = { disallow = "right", axis = "x" },
        right = { disallow = "left", axis = "x" }
    }

    if direction_map[key] then
        -- 禁止180度转向
        if GameState.snake.direction ~= direction_map[key].disallow then
            GameState.snake.next_direction = key
        end
    end
end

-- 修复后的碰撞检测
function check_collisions()
    local head = GameState.snake.body[1]

    -- 修复墙碰撞检测（当开启时）
    if GameConfig.wall_collision then
        if head.x < 1 or head.x > GameConfig.grid_width or
           head.y < 1 or head.y > GameConfig.grid_height then
            GameState.game_over = true
            return
        end
    else
        -- 处理穿墙逻辑
        head.x = (head.x - 1) % GameConfig.grid_width + 1
        head.y = (head.y - 1) % GameConfig.grid_height + 1
    end

    -- 修复自碰撞检测（当开启时）
    if GameConfig.self_collision then
        -- 从第2节开始检测（修复原bug）
        for i = 2, #GameState.snake.body do
            if head.x == GameState.snake.body[i].x and
               head.y == GameState.snake.body[i].y then
                GameState.game_over = true
                return
            end
        end
    end
end

-- 更新蛇位置（优化移动逻辑）
function update_snake_position()
    GameState.snake.direction = GameState.snake.next_direction

    local directions = {
        right = { x = 1, y = 0 },
        left = { x = -1, y = 0 },
        up = { x = 0, y = -1 },
        down = { x = 0, y = 1 }
    }
    local dir = directions[GameState.snake.direction]
    local new_head = {
        x = GameState.snake.body[1].x + dir.x,
        y = GameState.snake.body[1].y + dir.y
    }

    table.insert(GameState.snake.body, 1, new_head)

    if new_head.x == GameState.food.x  then
        GameState.score = GameState.score + 1
        GameState.current_speed = GameState.current_speed + 0.5/GameState.score  
        generate_food()
    else
        table.remove(GameState.snake.body)
    end
end

-- 生成食物（优化生成算法）
function generate_food()
    local candidates = {}
    
    -- 生成所有可能位置
    for x = 1, GameConfig.grid_width do
        for y = 1, GameConfig.grid_height do
            candidates[#candidates+1] = {x = x, y = y}
        end
    end

    -- 移除蛇身占据的位置
    for _, segment in ipairs(GameState.snake.body) do
        for i = #candidates, 1, -1 do
            if candidates[i].x == segment.x and candidates[i].y == segment.y then
                table.remove(candidates, i)
            end
        end
    end

    -- 随机选择剩余位置
    if #candidates > 0 then
        local selected = candidates[math.random(#candidates)]
        GameState.food.x = selected.x
        GameState.food.y = selected.y
    else
        GameState.game_over = true  -- 蛇已占满地图
    end
end

-- 绘制函数（优化视觉效果）
function draw_grid()
    love.graphics.setColor(0.15, 0.15, 0.15)
    for x = 0, GameConfig.grid_width do
        love.graphics.line(x * GameConfig.cell_size, 0, 
                          x * GameConfig.cell_size, GameConfig.grid_height * GameConfig.cell_size)
    end
    for y = 0, GameConfig.grid_height do
        love.graphics.line(0, y * GameConfig.cell_size, 
                          GameConfig.grid_width * GameConfig.cell_size, y * GameConfig.cell_size)
    end
end

function draw_snake()
    for i, segment in ipairs(GameState.snake.body) do
        -- 渐变颜色效果
        local color_ratio = i / #GameState.snake.body
        love.graphics.setColor(0, 1 - color_ratio*0.5, 0)
        love.graphics.rectangle("fill",
            (segment.x - 1) * GameConfig.cell_size + 1,
            (segment.y - 1) * GameConfig.cell_size + 1,
            GameConfig.cell_size - 2,
            GameConfig.cell_size - 2
        )
    end
end

function draw_food()
    love.graphics.setColor(1, 0.3, 0.3)
    love.graphics.rectangle("fill",
        (GameState.food.x - 1) * GameConfig.cell_size + 2,
        (GameState.food.y - 1) * GameConfig.cell_size + 2,
        GameConfig.cell_size - 4,
        GameConfig.cell_size - 4
    )
end

function draw_ui()
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Score: " .. GameState.score, 10, 10)
    love.graphics.print("Speed: " .. string.format("%.1f", GameState.current_speed), 10, 30)
    
    if GameState.game_over then
        love.graphics.setColor(1, 0.2, 0.2)
        love.graphics.printf("GAME OVER\nPress SPACE to restart",
            0, love.graphics.getHeight()/2 - 30,
            love.graphics.getWidth(), "center")
    end
end