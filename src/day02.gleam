import gleam/int
import gleam/list
import gleam/result
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

fn solve(input: String, is_invalid_id: fn(String, Int) -> Bool) -> Int {
  input
  |> parse_input
  |> list.filter(fn(id) {
    let str = int.to_string(id)
    is_invalid_id(str, string.length(str))
  })
  |> list.fold(0, fn(acc, id) { acc + id })
}

pub fn part1(input: String) -> Int {
  solve(input, fn(str: String, len: Int) {
    let half = string.slice(str, 0, len / 2)
    half <> half == str
  })
}

pub fn part2(input: String) -> Int {
  solve(input, fn(str: String, len: Int) {
    len > 1
    && list.range(1, len / 2)
    |> list.find(fn(n) {
      string.repeat(string.slice(str, 0, n), len / n) == str
    })
    |> result.is_ok
  })
}
