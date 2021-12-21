function makekey(x,y) return string.format("%d,%d", x, y) end

function unkey(s)
  local x,y = string.match(s,"(%-?%d+),(%-?%d+)")
  return tonumber(x), tonumber(y)
end

function bounds(grid)
  local min_y, max_y = math.maxinteger, math.mininteger
  local min_x, max_x = math.maxinteger, math.mininteger
  for k,v in pairs(grid) do
    local x,y = unkey(k)
    min_y, max_y = math.min(min_y, y), math.max(max_y, y)
    min_x, max_x = math.min(min_x, x), math.max(max_x, x)
  end
  return min_y, max_y, min_x, max_x
end

function printgrid(grid)
  min_y, max_y, min_x, max_x = bounds(grid)
  for y = min_y, max_y do
    for x = min_x, max_x do
      io.write(grid[makekey(x,y)])
    end
    print("")
  end
  print("")
end

function nextpixel(s, grid, y, x, default)
  local region = {{y-1, x-1}, {y-1, x}, {y-1, x+1},
                 {y,   x-1}, {y,   x}, {y,   x+1},
                 {y+1, x-1}, {y+1, x}, {y+1, x+1}}
  local binary, default = {}, default or "."

  for _, point in ipairs(region) do
    local y,x = point[1], point[2]
    table.insert(binary, (grid[makekey(x,y)] or default) == "#" and 1 or 0)
  end
  local d = tonumber(table.concat(binary), 2) + 1
  return s:sub(d,d)
end

function parse()
  local s, grid = nil, {}
  local y = 1
  for line in io.lines() do
    if not s then s = line
    elseif string.match(line, "#") then
      local x = 1
      for c in string.gmatch(line, ".") do
        local key = makekey(x, y)
        grid[key], x = c, x + 1
      end
      y = y + 1
    end
  end

  return grid, s
end

function step(s, grid, grow, default)
  local new_grid = {}
  local min_y, max_y, min_x, max_x = bounds(grid)
  local min_y, max_y, min_x, max_x = min_y - grow, max_y + grow, min_x - grow, max_x + grow

  for y = min_y, max_y do
    for x = min_x, max_x do
      local next = nextpixel(s, grid, y,x, default)
      local key = makekey(x,y)
      new_grid[key] = next
   end
  end

  return new_grid
end

function count(grid)
  local min_y, max_y, min_x, max_x = bounds(grid)
  local n = 0
  for y = min_y, max_y do
    for x = min_x, max_x do
      n = n + (grid[makekey(x,y)] == "#" and 1 or 0)
    end
  end
  return n
end

grid, s = parse()

for i = 1, 50 do
  grid = step(s, grid, 5, i % 2 == 0 and "#" or ".")
  if i == 2 then print(count(grid)) end
  if i == 50 then print(count(grid)) end
end
