export function exit(code) {
  process.exit(code);
}

export function monotonic_time_millis() {
  return Number(process.hrtime.bigint() / 1_000_000n);
}