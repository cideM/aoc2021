hex_to_binary = { ["0"] = "0000", ["1"] = "0001", ["2"] = "0010", ["3"] = "0011",
                  ["4"] = "0100", ["5"] = "0101", ["6"] = "0110", ["7"] = "0111",
                  ["8"] = "1000", ["9"] = "1001", ["A"] = "1010", ["B"] = "1011",
                  ["C"] = "1100", ["D"] = "1101", ["E"] = "1110", ["F"] = "1111", }

function parse_packet(s)
  local version, type_id, num_parsed = tonumber(s:sub(1,3), 2), tonumber(s:sub(4,6), 2), 6
  local packet = { version = version, type_id = type_id, number = nil, sub_packets = {} }

  if type_id == 4 then
    local groups, substr = {}, s:sub(7)
    for i = 1, #substr, 5 do
      table.insert(groups, substr:sub(i+1,i+4))
      if substr:sub(i,i) ~= "1" then
        packet.number = tonumber(table.concat(groups), 2)
        return packet, num_parsed + #groups * 5
      end
    end
  else
    num_parsed = num_parsed + 1
    if tonumber(s:sub(7,7), 2) == 0 then
      local length_in_bits, parsed = tonumber(s:sub(8,22), 2), 0
      num_parsed = num_parsed + 15

      while parsed < length_in_bits do
        local new_packet, new_parsed = parse_packet(s:sub(22 + parsed + 1))
        parsed = parsed + new_parsed
        table.insert(packet.sub_packets, new_packet)
      end

      return packet, num_parsed + parsed
    else
      local num_sub_packets, parsed = tonumber(s:sub(8,18), 2), 0
      num_parsed = num_parsed + 11

      while #packet.sub_packets < num_sub_packets do
        local new_packet, new_parsed = parse_packet(s:sub(18 + parsed + 1))
        parsed = parsed + new_parsed
        table.insert(packet.sub_packets, new_packet)
      end

      return packet, num_parsed + parsed
    end
  end
end

function score(p)
  if p.type_id == 0 then
    local sum = 0
    for _, sub in ipairs(p.sub_packets) do sum = sum + score(sub) end
    return sum
  elseif p.type_id == 1 then
    local sum = 1
    for _, sub in ipairs(p.sub_packets) do sum = sum * score(sub) end
    return sum
  elseif p.type_id == 2 then
    local sum = score(p.sub_packets[1])
    for _, sub in ipairs(p.sub_packets) do sum = math.min(sum, score(sub)) end
    return sum
  elseif p.type_id == 3 then
    local sum = score(p.sub_packets[1])
    for _, sub in ipairs(p.sub_packets) do sum = math.max(sum, score(sub)) end
    return sum
  elseif p.type_id == 4 then return p.number
  elseif p.type_id == 5 then return score(p.sub_packets[1]) > score(p.sub_packets[2]) and 1 or 0
  elseif p.type_id == 6 then return score(p.sub_packets[1]) < score(p.sub_packets[2]) and 1 or 0
  elseif p.type_id == 7 then return score(p.sub_packets[1]) == score(p.sub_packets[2]) and 1 or 0
  end
end

function score_version(p)
    local sum = p.version
    for _, sub in ipairs(p.sub_packets) do sum = sum + score_version(sub) end
    return sum
end

BINARY = {}
for c in string.gmatch(io.read("l"), ".") do table.insert(BINARY, hex_to_binary[c]) end

parsed = parse_packet(table.concat(BINARY))
print(score_version(parsed), score(parsed))
