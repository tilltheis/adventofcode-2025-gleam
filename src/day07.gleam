import gleam/dict.{type Dict}
import gleam/list
import gleam/option
import gleam/pair
import gleam/result
import gleam/set.{type Set}
import gleam/string

type Point =
  #(Int, Int)

type State {
  State(
    beams: Set(Int),
    splitters: Set(Point),
    dimensions: Dict(Int, Int),
    height: Int,
    split_count: Int,
  )
}

fn parse_input(input: String) -> State {
  input
  |> string.to_graphemes
  |> list.fold(
    #(#(0, 0), State(set.new(), set.new(), dict.new(), 1, 0)),
    fn(acc, char) {
      let #(#(x, y), state) = acc
      case char {
        "^" -> #(
          #(x + 1, y),
          State(..state, splitters: set.insert(state.splitters, #(x, y))),
        )
        "S" -> #(
          #(x + 1, y),
          State(
            ..state,
            beams: set.insert(state.beams, x),
            dimensions: dict.insert(state.dimensions, x, 1),
          ),
        )
        "\n" -> #(#(0, y + 1), State(..state, height: state.height + 1))
        _ -> #(#(x + 1, y), state)
      }
    },
  )
  |> pair.second
}

fn solve(input: String) -> State {
  let state = input |> parse_input
  list.range(0, state.height - 1)
  |> list.fold(state, fn(state, y) {
    let #(new_beams, new_dimensions, split_count_delta) =
      set.fold(state.beams, #(set.new(), dict.new(), 0), fn(acc, x) {
        let #(beams_acc, dimensions_acc, split_count_acc) = acc
        let dimension_count = result.unwrap(dict.get(state.dimensions, x), 0)
        let add_dimension_count = fn(dict: Dict(Int, Int), key: Int) {
          dict.upsert(dict, key, fn(maybe_count) {
            option.unwrap(maybe_count, 0) + dimension_count
          })
        }
        case set.contains(state.splitters, #(x, y)) {
          True -> #(
            beams_acc |> set.insert(x - 1) |> set.insert(x + 1),
            dimensions_acc
              |> add_dimension_count(x - 1)
              |> add_dimension_count(x + 1),
            split_count_acc + 1,
          )
          False -> #(
            beams_acc |> set.insert(x),
            dimensions_acc |> add_dimension_count(x),
            split_count_acc,
          )
        }
      })
    let new_split_count = state.split_count + split_count_delta
    State(
      ..state,
      beams: new_beams,
      dimensions: new_dimensions,
      split_count: new_split_count,
    )
  })
}

pub fn part1(input: String) -> Int {
  input
  |> solve
  |> fn(state) { state.split_count }
}

pub fn part2(input: String) -> Int {
  input
  |> solve
  |> fn(state) { state.dimensions }
  |> dict.values
  |> list.fold(0, fn(acc, n) { acc + n })
}
