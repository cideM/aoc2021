counts = {}
min = math.maxinteger
max = math.mininteger
for pos in string.gmatch(io.read("a"), "%d+") do
  pos = tonumber(pos)
  min = math.min(min, pos)
  max = math.max(max, pos)
  counts[pos] = (counts[pos] or 0) + 1
end

p1, p2 = math.maxinteger, math.maxinteger
for i = min, max do
  local cost_p1, cost_p2 = 0,0
  for pos, count in pairs(counts) do
    local distance = math.abs(pos - i)
    cost_p1 = cost_p1 + distance * count
    cost_p2 = cost_p2 + distance * (distance + 1) / 2 * count
  end
  p1 = math.min(p1, cost_p1)
  p2 = math.min(p2, cost_p2)
end
print(p1)
print(p2)
