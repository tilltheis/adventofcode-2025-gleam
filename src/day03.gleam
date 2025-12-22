import gleam/bit_array
import gleam/list
import gleam/string

fn parse_input(input: String) -> List(BitArray) {
  input
  |> string.split("\n")
  |> list.map(bit_array.from_string)
}

fn max_battery(
  bank: BitArray,
  start_index: Int,
  end_index: Int,
) -> Result(#(Int, Int), Nil) {
  list.range(start_index, end_index)
  |> list.fold(Error(Nil), fn(acc, index) {
    let assert Ok(<<byte:int>>) = bit_array.slice(bank, index, 1)
    case acc {
      Error(Nil) -> Ok(#(byte - 48, index))
      Ok(#(current_max, _)) if byte - 48 > current_max ->
        Ok(#(byte - 48, index))
      Ok(_) -> acc
    }
  })
}

fn max_joltage(bank: BitArray) -> Int {
  let byte_count = bit_array.byte_size(bank)
  assert byte_count >= 2
  let assert Ok(#(tens, i)) = max_battery(bank, 0, byte_count - 2)
  let assert Ok(#(ones, _)) = max_battery(bank, i + 1, byte_count - 1)
  tens * 10 + ones
}

pub fn part1(input: String) -> Int {
  input
  |> parse_input
  |> list.fold(0, fn(sum, row) { sum + max_joltage(row) })
}
