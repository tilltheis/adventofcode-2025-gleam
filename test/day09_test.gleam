import day09

const input = "7,1
11,1
11,7
9,7
9,5
2,5
2,3
7,3"

pub fn day09_1_test() {
  assert day09.part1(input) == 50
}

pub fn day09_2_test() {
  assert day09.part2(input) == 24
}
