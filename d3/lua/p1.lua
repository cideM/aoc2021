-- Read the input values linewise but track the columns.
col_sums = {}
num_lines = 0
for line in io.input():lines("*l") do
  num_lines = num_lines + 1
  local column = 1
  for digit in string.gmatch(line, ".") do
    col_sums[column] = (col_sums[column] or 0) + tonumber(digit)
    column = column + 1
  end
end

-- Finding the most or least common binary value in a list of binary values is
-- as simple as checking if the sum is lower than half the length.
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
print(epsilon * gamma)
