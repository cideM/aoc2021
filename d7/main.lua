counts = {}
min = math.maxinteger
max = math.mininteger
for pos in string.gmatch(io.read("a"), "%d+") do
  pos = tonumber(pos)
  min = math.min(min, pos)
  max = math.max(max, pos)
  counts[pos] = (counts[pos] or 0) + 1
end

best_cost_p1, best_cost_p2 = math.maxinteger, math.maxinteger
for i = min, max do
  local cost_all_p1, cost_all_p2 = 0,0
  for pos, count in pairs(counts) do
    local cost_one_p1 = math.abs(pos - i)
    cost_all_p1 = cost_all_p1 + cost_one_p1 * count
    cost_all_p2 = cost_all_p2 + cost_one_p1 * (cost_one_p1 + 1) / 2 * count
  end
  best_cost_p1 = math.min(best_cost_p1, cost_all_p1)
  best_cost_p2 = math.min(best_cost_p2, cost_all_p2)
end
print(best_cost_p1)
print(best_cost_p2)
