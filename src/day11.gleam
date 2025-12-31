import gleam/dict.{type Dict}
import gleam/int
import gleam/list
import gleam/option
import gleam/result
import gleam/string

fn parse_input(input: String) -> Dict(String, List(String)) {
  input
  |> string.split("\n")
  |> list.map(fn(line) {
    let assert Ok(#(src, dst_strs)) = string.split_once(line, ": ")
    #(src, string.split(dst_strs, " "))
  })
  |> dict.from_list
}

fn list_filter_not(items: List(a), pred: fn(a) -> Bool) -> List(a) {
  items |> list.filter(fn(item) { !pred(item) })
}

fn find_incoming_counts(
  graph: Dict(String, List(String)),
  open: List(String),
  incoming_counts: Dict(String, Int),
) -> Dict(String, Int) {
  case open {
    [] -> incoming_counts
    [node, ..nodes] -> {
      let neighbors = graph |> dict.get(node) |> result.unwrap([])
      let new_incoming_counts =
        list.fold(neighbors, incoming_counts, fn(counts, neighbor) {
          dict.upsert(counts, neighbor, fn(existing) {
            option.unwrap(existing, 0) + 1
          })
        })
      let new_open =
        neighbors
        |> list_filter_not(dict.has_key(incoming_counts, _))
        |> list.append(nodes)
      find_incoming_counts(graph, new_open, new_incoming_counts)
    }
  }
}

// kahn's algorithm
fn find_path_counts(
  graph: Dict(String, List(String)),
  reverse_graph: Dict(String, List(String)),
  incoming_counts: Dict(String, Int),
  open: List(String),
  path_counts: Dict(String, Int),
) -> Dict(String, Int) {
  case open {
    [] -> path_counts
    [node, ..nodes] -> {
      let node_path_count = case dict.get(reverse_graph, node) {
        Error(Nil) -> 1
        Ok(parents) ->
          parents |> list.filter_map(dict.get(path_counts, _)) |> int.sum
      }
      let new_path_counts = dict.insert(path_counts, node, node_path_count)
      let #(new_open, new_incoming_counts) =
        graph
        |> dict.get(node)
        |> result.unwrap([])
        |> list.fold(#(nodes, incoming_counts), fn(acc, neighbor) {
          let #(open_acc, counts_acc) = acc
          let assert Ok(count) = dict.get(counts_acc, neighbor)
          case count {
            1 -> #([neighbor, ..open_acc], dict.delete(counts_acc, neighbor))
            _ -> #(open_acc, dict.insert(counts_acc, neighbor, count - 1))
          }
        })
      find_path_counts(
        graph,
        reverse_graph,
        new_incoming_counts,
        new_open,
        new_path_counts,
      )
    }
  }
}

fn solve1(graph: Dict(String, List(String))) -> Int {
  let incoming_counts = find_incoming_counts(graph, ["you"], dict.new())
  let reverse_graph =
    dict.fold(graph, dict.new(), fn(acc, node, neighbors) {
      list.fold(neighbors, acc, fn(acc, neighbor) {
        dict.upsert(acc, neighbor, fn(existing) {
          [node, ..option.unwrap(existing, [])]
        })
      })
    })
    |> dict.delete("you")
    |> dict.map_values(fn(_, neighbors) {
      neighbors
      |> list.filter(fn(n) { n == "you" || dict.has_key(incoming_counts, n) })
    })
  let path_counts =
    find_path_counts(graph, reverse_graph, incoming_counts, ["you"], dict.new())
  let assert Ok(result) = dict.get(path_counts, "out")
  result
}

pub fn part1(input: String) -> Int {
  input |> parse_input |> solve1
}
