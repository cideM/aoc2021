-- Octopuses
GRID = {}
-- Overall number of flashes
FLASHES = 0
-- Key is 5,1 (row, col) and value just a boolean, to keep track of which
-- octopuses flashed during a step. Reset at the start of each step.
SEEN = {}

for line in io.input():lines("*l") do
  local row_num = #GRID + 1
  if not GRID[row_num] then; GRID[row_num] = {}; end
  for d in string.gmatch(line, ".") do
    table.insert(GRID[row_num], tonumber(d))
  end
end

function flash(row_num, col_num)
  SEEN[string.format("%d,%d",row_num,col_num)] = true
  GRID[row_num][col_num] = 0
  FLASHES = FLASHES + 1

  local adjacent = {
    {row_num-1, col_num-1}, {row_num-1, col_num  }, {row_num-1, col_num+1},
    {row_num  , col_num-1}, {row_num  , col_num+1},
    {row_num+1, col_num-1}, {row_num+1, col_num  }, {row_num+1, col_num+1},
  }

  for _, coord in ipairs(adjacent) do
    local value = (GRID[coord[1]] or {})[coord[2]]
    if SEEN[string.format("%d,%d",coord[1],coord[2])] or not value then goto skip; end
    GRID[coord[1]][coord[2]] = value + 1
    if GRID[coord[1]][coord[2]] > 9 then; flash(coord[1], coord[2]); end
    ::skip::
  end
end

function step()
  SEEN = {}
  -- Increase values
  for row_num, row in ipairs(GRID) do
    for col_num, value in ipairs(row) do
      GRID[row_num][col_num] = value + 1
    end
  end

  -- Flash first batch and recursively keep flashing
  for row_num, row in ipairs(GRID) do
    for col_num, value in ipairs(row) do
      if value > 9 and not SEEN[string.format("%d,%d",row_num,col_num)] then
        flash(row_num, col_num)
      end
    end
  end
end

for i = 0, 500 do
  step()
  if i == 99 then
    print("part 1", FLASHES)
  end

  local flashes = 0
  -- Can't use # for a sparse table
  for key in pairs(SEEN) do; flashes = flashes + 1; end
  if flashes == (#GRID * #GRID[1]) then
    print("part 2", i + 1)
    break
  end
end
