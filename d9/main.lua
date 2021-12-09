-- row,col -> number (height)
coords = {}
-- row,col (1) -> row,col (2) where a group of points (1) has the same low
-- point (2) to which water flows
basincoords = {}

for line in io.input():lines("*l") do
  local row = #coords + 1
  if not coords[row] then
    coords[row] = {}
  end
  for num in string.gmatch(line, ".") do
    num = tonumber(num)
    table.insert(coords[row], num)
  end
end

function basinify(row, col, lowpoint)
    -- Stop at 9, out of bounds, and if the point is already in a basin
    local current_point = (coords[row] or {})[col] or math.maxinteger
    local key = string.format("%d,%d",row,col)
    if basincoords[key] or current_point >= 9 then; return; end

    basincoords[key] = lowpoint

    for _, coord in ipairs({{row-1, col}, {row, col-1}, {row, col+1}, {row+1, col}}) do
      local neighbour_value = (coords[coord[1]] or {})[coord[2]] or math.mininteger
      -- Only recurse if we're going uphill
      if neighbour_value > current_point then; basinify(coord[1], coord[2], lowpoint); end
    end
end

-- is the point at row,col lower than its N,E,S and W neighbour?
function is_low_point(row, col)
  local neighbour_min = math.min(
    ((coords[row - 1] or {})[col    ] or math.maxinteger),
    ((coords[row    ] or {})[col - 1] or math.maxinteger),
    ((coords[row    ] or {})[col + 1] or math.maxinteger),
    ((coords[row + 1] or {})[col    ] or math.maxinteger)
  )
  return coords[row][col] < neighbour_min
end

risklevel = 0
for row_num, row in ipairs(coords) do
  for col_num, cell in ipairs(row) do
    if is_low_point(row_num, col_num) then
      basinify(row_num, col_num, {row_num, col_num})
      risklevel = risklevel + cell + 1
    end
  end
end
print("part 1", risklevel)

-- group the basin points by the low point to which they flow and sum each
-- group
basinsizes = {}
for _, lowpoint in pairs(basincoords) do
    local key = table.concat(lowpoint,",")
    basinsizes[key] = (basinsizes[key] or 0) + 1
end

-- keep the values, discard the keys
sizesonly = {}
for _,size in pairs(basinsizes) do
  table.insert(sizesonly, size)
end
table.sort(sizesonly)

product = 1
for k,size in pairs({sizesonly[#sizesonly], sizesonly[#sizesonly-1], sizesonly[#sizesonly-2]}) do
  product = product * size
end
print("part 2", product)
