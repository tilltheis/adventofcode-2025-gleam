import gleam/int
import gleam/list
import gleam/string

fn parse_input(input: String) -> List(Int) {
  input
  |> string.split(",")
  |> list.flat_map(fn(range) {
    let assert [Ok(from), Ok(to)] =
      range |> string.split("-") |> list.map(int.parse)
    list.range(from, to)
  })
}

fn is_invalid_id(id: Int) -> Bool {
  let str = int.to_string(id)
  let len = string.length(str)
  let half = string.slice(str, 0, len / 2)
  half <> half == str
}

pub fn part1(input: String) -> Int {
  input
  |> parse_input
  |> list.filter(is_invalid_id)
  |> list.fold(0, fn(acc, id) { acc + id })
}
