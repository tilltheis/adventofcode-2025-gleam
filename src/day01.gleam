import gleam/int
import gleam/list
import gleam/string

type State {
  State(value: Int, zero_count: Int)
}

fn parse_input(input: String) -> List(Int) {
  input
  |> string.split("\n")
  |> list.map(fn(line) {
    case line |> string.first, line |> string.drop_start(1) |> int.parse {
      Ok("L"), Ok(distance) -> -distance
      Ok("R"), Ok(distance) -> distance
      _, _ -> panic as { "Invalid rotation: " <> line }
    }
  })
}

fn solve(input: String, count_zeroes: fn(State, Int) -> Int) -> Int {
  let rotations = parse_input(input)
  let state =
    list.fold(rotations, State(value: 50, zero_count: 0), fn(state, rotation) {
      let value = { state.value + rotation % 100 + 100 } % 100
      let zero_count = state.zero_count + count_zeroes(state, rotation)
      State(value:, zero_count:)
    })
  state.zero_count
}

pub fn part1(input: String) -> Int {
  solve(input, fn(state, rotation) {
    case { state.value + rotation } % 100 {
      0 -> 1
      _ -> 0
    }
  })
}

pub fn part2(input: String) -> Int {
  solve(input, fn(state, rotation) {
    let uncorrected_value = state.value + rotation
    case rotation >= 0 {
      True -> uncorrected_value / 100
      False if state.value == 0 -> -uncorrected_value / 100
      False -> -{ uncorrected_value - 100 } / 100
    }
  })
}
