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

fn parse_input(input: String) -> List(Problem) {
  input
  |> string.split("\n")
  |> list.map(fn(line) {
    line |> string.split(" ") |> list.filter(fn(s) { s != "" })
  })
  |> list.transpose
  |> list.map(parse_row(_, []))
}

pub fn part1(input: String) -> Int {
  input
  |> parse_input
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
