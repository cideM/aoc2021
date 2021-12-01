local last_sum
local increases = 0

local numbers = {}

for line in io.input():lines("*l") do
  table.insert(numbers, tonumber(line))
end

local last_index = #numbers

for i = 3, last_index do
  local sum = numbers[i] + numbers[i - 1] + numbers[i - 2]
  if last_sum and sum > last_sum then
    increases = increases + 1
  end
  last_sum = sum
end

print(increases)
