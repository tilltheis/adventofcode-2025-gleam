import argv
import day01
import gleam/int
import gleam/io
import gleam/string
import simplifile

@external(erlang, "erlang", "halt")
fn exit(code: Int) -> Nil

const exit_code_usage = 1

const exit_code_puzzle_not_found = 2

const exit_code_input_file_error = 3

fn usage() -> Nil {
  io.println_error("Usage: gleam run day part")
  io.println_error("Example: gleam run 1 1")
  exit(exit_code_usage)
}

fn read_input(day: String) -> String {
  let path = "inputs/day" <> day <> ".txt"
  case simplifile.read(path) {
    Ok(content) -> string.trim(content)
    Error(error) -> {
      io.println_error(
        "Could not read input file: " <> simplifile.describe_error(error),
      )
      exit(exit_code_input_file_error)
      ""
    }
  }
}

pub fn main() -> Nil {
  case argv.load().arguments {
    ["1", "1"] ->
      io.println("01" |> read_input |> day01.part1 |> int.to_string())
    [_, _] -> {
      io.println_error("Puzzle not found.")
      exit(exit_code_puzzle_not_found)
    }
    _ -> usage()
  }
}
