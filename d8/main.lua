-- intersection returns a list with all values that are in all lists passed as
-- arguments
function intersection(a, ...)
    local occurences = {}
    for _,v in ipairs(a) do
      occurences[v] = 1
    end

    local args = table.pack(...)
    for i = 1, args.n do
      for _,v in pairs(args[i]) do
        occurences[v] = (occurences[v] or 0) + 1
      end
    end

    local intersection = {}
    for k,v in pairs(occurences) do
      if v == select("#",...) + 1 then
        table.insert(intersection, k)
      end
    end
    return intersection
end

-- intersection_complement returns the elements that are NOT in all lists. This
-- is different from set difference, which just says elements of a not in b. a
-- // b != b // a but my function here will return the same values in both
-- cases.
function intersection_complement(a, ...)
    local inter = intersection(a, ...)
    local seen = {}
    for _,v in ipairs(inter) do
      seen[v] = true
    end

    local args = table.pack(...)

    local out = {}
    local out_seen = {}
    for i = 1, args.n do
      for _,v in pairs(args[i]) do
        if not seen[v] and not out_seen[v] then
          table.insert(out, v)
          out_seen[v] = true
        end
      end
    end
    for _,v in pairs(a) do
      if not seen[v] and not out_seen[v] then
        table.insert(out, v)
        out_seen[v] = true
      end
    end
    return out
end

-- difference returns a list of values of t1 that are not in t2 
function difference(t1, t2)
    local seen = {}
    for _,v in ipairs(t2) do
      seen[v] = true
    end

    local diff = {}
    for _,v in ipairs(t1) do
      if not seen[v] then
        table.insert(diff, v)
      end
    end
    return diff
end

-- returns true if both lists are equal in values
function eq(t1, t2)
  return table.concat(t1) == table.concat(t2)
end

ZERO  = { 1,1,0,1,1,1,1 }
ONE   = { 0,1,0,1,0,0,0 }
TWO   = { 1,1,1,0,1,1,0 }
THREE = { 1,1,1,1,1,0,0 }
FOUR  = { 0,1,1,1,0,0,1 }
FIVE  = { 1,0,1,1,1,0,1 }
SIX   = { 1,0,1,1,1,1,1 }
SEVEN = { 1,1,0,1,0,0,0 }
EIGHT = { 1,1,1,1,1,1,1 }
NINE  = { 1,1,1,1,1,0,1 }

CONVERT = {
  [table.concat(ZERO)]   = 0,
  [table.concat(ONE)]   = 1,
  [table.concat(TWO)]   = 2,
  [table.concat(THREE)] = 3,
  [table.concat(FOUR)]  = 4,
  [table.concat(FIVE)]  = 5,
  [table.concat(SIX)]   = 6,
  [table.concat(SEVEN)] = 7,
  [table.concat(EIGHT)] = 8,
  [table.concat(NINE)]  = 9,
}

-- solve_patterns expects a list of 10 unique patterns and returns a table where
-- the key is a character and the value is an index into a list of 7 elements,
-- where each elements corresponds to a position of the 7-segment display.
--  1
-- 7 2
--  3
-- 6 4
--  5
function solve_patterns(t)
    -- sorting the table let's us grab specific values more easily
    table.sort(t, function(a,b) return #a < #b end)

    -- return value described above
    local mapping = {}

    -- "7" and "1" share the positions 2 and 4, but differ in 1
    -- variable names here correspond to numbers from the comment above the
    -- function
    local one = difference(t[2],t[1])
    mapping[one[1]] = 1

    -- intersection of "5","2","3" and "4" (unique) has to be position 3
    local three = intersection(t[4],t[5],t[6],t[3])
    mapping[three[1]] = 3

    -- Now we know precisely 1 and 3 and we at least know that t[1] has 2 and 4
    -- but not which is which. We can create a set containing 1,3,2,4 and the
    -- elements of "4" that are not in that set has to be position 7.
    local seven = difference(t[3], {one[1], three[1], t[1][1], t[1][2]})
    mapping[seven[1]] = 7

    -- "0", "6", "9" and "1" share position 4
    local four = intersection(t[7],t[8],t[9],t[1])
    mapping[four[1]] = 4

    -- now solve the position 2 and 4 dilemma
    local two = difference(t[1], {four[1]})
    mapping[two[1]] = 2

    -- "0", "6" and "9" differ in 2, 6 and 3. We know two of those, giving us
    -- position 6.
    local tmp = intersection_complement(t[7],t[8],t[9])
    local six = intersection_complement(tmp, {two[1], three[1]})
    mapping[six[1]] = 6

    local five = difference(t[7],{one[1],two[1],three[1],four[1],six[1],seven[1]})
    mapping[five[1]] = 5

    -- returns a function that solves the outputs for this entry
    return function(t)
      local out = {0,0,0,0,0,0,0}
      for _, char in ipairs(t) do
        out[mapping[char]] = 1
      end
      return CONVERT[table.concat(out)]
    end
end

entries = {}
for line in io.input():lines("*l") do
  local sep = string.find(line, "|")
  local pre = string.sub(line,1,sep - 1)
  local post = string.sub(line,sep)

  local entry = { patterns = {}, output = {} }

  for pattern in string.gmatch(pre, "%a+") do
    local set = {}
    for char in string.gmatch(pattern, ".") do
      table.insert(set, char)
    end
    table.insert(entry.patterns, set)
  end

  for output in string.gmatch(post, "%a+") do
    local set = {}
    for char in string.gmatch(output, ".") do
      table.insert(set, char)
    end
    table.insert(entry.output, set)
  end

  table.insert(entries, entry)
end

-- Part 1
count = 0
for _, entry in ipairs(entries) do
  for _, out in ipairs(entry.output) do
    if #out == 3 or
       #out == 4 or
       #out == 2 or
       #out == 7 then
       count = count + 1
     end
  end
end
print(count)

-- Part 2
numbers = {}
for _, entry in ipairs(entries) do
  local fn = solve_patterns(entry.patterns)
  local number = {}
  for _, output in ipairs(entry.output) do
    table.insert(number, tostring(fn(output)))
  end
  table.insert(numbers, tonumber(table.concat(number)))
end

sum = 0
for _, n in ipairs(numbers) do
  sum = sum + n
end
print(sum)
