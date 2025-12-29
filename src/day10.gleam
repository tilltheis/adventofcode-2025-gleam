import gleam/bool
import gleam/int
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/order.{type Order}
import gleam/pair
import gleam/regexp.{Match}
import gleam/result
import gleam/set.{type Set}
import gleam/string

type Machine {
  Machine(
    target_indicators: List(Bool),
    target_joltages: List(Int),
    buttons: List(List(Int)),
  )
}

fn parse_input(input: String) -> List(Machine) {
  input
  |> string.split("\n")
  |> list.fold([], fn(machines, line) {
    let assert Ok(line_re) = regexp.from_string("\\[(.+)\\] (.+) \\{(.+)\\}")
    let assert [
      Match(_, [Some(indicators_str), Some(buttons_str), Some(joltages_str)]),
    ] = regexp.scan(line_re, line)
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
    let assert Ok(joltages) =
      joltages_str |> string.split(",") |> list.map(int.parse) |> result.all
    [Machine(indicators, joltages, buttons), ..machines]
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

fn list_sort_comparing(
  list: List(a),
  by compare: fn(b, b) -> Order,
  comparing f: fn(a) -> b,
) -> List(a) {
  list.sort(list, fn(a, b) { compare(f(a), f(b)) })
}

fn list_zip_with(xs: List(a), ys: List(b), f: fn(a, b) -> c) -> List(c) {
  list_zip_with_helper(xs, ys, f, [])
}

fn list_zip_with_helper(
  xs: List(a),
  ys: List(b),
  f: fn(a, b) -> c,
  acc: List(c),
) -> List(c) {
  case xs, ys {
    [], _ -> list.reverse(acc)
    _, [] -> list.reverse(acc)
    [x, ..xs], [y, ..ys] -> list_zip_with_helper(xs, ys, f, [f(x, y), ..acc])
  }
}

// Representing equations as (coefficients, b) for equation coefficients * x = b
type LinearSystem =
  List(#(List(Int), Int))

// Representing terms as (coefficients, constant term)
type Term =
  #(List(Int), Int)

type TermOrConstant {
  Term(Term)
  Constant(Int)
}

fn machine_to_linear_system(machine: Machine) -> LinearSystem {
  list.index_fold(machine.target_joltages, [], fn(rows, target, index) {
    let a =
      machine.buttons
      |> list.fold([], fn(row, button) {
        case list.contains(button, index) {
          True -> [1, ..row]
          False -> [0, ..row]
        }
      })
      |> list.reverse
    [#(a, target), ..rows]
  })
}

fn gcd(a: Int, b: Int) -> Int {
  case b {
    0 -> int.absolute_value(a)
    _ -> gcd(b, a % b)
  }
}

fn to_echelon_form(equations: LinearSystem) -> LinearSystem {
  let equations =
    list_sort_comparing(equations, by: int.compare, comparing: fn(x) {
      x
      |> pair.first
      |> list.first
      |> result.unwrap(-1)
      |> int.absolute_value
      |> int.negate
    })
  case equations {
    [] -> []
    [#([], _), ..] -> []
    [#([0, ..], _), ..] -> {
      let rests =
        list.map(equations, fn(eq) {
          case eq {
            #([], _) -> panic
            #([_, ..xs], b) -> #(xs, b)
          }
        })
      to_echelon_form(rests)
      |> list.map(fn(eq) { #(list.prepend(eq.0, 0), eq.1) })
    }
    [#([pivot, ..pivots], pivot_b), ..eqs] -> {
      let rests =
        list.map(eqs, fn(eq) {
          case eq {
            #([], _) -> panic
            #([x, ..xs], b) -> {
              let gcd = gcd(int.absolute_value(pivot), int.absolute_value(x))
              let x_factor = pivot / gcd
              let factor = -x / gcd
              let new_xs =
                list_zip_with(xs, pivots, fn(a, b) { a * x_factor + b * factor })
              #(new_xs, b * x_factor + pivot_b * factor)
            }
          }
        })
      let echelon_rests =
        to_echelon_form(rests)
        |> list.map(fn(eq) { #(list.prepend(eq.0, 0), eq.1) })
      [#([pivot, ..pivots], pivot_b), ..echelon_rests]
    }
  }
}

// equations must be in echelon form
fn resolve_parameters(
  equations: LinearSystem,
  max_n: Int,
  n: Int,
) -> List(Option(Term)) {
  case equations {
    [] -> list.repeat(None, max_n - n)
    [#(coeffs, b), ..eqs] -> {
      case coeffs |> list.drop(n) |> list.first() {
        Ok(0) -> [None, ..resolve_parameters(equations, max_n, n + 1)]
        Ok(_) -> [Some(#(coeffs, b)), ..resolve_parameters(eqs, max_n, n + 1)]
        _ -> panic
      }
    }
  }
}

fn rsolve(
  open: List(TermOrConstant),
  rclosed: List(Int),
) -> Result(List(Int), Nil) {
  case open {
    [] -> Ok(list.reverse(rclosed))
    [Constant(k), ..ps] -> rsolve(ps, list.append(rclosed, [k]))
    [Term(#(coeffs, b)), ..ps] -> {
      let assert #(_, [factor, ..coeffs]) =
        list.split_while(coeffs, fn(c) { c == 0 })
      let k =
        list_zip_with(list.reverse(coeffs), rclosed, fn(c, k) { -c * k })
        |> list_sum
      case { k + b } % factor == 0 {
        True -> {
          let result = { k + b } / factor
          case result >= 0 {
            True -> rsolve(ps, list.append(rclosed, [result]))
            False -> Error(Nil)
          }
        }
        False -> Error(Nil)
      }
    }
  }
}

fn find_valid_solutions(
  open: List(Option(Term)),
  closed: List(TermOrConstant),
  max_value: Int,
) -> List(List(Int)) {
  case open {
    [] ->
      case rsolve(closed, []) {
        Ok(solution) -> [solution]
        Error(Nil) -> []
      }
    [Some(term), ..ps] ->
      find_valid_solutions(ps, [Term(term), ..closed], max_value)
    [None, ..ps] ->
      list.flat_map(list.range(0, max_value), fn(n) {
        find_valid_solutions(ps, [Constant(n), ..closed], max_value)
      })
  }
}

fn solve2(machine: Machine) -> Int {
  let assert Ok(max_value) = list.max(machine.target_joltages, int.compare)
  let assert Ok(result) =
    machine
    |> machine_to_linear_system
    |> to_echelon_form
    |> resolve_parameters(list.length(machine.buttons), 0)
    |> find_valid_solutions([], max_value)
    |> list.map(list_sum)
    |> list.sort(int.compare)
    |> list.first
  result
}

pub fn part2(input: String) -> Int {
  input |> parse_input |> list.map(solve2) |> list_sum
}
