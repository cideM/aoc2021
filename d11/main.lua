GRID = {}        -- Octopuses
FLASHES = 0      -- Overall number of flashes
FLASHES_STEP = 0 -- Flashes per step for part 2
-- Key is 5,1 (row, col) and value just a boolean, to keep track of which
-- octopuses flashed during a step. Reset at the start of each step.
SEEN = {}

for line in io.input():lines("*l") do
  local row = {}
  for d in string.gmatch(line, ".") do; table.insert(row, tonumber(d)); end
  table.insert(GRID, row)
end

function flash(row, col)
  SEEN[string.format("%d,%d",row,col)] = true
  GRID[row][col] = 0
  FLASHES = FLASHES + 1
  FLASHES_STEP = FLASHES_STEP + 1

  local adjacent = {{row-1, col-1}, {row-1, col  }, {row-1, col+1},
                    {row  , col-1}, {row  , col+1},
                    {row+1, col-1}, {row+1, col  }, {row+1, col+1}}

  for _, coord in ipairs(adjacent) do
    local r, c = coord[1], coord[2]
    local value = (GRID[r] or {})[c]
    if SEEN[string.format("%d,%d",r,c)] or not value then goto skip; end
    GRID[r][c] = value + 1
    if GRID[r][c] > 9 then; flash(r, c); end
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
  FLASHES_STEP = 0
  step()
  if i == 99 then; print("part 1", FLASHES); end
  if FLASHES_STEP == (#GRID * #GRID[1]) then; print("part 2", i + 1) break; end
end
