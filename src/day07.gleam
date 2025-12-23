import gleam/list
import gleam/pair
import gleam/set.{type Set}
import gleam/string

type Point =
  #(Int, Int)

type State {
  State(beams: Set(Int), splitters: Set(Point), height: Int, split_count: Int)
}

fn parse_input(input: String) -> State {
  input
  |> string.to_graphemes
  |> list.fold(#(#(0, 0), State(set.new(), set.new(), 1, 0)), fn(acc, char) {
    let #(#(x, y), State(beams, splitters, height, split_count)) = acc
    case char {
      "^" -> #(
        #(x + 1, y),
        State(beams, set.insert(splitters, #(x, y)), height, split_count),
      )
      "S" -> #(
        #(x + 1, y),
        State(set.insert(beams, x), splitters, height, split_count),
      )
      "\n" -> #(#(0, y + 1), State(beams, splitters, height + 1, split_count))
      _ -> #(#(x + 1, y), State(beams, splitters, height, split_count))
    }
  })
  |> pair.second
}

pub fn part1(input: String) -> Int {
  let state = input |> parse_input
  list.range(0, state.height - 1)
  |> list.fold(state, fn(state, y) {
    let #(new_beams, split_count_delta) =
      set.fold(state.beams, #(set.new(), 0), fn(acc, x) {
        let #(beams_acc, split_count_acc) = acc
        case set.contains(state.splitters, #(x, y)) {
          True -> #(
            beams_acc |> set.insert(x - 1) |> set.insert(x + 1),
            split_count_acc + 1,
          )
          False -> #(beams_acc |> set.insert(x), split_count_acc)
        }
      })
    let new_split_count = state.split_count + split_count_delta
    State(new_beams, state.splitters, state.height, new_split_count)
  })
  |> fn(state) { state.split_count }
}
