CAVES = {}
for line in io.input():lines("*l") do
  local a,b = string.match(line,"([%a]+)%-([%a]+)")
  if not CAVES[a] then CAVES[a] = {} end
  if not CAVES[b] then CAVES[b] = {} end
  table.insert(CAVES[a], b)
  table.insert(CAVES[b], a)
end

function islower(s) return string.match(s,"^[a-z]+$") end

-- revisited checks if the list "l" includes any lower case character
-- twice
function revisited(l)
  seen = {}
  for _, node in ipairs(l) do
    if seen[node] and islower(node) then return true end
    seen[node] = true
  end
  return false
end

-- ALLOW_REVISIT determines if we are allowed to revisit a lower case node once
ALLOW_REVISIT = false

-- go continues "oldpath" at all eligible neighbours of node "n"
function go(n, oldpath)
  local oldpathcopy = {}
  for k, v in pairs(oldpath) do; oldpathcopy[k] = v end
  table.insert(oldpathcopy, n)
  if n == "end" then return {oldpathcopy} end

  local paths = {}
  for _, node in pairs(CAVES[n]) do
    local seen = false; for _, v in ipairs(oldpath) do if v == node then seen = true end end

    if node ~= "start" and
       (not seen or not islower(node) or (ALLOW_REVISIT and not revisited(oldpathcopy))) then
      for _, newpath in ipairs(go(node, oldpathcopy)) do; table.insert(paths, newpath); end
    end
  end

  if #paths == 0 then return {oldpathcopy} else return paths end
end

goodpaths = 0
for _, path in ipairs(go("start", {})) do
  if path[#path] == "end" then; goodpaths = goodpaths + 1; end
end
print(goodpaths)

ALLOW_REVISIT = true
goodpaths = 0
for _, path in ipairs(go("start", {})) do
  if path[#path] == "end" then; goodpaths = goodpaths + 1; end
end
print(goodpaths)
