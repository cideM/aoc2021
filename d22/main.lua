-- commonrange returns you the common part of the ranges from "low" -> "high"
-- and from -> to. The function doesn't check if "low" is indeed less than
-- "high", for example.
function commonrange(low, high)
  return function (from, to)
    if to < low or from > high then return nil, nil end
    return math.max(low, from), math.min(high, to)
  end
end

-- common returns the common cube between "a" and "b"
function common(a,b)
  local x1a,x2a,y1a,y2a,z1a,z2a = a.x1,a.x2,a.y1,a.y2,a.z1,a.z2
  local x1b,x2b,y1b,y2b,z1b,z2b = b.x1,b.x2,b.y1,b.y2,b.z1,b.z2
  local x1,x2 = commonrange(x1a,x2a)(x1b,x2b)
  local y1,y2 = commonrange(y1a,y2a)(y1b,y2b)
  local z1,z2 = commonrange(z1a,z2a)(z1b,z2b)
  if x1 and y1 and z1 then return {x1=x1,x2=x2,y1=y1,y2=y2,z1=z1,z2=z2} end
end

-- count the cubes in a cuboid. This is almost like volume, but we need to
-- increase each range. It's easier to understand if you consider that the
-- volume of a cube where each axis goes from 0 to 0 is 0. But it still
-- contains a single cube.
function count(a) return (a.x2+1-a.x1) * (a.y2+1-a.y1) * (a.z2+1-a.z1) end

-- split splits cube "a" into pieces so it no longer overlaps with cube "b". It
-- returns the new cubes.
function split(a, b)
  x1a,x2a,y1a,y2a,z1a,z2a = a.x1,a.x2,a.y1,a.y2,a.z1,a.z2
  x1b,x2b,y1b,y2b,z1b,z2b = b.x1,b.x2,b.y1,b.y2,b.z1,b.z2

  -- The directions here describe the scene, when you're standing in front of
  -- the cubes, meaning the horizon is the x-axis, the z-axis is increasing
  -- towards you, and y-axis is just up and down. We first slice of the sides,
  -- then we slide of what's in front and behind of cube b, and finally we
  -- slice off the top and bottom chunks from the remaining block.
  local new_cubes = {}
  rightside_x1, rightside_x2 = commonrange(x2b+1, math.maxinteger)(x1a, x2a)
  if rightside_x1 then
    table.insert(new_cubes, {x1=rightside_x1,x2=rightside_x2,y1=y1a,y2=y2a,z1=z1a,z2=z2a})
  end

  leftside_x1, leftside_x2 = commonrange(math.mininteger, x1b-1)(x1a, x2a)
  if leftside_x1 then
    table.insert(new_cubes, {x1=leftside_x1,x2=leftside_x2,y1=y1a,y2=y2a,z1=z1a,z2=z2a})
  end

  -- these can be re-used so I'm just calling them (rem)aining_x*
  rem_x1, rem_x2 = commonrange(x1a,x2a)(x1b,x2b)
  here_z1, here_z2 = commonrange(z2b+1, math.maxinteger)(z1a, z2a)
  if rem_x1 and here_z1 then
    table.insert(new_cubes, {x1=rem_x1,x2=rem_x2,z1=here_z1,z2=here_z2,y1=y1a,y2=y2a})
  end

  other_z1, other_z2 = commonrange(math.mininteger, z1b-1)(z1a, z2a)
  if rem_x1 and other_z1 then
    table.insert(new_cubes, {x1=rem_x1,x2=rem_x2,z1=other_z1,z2=other_z2,y1=y1a,y2=y2a})
  end

  top_z1, top_z2 = commonrange(z1a, z2a)(z1b, z2b)
  top_y1, top_y2 = commonrange(y2b+1, math.maxinteger)(y1a,y2a)
  if rem_x1 and top_z1 and top_y1 then
    table.insert(new_cubes, {x1=rem_x1,x2=rem_x2,z1=top_z1,z2=top_z2,y1=top_y1,y2=top_y2})
  end

  bot_y1, bot_y2 = commonrange(math.mininteger, y1b-1)(y1a,y2a)
  if rem_x1 and top_z1 and bot_y1 then
    table.insert(new_cubes, {x1=rem_x1,x2=rem_x2,z1=top_z1,z2=top_z2,y1=bot_y1,y2=bot_y2})
  end

  return new_cubes
end

cuboids = {}
for line in io.lines() do
  x1,x2,y1,y2,z1,z2 = string.match(line, string.rep("(%-?%d+).-",6))
  x1,x2,y1,y2,z1,z2 = tonumber(x1),tonumber(x2),tonumber(y1),tonumber(y2),tonumber(z1),tonumber(z2)

  local current_cube, new_cuboids = {x1=x1,x2=x2,y1=y1,y2=y2,z1=z1,z2=z2}, {}

  for _, old_cube in ipairs(cuboids) do
    if not common(old_cube, current_cube) then table.insert(new_cuboids, old_cube)
    else
      local new_cubes = split(old_cube, current_cube)
      if #new_cubes > 0 then table.move(new_cubes, 1, #new_cubes, #new_cuboids + 1, new_cuboids) end
    end
  end

  if string.match(line, "on") then table.insert(new_cuboids, current_cube) end
  cuboids = new_cuboids
end

sum1,sum2,focus = 0, 0, {x1=-50,x2=50,y1=-50,y2=50,z1=-50,z2=50}
for _,c in pairs(cuboids) do
  sum2 = sum2 + count(c)
  local common = common(c, focus)
  if common then sum1 = sum1 + count(common) end
end
print(sum1,sum2)
