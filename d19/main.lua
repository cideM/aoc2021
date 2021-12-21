function taxi_dist(p1,p2)
  return math.abs(p1.x - p2.x) + math.abs(p1.y - p2.y) + math.abs(p1.z - p2.z)
end

-- pointcoords is just a helper function
function pointcoords(p) return p.x, p.y, p.z end

function rotations(p)
  local x,y,z = pointcoords(p)
  return {{ x =  x, y =  y, z =  z, }, { x =  x, y = -z, z =  y, }, { x =  x, y = -y, z = -z, },
          { x =  x, y =  z, z = -y, }, { x = -y, y =  x, z =  z, }, { x =  z, y =  x, z =  y, },
          { x =  y, y =  x, z = -z, }, { x = -z, y =  x, z = -y, }, { x = -x, y = -y, z =  z, },
          { x = -x, y = -z, z = -y, }, { x = -x, y =  y, z = -z, }, { x = -x, y =  z, z =  y, },
          { x =  y, y = -x, z =  z, }, { x =  z, y = -x, z = -y, }, { x = -y, y = -x, z = -z, },
          { x = -z, y = -x, z =  y, }, { x = -z, y =  y, z =  x, }, { x =  y, y =  z, z =  x, },
          { x =  z, y = -y, z =  x, }, { x = -y, y = -z, z =  x, }, { x = -z, y = -y, z = -x, },
          { x = -y, y =  z, z = -x, }, { x =  z, y =  y, z = -x, }, { x =  y, y = -z, z = -x, }}
end

-- align compares the beacons from scanner_a against each rotation of all
-- beacons of scanner_b. It does this by checking if at least 12 points have
-- the same distance. If two scanners are not aligned, the differences between
-- their shared points will be all over the place. But as soon as you align the
-- two, the differences between the common points are suddenly all equal.
function align(scanner_a, scanner_b)
  for i = 1, 24 do
    local distances = {}
    for _, beacon_a in ipairs(scanner_a.beacons) do
      for _, rotations in ipairs(scanner_b.rotated_beacons) do
        local xa, ya, za = pointcoords(beacon_a)
        local xb, yb, zb = pointcoords(rotations[i])
        local dx, dy, dz = xa - xb, ya - yb, za - zb
        local key = string.format("%d,%d,%d", dx, dy, dz)

        distances[key] = (distances[key] or 1) + 1

        if distances[key] >= 12 then
          for j, rotations in ipairs(scanner_b.rotated_beacons) do
            local xb, yb, zb = rotations[i].x, rotations[i].y, rotations[i].z
            scanner_b.beacons[j] = { x = xb, y = yb, z = zb }
          end

          scanner_b.position = {
            x = scanner_a.position.x + dx,
            y = scanner_a.position.y + dy,
            z = scanner_a.position.z + dz
          }

          return scanner_b.position
        end
      end
    end
  end
end

-- Parse the input data and leave the scanner position undefined, except for
-- the first scanner which we set to a known origin after this block.
scanners = {}
for line in io.lines() do
  if string.match(line, "scanner") then
    table.insert(scanners, { beacons = {}, position = {}, rotated_beacons = {} })
  else
    local x,y,z = string.match(line, "(%-?%d+),(%-?%d+),(%-?%d+)")
    if x and y and z then
      x,y,z = tonumber(x),tonumber(y),tonumber(z)
      local point = { x = x, y = y, z = z }
      table.insert(scanners[#scanners].beacons, point)
      table.insert(scanners[#scanners].rotated_beacons, rotations(point))
    end
  end
end

scanners[1].position = { x = 0, y = 0, z = 0 }

checked = {scanners[1]}
queue = {}; for i = 2, #scanners do table.insert(queue, scanners[i]) end

-- Use checked scanners where we know the exact, absolute origin to align
-- unchecked ones. If we can't align a scanner, put it back in the queue. We
-- first need to align other scanners until we can tackle that one.
while #queue > 0 do
  local current = table.remove(queue, 1)
  for i, checked_scanner in ipairs(checked) do
    if align(checked_scanner, current) then
      table.insert(checked, current)
      goto continue
    elseif i == #checked then
      table.insert(queue, current)
    end
  end
  ::continue::
end

-- Resolve the relative beacon positions to their scanner origin. This gives us
-- the absolute beacon positions.
seen = {}
unique_beacons = 0
for _, scanner in ipairs(scanners) do
  for _, beacon in ipairs(scanner.beacons) do
    local x, y, z = pointcoords(beacon)
    local sx, sy, sz = pointcoords(scanner.position)
    local key = string.format("%d,%d,%d", x + sx, y + sy, z + sz)
    if not seen[key] then
      unique_beacons = unique_beacons + 1
      seen[key] = true
    end
  end
end

max = math.mininteger

for i = 1, #scanners do
  for j = 1, #scanners do
    max = math.max(max, taxi_dist(scanners[i].position, scanners[j].position))
  end
end

print(unique_beacons)
print(max)
