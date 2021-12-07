lines = {}
for line in io.input():lines("*l") do
  table.insert(lines, line)
end

depth, horizontal = 0, 0
for _, line in ipairs(lines) do
  local n = string.match(line, "%d+")
  n = tonumber(n)
  if string.match(line, "forward") then
    horizontal = horizontal + n
  elseif string.match(line, "down") then
    depth = depth + n
  else
    depth = depth - n
  end
end
print(depth * horizontal)

depth, horizontal, aim = 0, 0, 0
for _, line in ipairs(lines) do
  local n = string.match(line, "%d+")
  n = tonumber(n)
  if string.match(line, "forward") then
    horizontal = horizontal + n
    depth = depth + (aim * n)
  elseif string.match(line, "down") then
    aim = aim + n
  else
    aim = aim - n
  end
end
print(depth * horizontal)
