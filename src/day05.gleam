import gleam/int
import gleam/list
import gleam/string

type Range {
  Range(from: Int, to: Int)
}

fn range_inclusive(from: Int, to: Int) -> Result(Range, Nil) {
  case from > to {
    True -> Error(Nil)
    False -> Ok(Range(from, to))
  }
}

fn range_contains(range: Range, value: Int) -> Bool {
  range.from <= value && value <= range.to
}

fn range_length(range: Range) -> Int {
  range.to - range.from + 1
}

type State {
  State(ranges: List(Range), ids: List(Int))
}

fn parse_input(input: String) -> State {
  let assert Ok(#(ranges_string, ids_string)) =
    input |> string.split_once("\n\n")
  let ranges =
    ranges_string
    |> string.split("\n")
    |> list.map(fn(line) {
      let assert [Ok(from), Ok(to)] =
        line |> string.split("-") |> list.map(int.parse)
      let assert Ok(range) = range_inclusive(from, to)
      range
    })
  let ids =
    ids_string
    |> string.split("\n")
    |> list.map(fn(line) {
      let assert Ok(id) = int.parse(line)
      id
    })
  State(ranges, ids)
}

pub fn part1(input: String) -> Int {
  let State(ranges, ids) = parse_input(input)
  ids
  |> list.filter(fn(id) { list.any(ranges, range_contains(_, id)) })
  |> list.length
}

pub fn part2(input: String) -> Int {
  { input |> parse_input }.ranges
  |> list.sort(fn(lhs, rhs) { int.compare(lhs.from, rhs.from) })
  |> list.fold([], fn(distinct_ranges: List(Range), range) {
    case distinct_ranges {
      [] -> [range]
      [last_range, ..rest] ->
        case range.from <= last_range.to {
          True -> [
            Range(last_range.from, int.max(last_range.to, range.to)),
            ..rest
          ]
          False -> [range, last_range, ..rest]
        }
    }
  })
  |> list.fold(0, fn(sum, range) { sum + range_length(range) })
}
