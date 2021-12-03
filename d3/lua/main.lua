local last_line
local increases = 0

function p1 ()
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
  for c = #col_sums, 1, -1 do
    if num_lines/col_sums[c] < 2 then
      most_common_reverse[c] = 1
    else
      most_common_reverse[c] = 0
    end
  end

  local gamma = tonumber(table.concat(most_common_reverse, ""), 2)

  local least_common_reverse = {}
  for c = #col_sums, 1, -1 do
    if num_lines/col_sums[c] > 2 then
      least_common_reverse[c] = 1
    else
      least_common_reverse[c] = 0
    end
  end

  local epsilon = tonumber(table.concat(least_common_reverse, ""), 2)
  print(epsilon * gamma)
end

function p2 ()
  local go
  go = function(lines, column, isneedle)
    local sum = 0
    for _, line in ipairs(lines) do
      sum = sum + line:sub(column,column)
    end

    local needle = isneedle(#lines, sum)

    local keep = {}
    for _, line in ipairs(lines) do
      if line:sub(column,column) == needle then
        table.insert(keep, line)
      end
    end

    if #keep == 1 then
      return keep[1]
    end

    return go(keep, column + 1, isneedle)
  end

  local lines = {}
  for line in io.input():lines("*l") do
    table.insert(lines, line)
  end

  local most_common = function(num_lines, sum)
    if num_lines/sum > 2 then
      return "0"
    end
    return "1"
  end

  local least_common = function(num_lines, sum)
    if num_lines/sum > 2 then
      return "1"
    end
    return "0"
  end

  local oxygen = go(lines, 1, most_common)
  local co2 = go(lines, 1, least_common)
  print(tonumber(oxygen, 2) * tonumber(co2, 2))
end

if arg[1] == "p1" then
  p1()
else
  p2()
end
