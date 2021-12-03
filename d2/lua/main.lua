local last_line
local increases = 0

function p1 ()
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
end

function p2 ()
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
end

if arg[1] == "p1" then
  p1()
else
  p2()
end
