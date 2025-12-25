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

fn solve(
  points: List(Point),
  update_max_area: fn(Int, Point, Point) -> Int,
) -> Int {
  points
  |> list.fold(#(0, []), fn(acc, point) {
    let #(max, prev_points) = acc
    let new_max =
      list.fold(prev_points, max, fn(acc, p) { update_max_area(acc, point, p) })
    #(new_max, [point, ..prev_points])
  })
  |> pair.first
}

pub fn part1(input: String) -> Int {
  solve(parse_input(input), fn(max, point, p) { int.max(max, area(point, p)) })
}

fn is_valid_rectangle(a: Point, b: Point, points: List(Point)) -> Bool {
  let x_min = int.min(a.0, b.0)
  let x_max = int.max(a.0, b.0)
  let y_min = int.min(a.1, b.1)
  let y_max = int.max(a.1, b.1)

  points
  |> list.window_by_2
  |> list.all(fn(pair) {
    let #(p1, p2) = pair
    let px_min = int.min(p1.0, p2.0)
    let px_max = int.max(p1.0, p2.0)
    let py_min = int.min(p1.1, p2.1)
    let py_max = int.max(p1.1, p2.1)

    case px_min < px_max {
      True ->
        px_max <= x_min || px_min >= x_max || py_max <= y_min || py_min >= y_max
      False ->
        py_max <= y_min || py_min >= y_max || px_max <= x_min || px_min >= x_max
    }
  })
}

pub fn part2(input: String) -> Int {
  let points = input |> parse_input
  let assert Ok(last) = list.last(points)
  let closed_polygon = [last, ..points]
  solve(points, fn(max, point, p) {
    let area = area(point, p)
    case area > max && is_valid_rectangle(point, p, closed_polygon) {
      True -> area
      False -> max
    }
  })
}
