lines = {}
for line in io.input():lines("*l") do
  table.insert(lines, line)
end

-- For part 1, track the sums of each column since we can then easily determine
-- if 1 or 0 is the dominant value by checking if the sum is lower than half
-- the number of values (one column per line so line count can be used)
col_sums = {}
num_lines = 0
for _, line in ipairs(lines) do
  num_lines = num_lines + 1
  local column = 1
  for digit in string.gmatch(line, ".") do
    col_sums[column] = (col_sums[column] or 0) + tonumber(digit)
    column = column + 1
  end
end

most_common_reverse = {}
least_common_reverse = {}
for c = #col_sums, 1, -1 do
  if num_lines/col_sums[c] < 2 then
    least_common_reverse[c] = 0
    most_common_reverse[c] = 1
  else
    least_common_reverse[c] = 1
    most_common_reverse[c] = 0
  end
end

gamma = tonumber(table.concat(most_common_reverse, ""), 2)
epsilon = tonumber(table.concat(least_common_reverse, ""), 2)
print("part 1", epsilon * gamma)

-- Part 2 shares the most and least common value logic but here we then select
-- only those values from each column that match what we're looking for (most
-- or least common).
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

most_common = function(num_lines, sum)
  return (num_lines/sum > 2 and "0") or "1"
end

least_common = function(num_lines, sum)
  return (num_lines/sum > 2 and "1") or "0"
end

oxygen = go(lines, 1, most_common)
co2 = go(lines, 1, least_common)
print("part 2", tonumber(oxygen, 2) * tonumber(co2, 2))
