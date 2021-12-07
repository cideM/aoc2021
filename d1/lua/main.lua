numbers = {}

for num in io.input():lines("*l") do
  table.insert(numbers, tonumber(num))
end

last_num, increases = nil, 0
for _, num in ipairs(numbers) do
  if last_num and num > last_num then
    increases = increases + 1
  end
  last_num = num
end
print(increases)

increases = 0
for i = 3, #numbers do
  local sum = numbers[i] + numbers[i - 1] + numbers[i - 2]
  if last_sum and sum > last_sum then
    increases = increases + 1
  end
  last_sum = sum
end

print(increases)
