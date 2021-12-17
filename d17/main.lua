x1, x2, y1, y2 = string.match(io.read("l"), "x=(%-?%d+)..(%-?%d+), y=(%-?%d+)..(%-?%d+)")
x1, x2, y1, y2 = tonumber(x1), tonumber(x2), tonumber(y1), tonumber(y2)
LOWER_X_BOUND, UPPER_X_BOUND = math.min(x1,x2), math.max(x1,x2)
LOWER_Y_BOUND, UPPER_Y_BOUND = math.min(y1,y2), math.max(y1,y2)

function step(x,y,dx,dy)
  return x + dx, y + dy,
         dx == 0 and 0 or (dx > 0 and dx - 1 or dx + 1),
         dy - 1
end

function is_in_target(x,y)
  return x >= LOWER_X_BOUND
     and x <= UPPER_X_BOUND
     and y >= LOWER_Y_BOUND
     and y <= UPPER_Y_BOUND
end

function is_past_target(x,y,dx,dy)
  return (dy < 0 and y < LOWER_Y_BOUND)
      or (dx > 0 and x > UPPER_X_BOUND)
      or (dx < 0 and x < LOWER_X_BOUND)
end

function fire(start_x,start_y,dx,dy)
  local x,y,dx,dy,steps = start_x,start_y,dx,dy,{}
  while not is_past_target(x,y,dx,dy) do
    x,y,dx,dy = step(x,y,dx,dy)
    table.insert(steps,{x=x,y=y})
    if is_in_target(x,y) then return true,x,y,dx,dy,steps end
  end
  return false,x,y,dx,dy,steps
end

function highpoint(steps)
  local highest_y = math.mininteger
  for _, step in ipairs(steps) do highest_y = math.max(highest_y, step.y) end
  return highest_y
end

min = math.mininteger
best_dx,best_dy, highest, success_velocities_unique, seen = min, min, min, {}, {}

for try_dx = -500,500 do
  for try_dy = -500,500 do
    success,x,y,dx,dy,steps = fire(0,0,try_dx,try_dy)
    if success then
      local key = string.format("%d,%d", try_dx, try_dy)
      if not seen[key] then
        seen[key] = true
        table.insert(success_velocities_unique, { dx = try_dx, dy = try_dy })
      end

      local high = highpoint(steps)
      if high > highest then best_dx,best_dy,highest = try_dx,try_dy,high end
    end
  end
end

print(best_dx,best_dy,highest, #success_velocities_unique)
