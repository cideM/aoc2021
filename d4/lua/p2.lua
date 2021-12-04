require"lib"

boards, numbers = read()

winner = {}

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
        winner = { board = b, num = d }
      end
    end
  end
end

print("last winner, last number was:", winner.num)
print_board(winner.board)
print("score", score(winner.board) * winner.num)
