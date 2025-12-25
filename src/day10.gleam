import gleam/bool
import gleam/int
import gleam/list
import gleam/option.{Some}
import gleam/regexp.{Match}
import gleam/result
import gleam/set.{type Set}
import gleam/string

type Machine {
  Machine(target_indicators: List(Bool), buttons: List(List(Int)))
}

fn parse_input(input: String) -> List(Machine) {
  input
  |> string.split("\n")
  |> list.fold([], fn(machines, line) {
    let assert Ok(line_re) = regexp.from_string("\\[(.+)\\] (.+) \\{(.+)\\}")
    let assert [Match(_, [Some(indicators_str), Some(buttons_str), Some(_)])] =
      regexp.scan(line_re, line)
    let indicators =
      indicators_str
      |> string.to_graphemes
      |> list.fold([], fn(acc, char) {
        case char {
          "#" -> [True, ..acc]
          _ -> [False, ..acc]
        }
      })
      |> list.reverse
    let assert Ok(buttons_re) = regexp.from_string("\\(([^)]+)\\)")
    let buttons =
      buttons_str
      |> regexp.scan(buttons_re, _)
      |> list.map(fn(match) {
        let assert [Some(button_str)] = match.submatches
        let assert Ok(button) =
          result.all(string.split(button_str, ",") |> list.map(int.parse))
        button
      })
    [Machine(indicators, buttons), ..machines]
  })
}

fn press_button(
  indicators: List(Bool),
  button: List(Int),
  index: Int,
) -> List(Bool) {
  case indicators, button {
    inds, [] -> inds
    [ind, ..inds], [btn, ..btns] if btn == index -> [
      bool.negate(ind),
      ..press_button(inds, btns, index + 1)
    ]
    [ind, ..inds], btns -> [ind, ..press_button(inds, btns, index + 1)]
    [], [_, ..] -> panic
  }
}

fn set_try_fold(xs: Set(a), z: b, f: fn(b, a) -> Result(b, c)) -> Result(b, c) {
  set.fold(xs, Ok(z), fn(acc, x) { result.try(acc, f(_, x)) })
}

fn bfs(
  target: List(Bool),
  buttons: List(List(Int)),
  open_searches: Set(List(Bool)),
  distance: Int,
) -> Int {
  let result =
    open_searches
    |> set_try_fold(set.new(), fn(acc, indicators) {
      buttons
      |> list.try_fold(set.new(), fn(processed, button) {
        let new_indicators = press_button(indicators, button, 0)
        case new_indicators == target {
          True -> Error(Nil)
          False -> Ok(set.insert(processed, new_indicators))
        }
      })
      |> result.map(set.union(acc, _))
    })

  case result {
    Ok(new_searches) -> bfs(target, buttons, new_searches, distance + 1)
    Error(_) -> distance
  }
}

fn set_singleton(x: a) -> Set(a) {
  set.from_list([x])
}

fn list_sum(xs: List(Int)) -> Int {
  list.fold(xs, 0, fn(acc, x) { acc + x })
}

fn solve(machine: Machine) -> Int {
  case list.all(machine.target_indicators, bool.negate) {
    True -> 0
    False ->
      bfs(
        machine.target_indicators,
        machine.buttons,
        machine.target_indicators |> list.map(fn(_) { False }) |> set_singleton,
        1,
      )
  }
}

pub fn part1(input: String) -> Int {
  input |> parse_input |> list.map(solve) |> list_sum
}
