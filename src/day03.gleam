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

fn max_joltage(bank: BitArray, required_battery_count: Int) -> Int {
  let byte_count = bit_array.byte_size(bank)
  assert byte_count >= required_battery_count
  let #(joltage, _) =
    list.range(byte_count - required_battery_count, byte_count - 1)
    |> list.fold(#(0, 0), fn(acc, end_index) {
      let #(joltage, start_index) = acc
      let assert Ok(#(n, i)) = max_battery(bank, start_index, end_index)
      #(joltage * 10 + n, i + 1)
    })
  joltage
}

fn solve(input: String, required_battery_count: Int) -> Int {
  input
  |> parse_input
  |> list.fold(0, fn(sum, row) {
    sum + max_joltage(row, required_battery_count)
  })
}

pub fn part1(input: String) -> Int {
  solve(input, 2)
}

pub fn part2(input: String) -> Int {
  solve(input, 12)
}
