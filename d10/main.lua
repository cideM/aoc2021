FROM_CLOSE = { ["]"] = "[", [")"] = "(", [">"] = "<", ["}"] = "{" }
FROM_OPEN = { ["["] = "]", ["("] = ")", ["<"] = ">", ["{"] = "}" }

INCOMPLETE_LINES = {}
ILLEGAL_LINES = {}
STACK = {}

for line in io.input():lines("*l") do
  local keep = true
  STACK = {}
  for char in string.gmatch(line, ".") do
    if FROM_OPEN[char] then
      table.insert(STACK, char)
    else
      if FROM_CLOSE[char] == STACK[#STACK] then
        table.remove(STACK, #STACK)
      else
        keep = false
        table.insert(ILLEGAL_LINES, char)
        break
      end
    end
  end
  if keep then
    local missing_chars = {}
    for i = #STACK, 1, -1 do
      table.insert(missing_chars, FROM_OPEN[STACK[i]])
    end
    table.insert(INCOMPLETE_LINES, table.concat(missing_chars))
  end
end

score_illegal = 0
for _,char in ipairs(ILLEGAL_LINES) do
  if char == ")" then
    score_illegal = score_illegal + 3
  elseif char == "]" then
    score_illegal = score_illegal + 57
  elseif char == "}" then
    score_illegal = score_illegal + 1197
  elseif char == ">" then
    score_illegal = score_illegal + 25137
  end
end
print(score_illegal)

scores_autocomplete = {}
for _, line in ipairs(INCOMPLETE_LINES) do
  local score = 0
  for char in string.gmatch(line, ".") do
    score = score * 5
    if char == ")" then
      score = score + 1
    elseif char == "]" then
      score = score + 2
    elseif char == "}" then
      score = score + 3
    elseif char == ">" then
      score = score + 4
    end
  end
  table.insert(scores_autocomplete, score)
end

table.sort(scores_autocomplete)
print(scores_autocomplete[math.ceil(#scores_autocomplete/2)])
