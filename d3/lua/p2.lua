go = function(lines, column, make_needle)
  local sum = 0
  for _, line in ipairs(lines) do
    sum = sum + line:sub(column,column)
  end

  local needle = make_needle(#lines, sum)

  local keep = {}
  for _, line in ipairs(lines) do
    if line:sub(column,column) == needle then
      table.insert(keep, line)
    end
  end

  if #keep == 1 then
    return keep[1]
  end

  return go(keep, column + 1, make_needle)
end

lines = {}
for line in io.input():lines("*l") do
  table.insert(lines, line)
end

most_common = function(num_lines, sum)
  return (num_lines/sum > 2 and "0") or "1"
end

least_common = function(num_lines, sum)
  return (num_lines/sum > 2 and "1") or "0"
end

oxygen = go(lines, 1, most_common)
co2 = go(lines, 1, least_common)
print(tonumber(oxygen, 2) * tonumber(co2, 2))

