import gleam/int
import gleam/list.{Continue, Stop}
import gleam/option.{None, Some}
import gleam/set.{type Set}
import gleam/string

type Point =
  #(Int, Int, Int)

type ClosestPairing {
  ClosestPairing(a: Point, b: Point, squared_distance: Int)
}

fn parse_input(input: String) -> List(Point) {
  input
  |> string.split("\n")
  |> list.map(fn(line) {
    let assert [Ok(x), Ok(y), Ok(z)] =
      line |> string.split(",") |> list.map(int.parse)
    #(x, y, z)
  })
}

fn squared_distance(a: Point, b: Point) -> Int {
  { b.0 - a.0 }
  * { b.0 - a.0 }
  + { b.1 - a.1 }
  * { b.1 - a.1 }
  + { b.2 - a.2 }
  * { b.2 - a.2 }
}

fn insert_pairing_into_clusters(
  clusters: List(Set(Point)),
  pairing: ClosestPairing,
) -> List(Set(Point)) {
  insert_helper(clusters, [], set.new(), set.from_list([pairing.a, pairing.b]))
}

fn insert_helper(
  open_clusters: List(Set(Point)),
  closed_clusters: List(Set(Point)),
  matched_cluster: Set(Point),
  points: Set(Point),
) -> List(Set(Point)) {
  case open_clusters {
    [] -> [matched_cluster, ..closed_clusters]
    [cluster, ..clusters] -> {
      let intersection = set.intersection(points, cluster)
      case set.is_empty(intersection) {
        True ->
          insert_helper(
            clusters,
            [cluster, ..closed_clusters],
            matched_cluster,
            points,
          )
        False ->
          insert_helper(
            clusters,
            closed_clusters,
            set.union(matched_cluster, cluster),
            set.difference(points, intersection),
          )
      }
    }
  }
}

fn singleton_set(x: a) -> Set(a) {
  set.from_list([x])
}

fn sorted_pairings(points: List(Point)) -> List(ClosestPairing) {
  points
  |> list.combination_pairs
  |> list.map(fn(pair) {
    ClosestPairing(pair.0, pair.1, squared_distance(pair.0, pair.1))
  })
  |> list.sort(fn(a, b) { int.compare(a.squared_distance, b.squared_distance) })
}

pub fn solve1(input: String, limit: Int) -> Int {
  let points = input |> parse_input
  let initial_clusters = list.map(points, singleton_set)
  points
  |> sorted_pairings
  |> list.take(limit)
  |> list.fold(initial_clusters, insert_pairing_into_clusters)
  |> list.map(set.size)
  |> list.sort(fn(a, b) { int.compare(-a, -b) })
  |> list.take(3)
  |> list.fold(1, fn(acc, x) { acc * x })
}

pub fn part1(input: String) -> Int {
  solve1(input, 1000)
}

pub fn part2(input: String) -> Int {
  let points = input |> parse_input
  let initial_clusters = list.map(points, singleton_set)
  let assert #(_, Some(last_inserted_pairing)) =
    points
    |> sorted_pairings
    |> list.fold_until(#(initial_clusters, None), fn(acc, pairing) {
      let #(clusters, _) = acc
      let new_clusters = insert_pairing_into_clusters(clusters, pairing)
      case new_clusters {
        [_] -> Stop(#(new_clusters, Some(pairing)))
        _ -> Continue(#(new_clusters, Some(pairing)))
      }
    })

  last_inserted_pairing.a.0 * last_inserted_pairing.b.0
}
