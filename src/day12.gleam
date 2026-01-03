import gleam/function
import gleam/int
import gleam/list
import gleam/result
import gleam/string

type Shape =
  List(List(Bool))

type Region {
  Region(width: Int, height: Int, shape_counts: List(Int))
}

type Input {
  Input(shapes: List(Shape), regions: List(Region))
}

type Direction {
  Trailing
}

@external(erlang, "string", "split")
fn erl_split(
  string: String,
  substring: String,
  direction: Direction,
) -> List(String)

@external(javascript, "./ffi.mjs", "split_last")
fn string_split_last(
  string: String,
  on substring: String,
) -> Result(#(String, String), Nil) {
  case erl_split(string, substring, Trailing) {
    [init, last] -> Ok(#(init, last))
    _ -> Error(Nil)
  }
}

fn parse_input(input: String) -> Input {
  let assert Ok(#(shapes_str, regions_str)) =
    input
    |> string_split_last("\n\n")

  let shapes =
    shapes_str
    |> string.split("\n\n")
    |> list.map(fn(shape_str) {
      shape_str
      |> string.split("\n")
      |> list.rest
      |> result.unwrap([])
      |> list.map(fn(line) {
        line
        |> string.to_graphemes
        |> list.map(fn(c) {
          case c {
            "#" -> True
            "." -> False
            _ -> panic
          }
        })
      })
    })

  let regions =
    regions_str
    |> string.split("\n")
    |> list.map(fn(line) {
      let assert Ok(#(size_str, counts_str)) = string.split_once(line, ": ")
      let assert Ok(#(width_str, height_str)) = string.split_once(size_str, "x")
      let assert Ok(width) = int.parse(width_str)
      let assert Ok(height) = int.parse(height_str)
      let counts =
        counts_str
        |> string.split(" ")
        |> list.map(fn(count_str) {
          let assert Ok(count) = int.parse(count_str)
          count
        })
      Region(width, height, counts)
    })

  Input(shapes, regions)
}

fn solve(region: Region, shapes: List(Shape)) -> Bool {
  let required_cell_count =
    region.shape_counts
    |> list.zip(shapes)
    |> list.map(fn(tuple) {
      let #(count, shape) = tuple
      let covered_cell_count =
        shape |> list.flatten |> list.count(function.identity)
      count * covered_cell_count
    })
    |> int.sum

  required_cell_count <= region.width * region.height
}

pub fn part1(input: String) -> Int {
  let parsed = input |> parse_input
  parsed.regions
  |> list.map(solve(_, parsed.shapes))
  |> list.count(function.identity)
}
