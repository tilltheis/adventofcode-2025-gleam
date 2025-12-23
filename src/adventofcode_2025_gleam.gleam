import argv
import day01
import day02
import day03
import day04
import day05
import day06
import gleam/int
import gleam/io
import gleam/string
import simplifile

@external(erlang, "erlang", "halt")
@external(javascript, "./ffi.mjs", "exit")
fn exit(code: Int) -> Nil

type TimeUnit {
  Millisecond
}

@external(erlang, "erlang", "monotonic_time")
fn erlang_monotonic_time(unit: TimeUnit) -> Int

@external(javascript, "./ffi.mjs", "monotonic_time_millis")
fn monotonic_time_millis() -> Int {
  erlang_monotonic_time(Millisecond)
}

const exit_code_usage = 1

const exit_code_puzzle_not_found = 2

const exit_code_input_file_error = 3

fn usage() -> Nil {
  io.println_error("Usage: gleam run day part")
  io.println_error("Example: gleam run 1 1")
  exit(exit_code_usage)
}

fn puzzle_not_found() -> Nil {
  io.println_error("Puzzle not found.")
  exit(exit_code_puzzle_not_found)
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

fn run(day: String, solve: fn(String) -> Int) -> Nil {
  let input = day |> read_input
  let start_time = monotonic_time_millis()
  let solution = solve(input)
  let end_time = monotonic_time_millis()
  let duration = end_time - start_time
  io.println(
    int.to_string(solution) <> " (" <> int.to_string(duration) <> " ms)",
  )
}

pub fn main() -> Nil {
  case argv.load().arguments {
    ["1", "1"] -> run("01", day01.part1)
    ["1", "2"] -> run("01", day01.part2)
    ["2", "1"] -> run("02", day02.part1)
    ["2", "2"] -> run("02", day02.part2)
    ["3", "1"] -> run("03", day03.part1)
    ["3", "2"] -> run("03", day03.part2)
    ["4", "1"] -> run("04", day04.part1)
    ["4", "2"] -> run("04", day04.part2)
    ["5", "1"] -> run("05", day05.part1)
    ["5", "2"] -> run("05", day05.part2)
    ["6", "1"] -> run("06", day06.part1)
    [_, _] -> puzzle_not_found()
    _ -> usage()
  }
}
