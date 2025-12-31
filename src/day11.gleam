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
        |> list.filter(fn(x) { !dict.has_key(incoming_counts, x) })
        |> list.append(nodes)
      find_incoming_counts(graph, new_open, new_incoming_counts)
    }
  }
}

type NodeInfo {
  NodeInfo(path_count: Int, visited_nodes: List(String))
}

fn merge_valid_parents(parent_infos: List(NodeInfo)) -> Result(NodeInfo, Nil) {
  let with_required =
    list.drop_while(parent_infos, fn(info) { list.is_empty(info.visited_nodes) })

  case with_required {
    [] -> {
      let total_paths =
        parent_infos |> list.map(fn(info) { info.path_count }) |> int.sum
      Ok(NodeInfo(total_paths, []))
    }
    [first, ..rest] -> {
      let max_nodes =
        list.fold(rest, first.visited_nodes, fn(max, info) {
          case list.length(info.visited_nodes) > list.length(max) {
            True -> info.visited_nodes
            False -> max
          }
        })

      let all_compatible =
        list.all(with_required, fn(info) {
          list.all(info.visited_nodes, list.contains(max_nodes, _))
        })

      case all_compatible {
        False -> Error(Nil)
        True -> {
          let valid_parents =
            list.filter(with_required, fn(info) {
              info.visited_nodes == max_nodes
            })
          let total_paths =
            valid_parents |> list.map(fn(info) { info.path_count }) |> int.sum
          Ok(NodeInfo(total_paths, max_nodes))
        }
      }
    }
  }
}

fn compute_node_info(
  reverse_graph: Dict(String, List(String)),
  visited: Dict(String, NodeInfo),
  node: String,
  required_nodes: List(String),
) -> Result(NodeInfo, Nil) {
  let visited_prefix = case list.contains(required_nodes, node) {
    True -> [node]
    False -> []
  }

  case dict.get(reverse_graph, node) {
    Error(Nil) -> Ok(NodeInfo(1, visited_prefix))
    Ok(parents) -> {
      let parent_infos = parents |> list.filter_map(dict.get(visited, _))
      use parent_info <- result.try(merge_valid_parents(parent_infos))
      let merged_nodes =
        list.append(visited_prefix, parent_info.visited_nodes)
        |> list.unique
      Ok(NodeInfo(parent_info.path_count, merged_nodes))
    }
  }
}

fn update_neighbors(
  graph: Dict(String, List(String)),
  node: String,
  open: List(String),
  incoming_counts: Dict(String, Int),
) -> #(List(String), Dict(String, Int)) {
  graph
  |> dict.get(node)
  |> result.unwrap([])
  |> list.fold(#(open, incoming_counts), fn(acc, neighbor) {
    let #(open_acc, counts_acc) = acc
    let assert Ok(count) = dict.get(counts_acc, neighbor)
    case count {
      1 -> #([neighbor, ..open_acc], dict.delete(counts_acc, neighbor))
      _ -> #(open_acc, dict.insert(counts_acc, neighbor, count - 1))
    }
  })
}

// kahn's algorithm
fn find_path_counts(
  graph: Dict(String, List(String)),
  reverse_graph: Dict(String, List(String)),
  incoming_counts: Dict(String, Int),
  required_nodes: List(String),
  open: List(String),
  visited: Dict(String, NodeInfo),
) -> Dict(String, Int) {
  case open {
    [] -> visited |> dict.map_values(fn(_, info) { info.path_count })
    [node, ..rest] -> {
      case compute_node_info(reverse_graph, visited, node, required_nodes) {
        Error(Nil) -> {
          find_path_counts(
            graph,
            reverse_graph,
            incoming_counts,
            required_nodes,
            rest,
            visited,
          )
        }
        Ok(node_info) -> {
          let new_visited = dict.insert(visited, node, node_info)
          let #(new_open, new_incoming_counts) =
            update_neighbors(graph, node, rest, incoming_counts)
          find_path_counts(
            graph,
            reverse_graph,
            new_incoming_counts,
            required_nodes,
            new_open,
            new_visited,
          )
        }
      }
    }
  }
}

fn build_reverse_graph(
  graph: Dict(String, List(String)),
  source: String,
  incoming_counts: Dict(String, Int),
) -> Dict(String, List(String)) {
  dict.fold(graph, dict.new(), fn(acc, node, neighbors) {
    list.fold(neighbors, acc, fn(acc, neighbor) {
      dict.upsert(acc, neighbor, fn(existing) {
        [node, ..option.unwrap(existing, [])]
      })
    })
  })
  |> dict.delete(source)
  |> dict.map_values(fn(_, neighbors) {
    neighbors
    |> list.filter(fn(n) { n == source || dict.has_key(incoming_counts, n) })
  })
}

fn solve(
  graph: Dict(String, List(String)),
  source: String,
  required_nodes: List(String),
) -> Int {
  let incoming_counts = find_incoming_counts(graph, [source], dict.new())
  let reverse_graph = build_reverse_graph(graph, source, incoming_counts)
  let path_counts =
    find_path_counts(
      graph,
      reverse_graph,
      incoming_counts,
      required_nodes,
      [source],
      dict.new(),
    )
  let assert Ok(result) = dict.get(path_counts, "out")
  result
}

pub fn part1(input: String) -> Int {
  input |> parse_input |> solve("you", [])
}

pub fn part2(input: String) -> Int {
  input |> parse_input |> solve("svr", ["dac", "fft"])
}
