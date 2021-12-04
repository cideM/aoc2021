local depth = 0
local horizontal = 0

for line in io.input():lines("*l") do
  local number = string.match(line, "%d+")
  if string.match(line, "forward") then
    horizontal = horizontal + number
  elseif string.match(line, "down") then
    depth = depth + number
  else
    depth = depth - number
  end
end

print(depth * horizontal)
