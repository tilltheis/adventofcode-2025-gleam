import day06

const input = "123 328  51 64 
 45 64  387 23 
  6 98  215 314
*   +   *   +"

pub fn day06_1_test() {
  assert day06.part1(input) == 4_277_556
}

pub fn day06_2_test() {
  assert day06.part2(input) == 3_263_827
}
