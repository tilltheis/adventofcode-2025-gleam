import day04

const input = "..@@.@@@@.
@@@.@.@.@@
@@@@@.@.@@
@.@@@@..@.
@@.@@@@.@@
.@@@@@@@.@
.@.@.@.@@@
@.@@@.@@@@
.@@@@@@@@.
@.@.@@@.@."

pub fn day04_1_test() {
  assert day04.part1(input) == 13
}

pub fn day04_2_test() {
  assert day04.part2(input) == 43
}
