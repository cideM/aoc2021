function parse(s)
  local s = string.gsub(string.gsub(s, "%[", "{"), "%]", "}")
  return load(string.format("return %s",s))()
end

-- explode performs a single explosion in the given tree and adds the left and
-- right number of the exploded pair in the correct places. It returns:
-- - new tree
-- - value that needs to be added on the left (if any)
-- - value that needs to be added on the right (if any)
-- - if an explosion happened
function explode(t, depth, add_l, add_r, can_explode)
  --[[
  explode has two tasks:
  1. perform a single explosion, as long as "can_explode" is true
  2. add the left and right numbers of the exploded pair in the correct places
  Task 2. is achieved by traversing the tree depth-first and favoring the left
  subtree, so any node knows about explosions that happened in its subtrees
  before moving further up. The two numbers are then propagated up through
  return values and past into other, unevaluated subtrees. The only exception
  here is that if a right subtree explodes, the left was already rebuilt so we
  need to rebuild the left subtree again, with the knowledge of the right
  subtree explosion.
  --]]
  local depth, can_explode = depth or 0, can_explode == nil and true or can_explode

  if type(t) == "number" then
    local add = add_l or add_r or 0
    return t + add, nil, nil, false
  end

  if depth == 4 and can_explode then return 0, t[1], t[2], true end

  -- lsub and rsub are the new, left and right subtrees.
  -- l and r are the left and right number from the exploded pair in the left subtree
  local lsub, l, r, ok = explode(t[1], depth + 1, add_l, nil, can_explode)

  --[[
  Rebind some variables for the right subtree. Most noteworth is how the
  **right** number from the exploded, left subtree is passed to the right
  subtree as the **left** number.
       o
       |
    +--x--------+
    |      +----+----+
  [1,3]    4         9
  In this scenario, if the pair [1,3] explodes, the parent node "x" gets the
  values l = 1 and r = 3 from the recursive "explode" call for the left
  subtree. It needs to pass the **right** number, 3, down the **left** side of
  the right subtree, so that 3 is added to 4 and not to 9.
  --]]
  local add_l, add_r, can_explode = ok and r, ok and nil or add_r, not ok and can_explode

  -- the "r" suffix denotes the values from the "r"ight subtree
  local rsub, lr, rr, okr = explode(t[2], depth + 1, add_l, add_r, can_explode)

  -- right exploded
  if okr then
    lsub = explode(t[1], depth + 1, nil, lr, false)
    return {lsub, rsub}, nil, rr, true
  -- left exploded
  elseif ok then return {lsub, rsub}, l, nil, true
  -- no explosion
  else return {lsub, rsub}, nil, nil, false
  end

end

-- split a single number in the given tree "t". Returns the new tree and
-- whether a split occurred.
function split(t, can_split)
  local can_split = can_split == nil and true or can_split
  if type(t) == "number" then
    if can_split and t >= 10 then
      return {math.floor(t / 2), math.ceil(t / 2)}, true
    else
      return t, false
    end
  end
  local left, has_split_left = split(t[1], can_split)
  local right, has_split_right = split(t[2], not has_split_left and can_split)
  return {left, right}, (has_split_left or has_split_right)
end

function score(t)
  return type(t) == "number" and t or score(t[1]) * 3 + score(t[2]) * 2
end

function add(a,b)
  local new = {a,b}
  local continue = true
  while continue do
    new, _, _, continue = explode(new)
    if not continue then new, continue = split(new) end
  end
  return new
end

list = {}
for line in io.lines() do table.insert(list, parse(line)) end

pair = nil
for _, line in ipairs(list) do pair = not pair and line or add(pair, line) end
print(score(pair))

max = math.mininteger
for i = 1, #list do
  for j = 1, #list do
    max = math.max(max, score(add(list[i], list[j])))
  end
end
print(max)
