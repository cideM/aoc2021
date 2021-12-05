function makekey(x,y)
  return string.format("%d,%d",x,y)
end

function score(t)
  local overlap = 0
  for k,v in pairs(t) do
    if v > 1 then
      overlap = overlap + 1
    end
  end
  return overlap
end

part1_positions = {}
part2_positions = {}

for line in io.input():lines("*l") do
  x1,y1,x2,y2 = string.match(line, "(%d+),(%d+) %-> (%d+),(%d+)")
  x1,y1,x2,y2 = tonumber(x1),tonumber(y1),tonumber(x2),tonumber(y2)

  local ys, xs = {}, {}
  for y = y1, y2, (y2 > y1 and 1) or -1 do; table.insert(ys, y); end
  for x = x1, x2, (x2 > x1 and 1) or -1 do; table.insert(xs, x); end

  -- If for example both points have the same x coordinate, such as 1,2 -> 1,3,
  -- then we need to still make sure that "xs" and "ys" have the same length.
  -- Or we use the longer of the two to iterate and default the other to the
  -- only value in its list, essentially repeating the X coordinate in this
  -- example.
  -- ys = {2,3}
  -- xs = {1}
  -- --> {1,2}, {1,3}
  --      ^------^---- just default to xs[1]
  if #xs > #ys then
    for i, x in ipairs(xs) do
      local key = makekey(x,ys[i] or ys[1])
      if x1 == x2 or y1 == y2 then
        part1_positions[key] = (part1_positions[key] or 0) + 1
      end
      part2_positions[key] = (part2_positions[key] or 0) + 1
    end
  else
    for i, y in ipairs(ys) do
      local key = makekey(xs[i] or xs[1], y)
      if x1 == x2 or y1 == y2 then
        part1_positions[key] = (part1_positions[key] or 0) + 1
      end
      part2_positions[key] = (part2_positions[key] or 0) + 1
    end
  end

end

print(score(part1_positions))
print(score(part2_positions))
