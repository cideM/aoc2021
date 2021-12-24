ROOM_SIZE = 4
CORRECT_ROOM = { A = 4, B = 6, C = 8, D = 10 }
CORRECT_ROOM_REVERSE = { [4] = "A", [6] = "B", [8] = "C", [10] = "D" }
COST_FACTORS = { A = 1, B = 10, C = 100, D = 1000 }

function makekey(x,y) return string.format("%d,%d",x,y) end

input = {}
io.read("l")
io.read("l")

for i = 3, 4 do
  a,b,c,d = string.match(io.read("l"), string.rep("(%u).", 4))
  input["4,"..i] = a; input["6,"..i] = b; input["8,"..i] = c; input["10,"..i] = d
end

function stringify(g)
  local buf = {g["4,3"] or ".", g["6,3"] or ".", g["8,3"] or ".", g["10,3"] or "."}
  for i = 2,12 do table.insert(buf, g[string.format("%d,%d",i,2)] or ".") end
  for i = 4, 2 + ROOM_SIZE do
    table.move(
      {g["4,"..i] or ".", g["6,"..i] or ".", g["8,"..i] or ".", g["10,"..i] or "."},
      1, 4, #buf + 1, buf
    )
  end
  return table.concat(buf)
end

function final_key()
  local game = {}
  for x = 4, 10, 2 do
    for y = 3, ROOM_SIZE + 2 do
      game[makekey(x,y)] = CORRECT_ROOM_REVERSE[x]
    end
  end
  return stringify(game)
end

function distance(x1,y1,x2,y2) return math.abs(x1 - x2) + math.abs(y1 - y2) end

function path(x,y,x2,y2)
  local steps = {}
  if y > 2 then for i = y - 1, 2, -1 do table.insert(steps, makekey(x,i)) end end
  if x2 > x then for i = x+1, x2 do table.insert(steps, makekey(i,2)) end end
  if x2 < x then for i = x-1, x2, -1 do table.insert(steps, makekey(i,2)) end end
  if y2 > 2 then for i = 3, y2 do table.insert(steps, makekey(x2,i)) end end
  return steps
end

function path_free(g, steps)
  for _, s in ipairs(steps) do if g[s] then return false end end
  return true
end

-- unkey reverses makekey
function unkey(s)
  local x,y = string.match(s,"(%d+),(%d+)")
  return tonumber(x), tonumber(y)
end

function get_possible_targets(g,x,y)
  local pod = g[makekey(x,y)]

  -- if we're already in a possible, final destination, stay there
  local should_stay = false
  if y > 2 and x == CORRECT_ROOM[pod] then
    should_stay = true
    for i = y, (2 + ROOM_SIZE) do if g[makekey(x,i)] ~= pod then should_stay = false end end
  end
  if should_stay then return {} end

  local maybe = {}
  for i = 3, (2 + ROOM_SIZE) do table.insert(maybe, makekey(CORRECT_ROOM[pod],i)) end
  if y > 2 then
    table.move({"2,2", "3,2", "5,2", "7,2", "9,2", "11,2", "12,2"}, 1, 7, #maybe + 1, maybe)
  end

  local final = {}
  for _, t in ipairs(maybe) do
    -- target is already occupied
    if g[t] then goto skip end

    -- target is self
    if t == pod then goto skip end

    -- path to target is blocked
    local x2,y2 = unkey(t)
    local steps = path(x,y,x2,y2)
    if not path_free(g,steps) then goto skip end

    -- if any possible location is a possible, final destination, return only
    -- that
    local is_final_location = false
    if y2 > 2 then
      is_final_location = true
      for i = y2 + 1, (2 + ROOM_SIZE) do
        if g[makekey(x2,i)] ~= pod then is_final_location = false end
      end
      if is_final_location then return {t} else goto skip end
    end

    table.insert(final, t)
    ::skip::
  end

  return final
end

function move(g,x,y,x2,y2)
  local new_g, from = {}, g[makekey(x,y)]
  for k,v in pairs(g) do new_g[k] = v end
  new_g[makekey(x2,y2)] = from; new_g[makekey(x,y)] = nil
  return new_g, #path(x,y,x2,y2) * COST_FACTORS[from]
end

function play(start, moves)
  local cost, game = 0, start
  for _, m in ipairs(moves) do
    local next_game, next_cost = move(game,m[1],m[2],m[3],m[4])
    cost = cost + next_cost; game = next_game
  end
  return game, cost
end

-- "neighbours" returns the game states we can transition to from the current
-- state. Try every possible move, although some obviously wasteful moves are
-- discarded by "get_possible_targets".
function neighbours(state)
  local moves = {}
  for k,v in pairs(state.game) do
    local x, y = unkey(k)
    local targets = get_possible_targets(state.game,x,y)
    if #targets > 0 then
      for _, t in ipairs(targets) do
        local x2,y2 = unkey(t)
        -- print("insert move",x,y,x2,y2)
        table.insert(moves, {x,y,x2,y2})
      end
    end
  end

  local next_states = {}
  for _, m in ipairs(moves) do
    local new_game, new_cost = play(state.game, {m})
    local new_state = { game = new_game, total = state.total + new_cost, cost = new_cost }
    local key = stringify(new_state.game)
    new_state.key = key
    table.insert(next_states, new_state)
  end
  return next_states
end

-- going from one game state (which amphipod is where) to another is done
-- through a move, which has a cost. We can use this to find the best path from
-- start to the final state (which is known in advance) through Dijkstra.
function dijkstra(game)
  -- holds the actual state values, other code should only reference this
  local all_states = {}
  local initial_state = { game = game, cost = 0, total = 0 }
  local initial_state_key = stringify(initial_state.game)
  initial_state.key = initial_state_key
  all_states[initial_state_key] = initial_state

  local queue = {initial_state_key}

  -- imagine this being a min heap where we pop off the first element
  local min_cost = function()
    local min, best, pos = math.maxinteger, "", 0
    for i, key in ipairs(queue) do
      local state = all_states[key]
      if state.total < min then min = state.total; best = key; pos = i end
    end
    table.remove(queue, pos)
    return best
  end

  -- search our not so min heap for a given key
  local has_key = function(key)
    for _, cur_key in ipairs(queue) do if cur_key == key then return true end end
  end

  local final = final_key()
  while #queue > 0 do
    local key = min_cost()
    local state = all_states[key]

    if key == final then goto done end

    local neighbours = neighbours(state)
    for _, neighbour in ipairs(neighbours) do
      if not all_states[neighbour.key] then
        all_states[neighbour.key] = neighbour
        table.insert(queue, neighbour.key)
      end

      if has_key(neighbour.key) then
        if neighbour.total < all_states[neighbour.key].total then
          all_states[neighbour.key].total = neighbour.total
        end
      end
    end
  end

  ::done::
  return all_states[final]
end

ROOM_SIZE = 2
final, games = dijkstra(input)
print(final.total)

ROOM_SIZE = 4
input["4,4"] = "D"; input["4,5"] = "D"; input["4,6"] = "C";
input["6,4"] = "C"; input["6,5"] = "B"; input["6,6"] = "D";
input["8,4"] = "B"; input["8,5"] = "A"; input["8,6"] = "B";
input["10,4"] = "A"; input["10,5"] = "C"; input["10,6"] = "B"

final, games = dijkstra(input)
print(final.total)
