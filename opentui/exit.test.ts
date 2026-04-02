import { expect, test } from "bun:test"

import { requestOpenTuiExit } from "./exit"

test("requestOpenTuiExit sends bridge exit before shutdown", () => {
  const calls: string[] = []
  const payloads: Array<Record<string, unknown>> = []

  requestOpenTuiExit(
    (payload) => {
      calls.push("send")
      payloads.push(payload)
    },
    (code) => {
      calls.push(`shutdown:${code}`)
    },
  )

  expect(calls).toEqual(["send", "shutdown:0"])
  expect(payloads).toEqual([{ type: "exit" }])
})
