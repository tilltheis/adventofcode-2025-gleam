import day03

const input = "987654321111111
811111111111119
234234234234278
818181911112111"

pub fn day03_1_test() {
  assert day03.part1(input) == 357
}

pub fn day03_2_test() {
  assert day03.part2(input) == 3_121_910_778_619
}
