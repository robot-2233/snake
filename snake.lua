Snake = {
    body = {},
    direction = "right",
    nextDirection = "right",
    growth = 3
}

function Snake:new()
    -- 初始化蛇身
end

function Snake:update(dt)
    -- 移动逻辑
end

function Snake:grow(amount)
    -- 生长逻辑（可被bug修改）
end