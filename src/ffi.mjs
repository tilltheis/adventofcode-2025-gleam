import { Error, Ok } from '../gleam_stdlib/gleam.mjs';

export function exit(code) {
  process.exit(code);
}

export function monotonic_time_millis() {
  return Number(process.hrtime.bigint() / 1_000_000n);
}

export function split_last(haystack, needle) {
  const index = haystack.lastIndexOf(needle);
  if (index >= 0) {
    const before = haystack.slice(0, index);
    const after = haystack.slice(index + needle.length);
    return new Ok([before, after]);
  } else {
    return new Error(Nil);
  }
}