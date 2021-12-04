require"lib"

boards, numbers = read()

for _, d in ipairs(numbers) do
  for b_num, b in ipairs(boards) do
    for row_num, row in ipairs(b) do
      for i, value in ipairs(row) do
        if d == value.num then
          boards[b_num][row_num][i].hit = true
        end
      end
    end
    if is_complete(b) then
      print("found winner, last number was:", d)
      print_board(b)
      print("score", score(b) * d)
      os.exit(0)
    end
  end
end
