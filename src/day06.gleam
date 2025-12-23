import gleam/int
import gleam/list
import gleam/string

type Operation {
  Addition
  Multiplication
}

type Problem {
  Problem(operands: List(Int), operation: Operation)
}

fn solve(problems: List(Problem)) -> Int {
  problems
  |> list.map(fn(problem) {
    case problem {
      Problem(operands, Addition) ->
        operands |> list.fold(0, fn(acc, x) { acc + x })
      Problem(operands, Multiplication) ->
        operands |> list.fold(1, fn(acc, x) { acc * x })
    }
  })
  |> list.fold(0, fn(acc, x) { acc + x })
}

fn parse_row(row: List(String), operands: List(Int)) -> Problem {
  case row {
    [] -> panic
    ["+"] -> Problem(operands, Addition)
    ["*"] -> Problem(operands, Multiplication)
    [x] -> panic as { "Unknown operation: " <> x }
    [str, ..rest] -> {
      let assert Ok(operand) = int.parse(str)
      parse_row(rest, [operand, ..operands])
    }
  }
}

fn parse_input1(input: String) -> List(Problem) {
  input
  |> string.split("\n")
  |> list.map(fn(line) {
    line |> string.split(" ") |> list.filter(fn(s) { s != "" })
  })
  |> list.transpose
  |> list.map(parse_row(_, []))
}

pub fn part1(input: String) -> Int {
  input |> parse_input1 |> solve
}

fn list_split_last_helper(
  list: List(a),
  acc: List(a),
) -> Result(#(List(a), a), Nil) {
  case list {
    [] -> Error(Nil)
    [x] -> Ok(#(list.reverse(acc), x))
    [x, ..rest] -> list_split_last_helper(rest, [x, ..acc])
  }
}

fn list_split_last(list: List(a)) -> Result(#(List(a), a), Nil) {
  list_split_last_helper(list, [])
}

fn parse_input2(input: String) -> List(Problem) {
  let assert Ok(#(operands_lines, operations_line)) =
    input |> string.split("\n") |> list_split_last

  let operations =
    operations_line
    |> string.split("")
    |> list.filter_map(fn(str) {
      case str {
        "+" -> Ok(Addition)
        "*" -> Ok(Multiplication)
        _ -> Error(Nil)
      }
    })

  let operands =
    operands_lines
    |> list.map(string.split(_, ""))
    |> list.transpose
    |> list.map(fn(row) {
      row
      |> list.filter(fn(str) { str != " " })
    })
    |> list.map(fn(row) {
      list.fold(row, 0, fn(acc, str) {
        let assert Ok(n) = int.parse(str)
        acc * 10 + n
      })
    })
    |> list.chunk(fn(x) { x != 0 })
    |> list.filter(fn(chunk) { chunk != [0] })

  list.zip(operands, operations)
  |> list.map(fn(ops_and_op) {
    let #(ops, op) = ops_and_op
    Problem(ops, op)
  })
}

pub fn part2(input: String) -> Int {
  input |> parse_input2 |> solve
}
