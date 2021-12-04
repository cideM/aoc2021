local col_sums = {}
local num_lines = 0
for line in io.input():lines("*l") do
  num_lines = num_lines + 1
  local column = 1
  for digit in string.gmatch(line, ".") do
    if not col_sums[column] then
      col_sums[column] = 0
    end
    col_sums[column] = col_sums[column] + tonumber(digit)
    column = column + 1
  end
end

local most_common_reverse = {}
local least_common_reverse = {}
for c = #col_sums, 1, -1 do
  if num_lines/col_sums[c] < 2 then
    least_common_reverse[c] = 0
    most_common_reverse[c] = 1
  else
    least_common_reverse[c] = 1
    most_common_reverse[c] = 0
  end
end

local gamma = tonumber(table.concat(most_common_reverse, ""), 2)
local epsilon = tonumber(table.concat(least_common_reverse, ""), 2)
print(epsilon * gamma)
