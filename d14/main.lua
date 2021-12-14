PAIR_COUNTS = {}
INSERTIONS = {}

function score(PAIR_COUNTS)
    local count, max, min = {}, math.mininteger, math.maxinteger
    for k,v in pairs(PAIR_COUNTS) do
      local a, b = k:sub(1,1), k:sub(2,2)
      count[a] = (count[a] or 0) + v
      count[b] = (count[b] or 0) + v
    end
    for k,v in pairs(count) do; count[k] = math.ceil(v/2); end
    for k,v in pairs(count) do;
      max = math.max(v, max)
      min = math.min(v, min)
    end
    return max - min
end

for line in io.input():lines("*l") do
  if string.match(line, "^[A-Z]+$") then
    local pairs = {line:sub(1,1)}
    for c in string.gmatch(line:sub(2), ".") do
      table.insert(pairs, c)
      local pair = table.concat(pairs)
      PAIR_COUNTS[pair] = (PAIR_COUNTS[pair] or 0) + 1
      table.remove(pairs, 1)
    end
  end

  local from, to = string.match(line, "^(%a%a) %-> (%a)$")
  if from and to then; INSERTIONS[from] = to; end
end

function step()
  local new_counts = {}
  for pair, count in pairs(PAIR_COUNTS) do
    local insert = INSERTIONS[pair]
    local pair1 = pair:sub(1,1) .. insert
    local pair2 = insert .. pair:sub(2,2)
    new_counts[pair1] = (new_counts[pair1] or 0) + count
    new_counts[pair2] = (new_counts[pair2] or 0) + count
  end
  PAIR_COUNTS = new_counts
end

for i=1,10 do; step(); end
print(score(PAIR_COUNTS))
for i=1,40 do; step(); end
print(score(PAIR_COUNTS))
