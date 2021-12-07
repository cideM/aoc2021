-- score sums up the board fields that were never marked
function score(b)
  local sum = 0
  for _, row in ipairs(b) do
    for _, v in ipairs(row) do
      if not v.hit then
        sum = sum + v.num
      end
    end
  end
  return sum
end

function print_board(b)
  for _, row in ipairs(b) do
    for _, v in ipairs(row) do
      io.write(v.num, "\t", tostring(v.hit), "\t")
    end
    print("")
  end
end

-- is_complete checks if the board has at least one row or column where all
-- fields are marked
function is_complete(board)
  local cols = {[1] = true, [2] = true, [3] = true, [4] = true, [5] = true}

  for row_num, row in ipairs(board) do
    local row_is_done = true
    for i, v in ipairs(row) do
      if not v.hit then
        cols[i] = false
        row_is_done = false
      end
    end
    if row_is_done then
      return true
    end
  end

  for _, col in ipairs(cols) do
    if col then
      return true
    end
  end
end

function read()
  local numbers, boards = {}, {}
  local cur_board_num, cur_board_row = 0,0
  for line in io.input():lines("*l") do
    -- Start a new board
    if string.match(line, "^$") then
      cur_board_num = cur_board_num + 1
      cur_board_row = 0
    elseif string.find(line, ",") then
    -- First line has commas and contains the drawn numbers
      for d in string.gmatch(line, "%d+") do
        table.insert(numbers, tonumber(d))
      end
    else
      cur_board_row = cur_board_row + 1
      -- Make sure current board and row are always a table
      if not boards[cur_board_num] then
        boards[cur_board_num] = {}
      end
      b = boards[cur_board_num]
      if not b[cur_board_row] then
        b[cur_board_row] = {}
      end
      row = b[cur_board_row]

      for d in string.gmatch(line, "%d+") do
        table.insert(row, {num = tonumber(d), hit = false })
      end
    end
  end

  return boards, numbers
end

boards, numbers = read()
winners = {}
for _, d in ipairs(numbers) do
  for b_num, b in ipairs(boards) do
    -- Skip boards that are complete or else they will eventually end up with
    -- ALL fields marked and then you get a score of 0
    if not is_complete(b) then
      for row_num, row in ipairs(b) do
        for i, value in ipairs(row) do
          if d == value.num then
            boards[b_num][row_num][i].hit = true
          end
        end
      end
      if is_complete(b) then
        table.insert(winners, {board = b, num = d})
      end
    end
  end
end

print(score(winners[1].board) * winners[1].num)
print(score(winners[#winners].board) * winners[#winners].num)
