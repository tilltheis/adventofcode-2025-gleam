import gleam/bit_array
import gleam/list
import gleam/result

type Grid {
  Grid(cells: BitArray, width: Int, height: Int)
}

const byte_at = 64

const byte_linefeed = 10

fn grid_from_string(str: String) -> Grid {
  let bytes = bit_array.from_string(str)
  let index_of_newline_result =
    list.range(0, bit_array.byte_size(bytes))
    |> list.try_each(fn(i) {
      let assert Ok(<<byte:int>>) = bit_array.slice(bytes, i, 1)
      case byte {
        b if b == byte_linefeed -> Error(i)
        _ -> Ok(Nil)
      }
    })
  let width = case index_of_newline_result {
    Ok(Nil) -> bit_array.byte_size(bytes)
    Error(i) -> i
  }
  let height = { bit_array.byte_size(bytes) + 1 } / { width + 1 }
  Grid(bytes, width, height)
}

fn grid_get(grid: Grid, x: Int, y: Int) -> Result(Int, Nil) {
  case x < 0 || x >= grid.width || y < 0 || y >= grid.height {
    True -> Error(Nil)
    False -> {
      let index = y * { grid.width + 1 } + x
      let assert Ok(<<byte:int>>) = bit_array.slice(grid.cells, index, 1)
      Ok(byte)
    }
  }
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

pub fn part1(input: String) -> Int {
  let grid = grid_from_string(input)
  list.range(0, grid.height - 1)
  |> list.flat_map(fn(y) {
    list.range(0, grid.width - 1)
    |> list.filter_map(fn(x) {
      case grid_get(grid, x, y) {
        Ok(byte) if byte == byte_at -> Ok(count_occupied_neighbors(grid, x, y))
        _ -> Error(Nil)
      }
    })
  })
  |> list.filter(fn(n) { n < 4 })
  |> list.length()
}
