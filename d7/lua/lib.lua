function readinput()
  local counts = {}
  for pos in string.gmatch(io.read("a"), "%d+") do
    pos = tonumber(pos)
    counts[pos] = (counts[pos] or 0) + 1
  end
  return counts
end

function solve(counts, costfn)
  -- Find the minimum and maximum position since the best alignment positions
  -- has to be somewhere in between
  local positions = {}
  for k in pairs(counts) do
    table.insert(positions, k)
  end
  local min = math.min(table.unpack(positions))
  local max = math.max(table.unpack(positions))

  local best_cost = math.maxinteger
  local best_pos = 0

  for i = min, max do
    local cost_all = 0
    for pos, count in pairs(counts) do
      local cost_one = costfn(pos, i)
      cost_all = cost_all + cost_one * count
    end
    if cost_all < best_cost then
      best_pos = i
      best_cost = cost_all
    end
  end

  return best_pos, best_cost
end
