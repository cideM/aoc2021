local last_line
local increases = 0

for line in io.input():lines("*l") do
  if last_line and tonumber(line) > last_line then
    increases = increases + 1
  end
  last_line = tonumber(line)
end

print(increases)
