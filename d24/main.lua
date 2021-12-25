function parse_instruction(instruction)
  local op, a, _, b = string.match(instruction, "(%l+) (%l)( ?)(.*)")
  return { op = op, a = a, b = b }
end

-- parse_instructions returns groups of instructions that starts with an "inp"
function parse_instructions()
  local instructions = {}
  for line in io.lines() do
    local parsed = parse_instruction(line)
    if parsed.op == "inp" then table.insert(instructions, {}) end
    table.insert(instructions[#instructions], parsed)
  end
  return instructions
end

function run_block(number, instructions, registers)
  local r = {}; for k,v in pairs(registers) do r[k] = v end
  local read_b = function(s) return tonumber(s) or r[s] end

  for _, ins in ipairs(instructions) do
    if ins.op == "inp" then r[ins.a] = number
    elseif ins.op == "add" then r[ins.a] = r[ins.a] + read_b(ins.b)
    elseif ins.op == "mul" then r[ins.a] = r[ins.a] * read_b(ins.b)
    elseif ins.op == "div" then r[ins.a] = r[ins.a] // read_b(ins.b)
    elseif ins.op == "mod" then r[ins.a] = r[ins.a] % read_b(ins.b)
    elseif ins.op == "eql" then r[ins.a] = r[ins.a] == read_b(ins.b) and 1 or 0
    end
  end

  return r
end

cache = {}
function run(n, blocks, next_nums, previous, registers)
  -- it's really, really important to create a deep copy
  local r = {}; for k,v in pairs(registers) do r[k] = v end

  local key = #previous .. "|" .. r.z .. "|" .. n
  if cache[key] then return end

  local new_registers, new_previous = run_block(n, blocks[#previous + 1], r), previous .. n

  if #new_previous == 14 then if new_registers.z == 0 then return previous .. n end
  else
    for _, new_num in ipairs(next_nums) do
      local result = run(new_num, blocks, next_nums, new_previous, new_registers)
      if result then return result end
    end
  end

  -- It's important that this happens after the recursion. In the first run we
  -- look at:
  -- n = 9, previous = ""  <-- first "run"
  -- We then want to call "run" recursively, first with another 9, so:
  -- n = 9, previous = "9" <-- first recursive "run"
  -- We're doing depth-first recursion here so the cache will quickly fill up
  -- with the first sequence of "previous" digits:
  -- "9" = true, "99" = true, "999" = true, ...
  -- Once that first run is over, we're back in the next iteration of the loop
  -- in the "else" clause. Now we'll try "98..." instead of "99...". So the
  -- next step will be "989", "9899", and so on. But what happens when we call
  -- "run" for the "989" case? We'll have:
  -- n = 9, previous = "98"
  -- If in this case, the value of "z" happens to be the same as for:
  -- n = 9, previous = "99"
  -- then both runs will have the same cache key of:
  -- "2|0|9"
  --  ^-^-^-- number of previous
  --    +-|-- z register
  --      +-- current number
  --  That's why filling the cache needs to come last.
  cache[key] = true
end

empty_reg = { w = 0, x = 0, y = 0, z = 0 }

function p1(instructions)
  -- 99799212949967
  for i = 9,1,-1 do
    print(i)
    local result = run(i, instruction_blocks, {9,8,7,6,5,4,3,2,1}, "", empty_reg)
    if result then return result end
  end
end

function p2(instructions)
  -- 34198111816311
  for i = 1,9 do
    print(i)
    local result = run(i, instruction_blocks, {1,2,3,4,5,6,7,8,9}, "", empty_reg)
    if result then return result end
  end
end

instruction_blocks = parse_instructions()

print("start p1")
print(p1())
print("start p2")
print(p2())
