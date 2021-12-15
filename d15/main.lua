function makekey(x,y) return string.format("%d,%d",x,y) end

-- GRID is a nested array. The indices are y and x respectively. The same
-- indeces can be used to identify the same node in the prev and q tables in
-- the dijkstra function.
GRID = {}

-- the heap implementation is taken from
-- https://github.com/Tieske/binaryheap.lua/blob/master/src/binaryheap.lua
HEAP = {}

-- String key to point, canonical source of truth. Other tables should have
-- references to these points.
POINTS = {}

function bubbleup(pos)
  while pos > 1 do
    local parent = math.floor(pos/2)
    if not (HEAP[pos].distance < HEAP[parent].distance) then break end
    HEAP[parent], HEAP[pos] = HEAP[pos], HEAP[parent]
    HEAP[parent].heappos = parent
    HEAP[pos].heappos = pos
    pos = parent
  end
end

function sink(pos)
  local last = #HEAP
  while true do
    local min = pos
    local child = pos * 2
    for c = child, child + 1 do
      if c <= last and HEAP[c].distance < HEAP[min].distance then min = c end
    end

    if min == pos then break end
    HEAP[pos], HEAP[min] = HEAP[min], HEAP[pos]
    HEAP[pos].heappos = pos
    HEAP[min].heappos = min
    pos = min
  end
end

function insert(value)
  local pos = #HEAP + 1
  HEAP[pos] = value
  HEAP[pos].heappos = pos
  bubbleup(pos)
end

function remove(pos)
  local last = #HEAP
  if pos == last then
    local v = HEAP[last]
    HEAP[last] = nil
    return v
  end

  local v = HEAP[pos]
  HEAP[pos], HEAP[last] = HEAP[last], HEAP[pos]
  HEAP[last] = nil
  bubbleup(pos)
  sink(pos)
  return v
end

for line in io.lines() do
  local row = {}
  for d in string.gmatch(line, ".") do
    d = tonumber(d)
    local x,y = #row + 1, #GRID + 1
    local key = makekey(x,y)
    local distance = (x == 1 and y == 1 and 0) or math.maxinteger
    local point = { cost = d, x = x, y = y, distance = distance, key = key, heappos = nil }
    POINTS[key] = point
    table.insert(row, point)
  end
  table.insert(GRID, row)
end

function neighbours(x,y)
  return {
    { y = y - 1, x = x     },
    { y = y    , x = x - 1 },
    { y = y    , x = x + 1 },
    { y = y + 1, x = x     }
  }
end

-- dijkstra is an implementation of the pseudocode in
-- https://en.wikipedia.org/wiki/Dijkstra%27s_algorithm#Pseudocode
function dijkstra()
  -- prev is a pointer to the previous point, useful for backtracking the best
  -- path later
  local prev = {}
  -- q is the set of nodes we still need to process
  local q = { len = 0, points = {}}

  for row_num in ipairs(GRID) do
    for _, point in ipairs(GRID[row_num]) do
      q.points[point.key] = point; q.len = q.len + 1
      insert(point)
    end
  end

  while q.len > 0 do
    -- minimum distance that we haven't visited (if not q.points)
    local point_min = remove(1)
    if not q.points[point_min.key] then goto continue end

    -- remove the node from the set of nodes we still need to process
    q.points[point_min.key] = nil; q.len = q.len - 1

    for _, coord in ipairs(neighbours(point_min.x, point_min.y)) do
      local neighbour_key = makekey(coord.x, coord.y)
      -- only consider neighbours we haven't visited
      if q.points[neighbour_key] then
        local neighbour = POINTS[neighbour_key]
        -- total cost from origin (1,1) through the current minimum distance
        -- node to the given neighbour
        local cost = point_min.distance + neighbour.cost
        if cost < neighbour.distance then
          POINTS[neighbour.key].distance = cost
          -- update the heap
          bubbleup(POINTS[neighbour.key].heappos); sink(POINTS[neighbour.key].heappos)
          prev[neighbour.key] = point_min
        end
      end
    end

    ::continue::
  end

  -- backtracking
  local sum, current = 0, POINTS[makekey(#GRID[1], #GRID)]
  while current do
    sum = sum + current.cost
    current = prev[current.key] and POINTS[prev[current.key].key]
  end
  -- origin doesn't count, only if we revisit it
  print(sum - GRID[1][1].cost)
end

-- 315
dijkstra()

-- grow the existing rows horizontally
for row_num in ipairs(GRID) do
  local newrow = table.move(GRID[row_num], 1, #GRID[row_num], 1, {})
  for i = 1, 4 do
    for col_num in ipairs(GRID[row_num]) do
      local oldvalindex = #newrow + 1 - #GRID[row_num]
      local oldval = newrow[oldvalindex].cost
      local newval = oldval + 1
      if newval > 9 then newval = 1 end
      local x,y = #newrow + 1, row_num
      local key = makekey(x,y)
      local point = { cost = newval, x = x, y = y, distance = math.maxinteger, key = key, heappos = nil }
      POINTS[key] = point
      table.insert(newrow, point)
    end
  end
  GRID[row_num] = newrow
end

-- we need to cache this value since it'll change once we start modifying the
-- GRID but we need the original value to know how man rows back we need to
-- look
num_rows = #GRID

-- grow the now wider rows vertically
for i = 1,4 do
  for new_row_num = i * num_rows + 1, i * num_rows + num_rows do
    local newrow = {}
    for x, oldpoint in ipairs(GRID[new_row_num - num_rows]) do
      local newval = oldpoint.cost + 1
      if newval > 9 then newval = 1 end
      local y = new_row_num
      local key = makekey(x,y)
      local point = { cost = newval, x = x, y = y, distance = math.maxinteger, key = key, heappos = nil }
      POINTS[key] = point
      table.insert(newrow, point)
    end
    table.insert(GRID, newrow)
  end
end

-- reset the distances of all points, hacky
for _, row in ipairs(GRID) do
  for _, col in ipairs(row) do
    POINTS[col.key].distance = (row == 1 and col == 1 and 0) or math.maxinteger
  end
end

-- 2993
dijkstra()
