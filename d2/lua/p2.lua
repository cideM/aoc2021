local depth = 0
local horizontal = 0
local aim = 0

for line in io.input():lines("*l") do
  local number = string.match(line, "%d+")
  if string.match(line, "forward") then
    horizontal = horizontal + number
    depth = depth + (aim * number)
  elseif string.match(line, "down") then
    aim = aim + number
  else
    aim = aim - number
  end
end

print(depth * horizontal)

