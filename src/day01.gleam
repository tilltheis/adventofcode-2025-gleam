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

fn solve1(rotations: List(Int)) -> Int {
  let state =
    list.fold(rotations, State(value: 50, zero_count: 0), fn(state, rotation) {
      let value = { { state.value + rotation } % 100 + 100 } % 100
      let zero_count = case value {
        0 -> state.zero_count + 1
        _ -> state.zero_count
      }
      State(value:, zero_count:)
    })
  state.zero_count
}

pub fn part1(input: String) -> Int {
  input |> parse_input |> solve1
}
