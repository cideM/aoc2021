function makekey(x,y) return string.format("%d,%d",x,y) end

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
  local min_y, max_y, min_x, max_x = bounds(grid)
  for y = min_y, max_y do
    for x = min_x, max_x do
      io.write(grid[makekey(x,y)] or ".")
    end
    print("")
  end
  print("")
end

function wrap(a,b) return ((a - 1) % b) + 1 end

function move(g, key, max_x, max_y)
  local cell,x,y = g[key],unkey(key)
  local next_key = cell == ">" and makekey(wrap(x+1, max_x),y)
                            or makekey(x,wrap(y+1, max_y))
  local target = g[next_key]
  if not target or target == "." then
    return next_key, true
  else
    return "", false
  end
end

function move_herd(g, v)
  local new_g, moved = {}, false
  local _, max_y, _, max_x = bounds(g)
  -- This shouldn't be necessary. You could also map over "g" without modifying
  -- it and build up "new_g" in the process. Try adding to else branches, where
  -- you just "new_g[key] = cell". One after the inner and one after the other
  -- if. Now you'll have an infinite loop but I have NO IDEA WHY. It looks like
  -- a classic case of mutating a map while iterating but even if I first read
  -- the result of "pairs(g)" into a list and then iterate over that list it
  -- fails.
  for k,v in pairs(g) do new_g[k] = v end
  for key, cell in pairs(g) do
    if cell == v then
      local new_target_key, ok = move(g, key, max_x, max_y)
      if ok then
        moved = true
        new_g[key] = nil
        new_g[new_target_key] = cell
      end
    end
  end
  return new_g, moved
end

function step(g)
  local g2, moved2 = move_herd(g,">")
  local g3, moved3 = move_herd(g2, "v")
  return g3, moved2 or moved3
end

input, y = {}, 1
for line in io.lines() do
  local x = 1
  for cell in string.gmatch(line, ".") do
    input[makekey(x,y)] = cell
    x = x + 1
  end
  y = y + 1
end

continue, g, n = true, input, 0
while continue and n < math.maxinteger do
  g, continue = step(g)
  n = n + 1
end
print(n)
