import day05

const input = "3-5
10-14
16-20
12-18

1
5
8
11
17
32"

pub fn day05_1_test() {
  assert day05.part1(input) == 3
}

pub fn day05_2_test() {
  assert day05.part2(input) == 14
}
