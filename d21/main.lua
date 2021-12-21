pos, t, dice, scores = {3,5}, 0, {}, {0,0}
for i = 1, 10000 do table.insert(dice, #dice + 1) end
while scores[1] < 1000 and scores[2] < 1000 do
  player = t % 2 == 0 and 1 or 2
  pos[player] = (pos[player] + dice[t*3+1] + dice[t*3+2] + dice[t*3+3] - 1) % 10 + 1
  scores[player], t = scores[player] + pos[player], t + 1
end
print(math.min(table.unpack(scores)) * t * 3)

rolls = {}
for r1 = 1, 3 do for r2 = 1, 3 do for r3 = 1, 3 do table.insert(rolls, r1 + r2 + r3) end end end

memo = {}
-- the extremely clever swapping is taken from 1/blob/master/day21/main.py
function play(p1, s1, p2, s2)
  local w1, w2 = 0,0
  for _, inc in ipairs(rolls) do
    local p1 = (p1 + inc - 1) % 10 + 1
    local s1 = s1  + p1
    if s1 >= 21 then w1 = w1 + 1
    else
      local key, morewins1, morewins2 = string.format("%d%d%d%d",p1, s1, p2, s2), nil, nil
      if memo[key] then morewins2, morewins1 = table.unpack(memo[key])
      else
        morewins2, morewins1 = play(p2, s2, p1, s1)
        memo[key] = {morewins2, morewins1}
      end
      w1, w2 = w1 + morewins1, w2 + morewins2
    end
  end
  return w1, w2
end
print(math.max(play(3,0,5,0)))
