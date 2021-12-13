GRID = {}
MAX_X = math.mininteger
MAX_Y = math.mininteger

function count()
  local total = 0
  for k in pairs(GRID) do total = total + 1 end
  return total
end

function printgrid()
  for y = 0, MAX_Y do
    for x = 0, MAX_X do
      local key = makekey(x,y)
      io.write(GRID[key] or ".")
    end
    print("")
  end
  print("")
end

-- makekey turns an x,y point into a table key
function makekey(x,y) return string.format("%d,%d",x,y) end

-- unkey reverses makekey
function unkey(s)
  local x,y = string.match(s,"(%d+),(%d+)")
  return tonumber(x), tonumber(y)
end

-- fold traverses the grid and for **marked** points it call the given "move"
-- function. If that function returns nil, nothing happens, otherwise it moves
-- the point to the new coordinates returned by "move".
function fold(move)
  local newgrid = {}
  for key in pairs(GRID) do
    if GRID[key] then
      local newx, newy = move(key)
      if newx and newy then
        GRID[key] = nil
        newgrid[makekey(newx, newy)] = "#"
      end
    end
  end
  for k,v in pairs(newgrid) do GRID[k] = v end
end

COUNTS = {}
for line in io.input():lines("*l") do
  local x,y = unkey(line)
  if x and y then
    GRID[line] = "#"
    MAX_X = math.max(MAX_X, x); MAX_Y = math.max(MAX_Y, y)
  end

  if string.match(line, "fold along x") then
    local foldx = tonumber(string.match(line, "fold along x=(%d+)"))
    fold(function (key)
      local x,y = unkey(key)
      if x > foldx then return foldx - (x - foldx), y end
    end)
    table.insert(COUNTS, count())
    MAX_X = math.min(MAX_X, foldx - 1) -- Truncate the grid after folding
  end

  if string.match(line, "fold along y") then
    local foldy = tonumber(string.match(line, "fold along y=(%d+)"))
    fold(function (key)
      local x,y = unkey(key)
      if y > foldy then return x, foldy - (y - foldy) end
    end)
    table.insert(COUNTS, count())
    MAX_Y = math.min(MAX_Y, foldy - 1) -- Truncate the grid after folding
  end
end

print("part 1", COUNTS[1])
printgrid()
