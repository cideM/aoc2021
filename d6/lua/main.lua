age_count = {}

for age in string.gmatch(io.read("a"), "%d+") do
  -- Lua uses 1-based indexing so we increment all ages by 1
  age = tonumber(age) + 1
  age_count[age] = (age_count[age] or 0) + 1
end

-- Change to 80 for part 1
for d = 1, 256 do
  num_create = age_count[1] or 0
  -- Move the array left by 1
  table.move(age_count, 1, 9, 0, age_count)
  age_count[9] = num_create
  age_count[7] = (age_count[7] or 0) + num_create
end

sum = 0
for age = 1, 9 do
  sum = sum + (age_count[age] or 0)
end
print(sum)
