import gleam/int
import gleam/list
import gleam/pair
import gleam/string

type Point =
  #(Int, Int)

fn parse_input(input: String) -> List(Point) {
  input
  |> string.split("\n")
  |> list.map(fn(line) {
    let assert [Ok(x), Ok(y)] = line |> string.split(",") |> list.map(int.parse)
    #(x, y)
  })
}

fn area(a: Point, b: Point) -> Int {
  { int.absolute_value(a.0 - b.0) + 1 } * { int.absolute_value(a.1 - b.1) + 1 }
}

pub fn part1(input: String) -> Int {
  input
  |> parse_input
  |> list.fold(#(0, []), fn(acc, point) {
    let #(max_area, prev_points) = acc
    let new_max =
      list.fold(prev_points, max_area, fn(acc, p) {
        int.max(acc, area(point, p))
      })
    #(new_max, [point, ..prev_points])
  })
  |> pair.first
}
