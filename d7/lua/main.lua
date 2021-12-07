require"lib"

positions = readinput()

function p1(crab_pos, try_pos)
  -- The cost of moving a crab is equal to the distance
  return math.abs(crab_pos - try_pos)
end

function p2(crab_pos, try_pos)
  local n = math.abs(crab_pos - try_pos)
  -- The cost a partial sum of the series 1 + 2 + 3 + ...
  return n * (n + 1) / 2
end

print(solve(positions, p1))
print(solve(positions, p2))
