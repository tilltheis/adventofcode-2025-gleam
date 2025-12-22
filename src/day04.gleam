import gleam/list
import gleam/result
import gleam/string
import iv.{type Array}

type Grid {
  Grid(cells: Array(Int), width: Int, height: Int)
}

const byte_linefeed = 10

const byte_dot = 46

const byte_at = 64

fn grid_from_string(str: String) -> Grid {
  let bytes =
    str
    |> string.to_utf_codepoints
    |> list.map(string.utf_codepoint_to_int)
    |> iv.from_list
  let index_of_newline_result = bytes |> iv.index_of(byte_linefeed)
  let width = result.unwrap(index_of_newline_result, iv.size(bytes))
  let height = { iv.size(bytes) + 1 } / { width + 1 }
  Grid(bytes, width, height)
}

fn grid_point_to_index(grid: Grid, x: Int, y: Int) -> Result(Int, Nil) {
  case x < 0 || x >= grid.width || y < 0 || y >= grid.height {
    True -> Error(Nil)
    False -> Ok(y * { grid.width + 1 } + x)
  }
}

fn grid_get(grid: Grid, x: Int, y: Int) -> Result(Int, Nil) {
  grid_point_to_index(grid, x, y) |> result.try(iv.get(grid.cells, _))
}

fn grid_set(grid: Grid, x: Int, y: Int, value: Int) -> Result(Grid, Nil) {
  grid_point_to_index(grid, x, y)
  |> result.try(iv.set(grid.cells, _, value))
  |> result.map(fn(cells) { Grid(cells, grid.width, grid.height) })
}

const deltas = [
  #(-1, -1),
  #(0, -1),
  #(1, -1),
  #(-1, 0),
  #(1, 0),
  #(-1, 1),
  #(0, 1),
  #(1, 1),
]

fn count_occupied_neighbors(grid: Grid, x: Int, y: Int) -> Int {
  deltas
  |> list.filter_map(fn(point) {
    grid_get(grid, x + point.0, y + point.1)
    |> result.try(fn(byte) {
      case byte == byte_at {
        True -> Ok(Nil)
        False -> Error(Nil)
      }
    })
  })
  |> list.length()
}

fn find_removable_points(grid: Grid) -> List(#(Int, Int)) {
  list.range(0, grid.height - 1)
  |> list.flat_map(fn(y) {
    list.range(0, grid.width - 1)
    |> list.filter_map(fn(x) {
      case grid_get(grid, x, y) {
        Ok(byte) if byte == byte_at ->
          case count_occupied_neighbors(grid, x, y) < 4 {
            True -> Ok(#(x, y))
            False -> Error(Nil)
          }
        _ -> Error(Nil)
      }
    })
  })
}

pub fn part1(input: String) -> Int {
  grid_from_string(input) |> find_removable_points |> list.length
}

fn fixpoint(x: a, f: fn(a) -> a) -> a {
  case f(x) {
    y if y == x -> y
    y -> fixpoint(y, f)
  }
}

type State {
  State(grid: Grid, removed_count: Int)
}

fn step(state: State) -> State {
  find_removable_points(state.grid)
  |> list.fold(state, fn(acc, point) {
    let assert Ok(new_grid) = grid_set(acc.grid, point.0, point.1, byte_dot)
    State(new_grid, acc.removed_count + 1)
  })
}

pub fn part2(input: String) -> Int {
  fixpoint(State(grid_from_string(input), 0), step).removed_count
}
