import { expect, test } from "bun:test"
import {
  mergeTranscriptEntries,
  runtimeLogEntriesFromFile,
  runtimeLogEntryFromBridgeEvent,
} from "./runtime-log"

test("runtime log file entries render with the same identity as bridge updates", () => {
  const fromFile = runtimeLogEntriesFromFile({
    events: [
      {
        timestamp: "2026-04-04T10:00:00Z",
        iteration: 3,
        actor: "decanus",
        lane: "command",
        action: "turn_started",
        status: "running",
        summary: "active goal",
      },
    ],
  }, ".contubernium/logs/run-1.json")

  const fromBridge = runtimeLogEntryFromBridgeEvent({
    kind: "run_log_event",
    tone: "info",
    actor: "decanus",
    title: "turn_started • command",
    text: "active goal",
    highlight: "plain",
    last_log_path: ".contubernium/logs/run-1.json",
    iteration: 3,
    log_timestamp: "2026-04-04T10:00:00Z",
  })

  expect(fromFile).toHaveLength(1)
  expect(fromFile[0]?.id).toBe(fromBridge.id)
  expect(fromFile[0]?.title).toBe("turn_started • command")
})

test("merging loaded and incremental runtime log entries avoids duplicates", () => {
  const loaded = runtimeLogEntriesFromFile({
    events: [
      {
        timestamp: "2026-04-04T10:00:00Z",
        iteration: 3,
        actor: "decanus",
        lane: "command",
        action: "turn_started",
        status: "running",
        summary: "active goal",
      },
    ],
  }, ".contubernium/logs/run-1.json")

  const merged = mergeTranscriptEntries(loaded, [
    runtimeLogEntryFromBridgeEvent({
      kind: "run_log_event",
      tone: "info",
      actor: "decanus",
      title: "turn_started • command",
      text: "active goal",
      highlight: "plain",
      last_log_path: ".contubernium/logs/run-1.json",
      iteration: 3,
      log_timestamp: "2026-04-04T10:00:00Z",
    }),
    runtimeLogEntryFromBridgeEvent({
      kind: "run_log_event",
      tone: "success",
      actor: "decanus",
      title: "tool_result • command",
      text: "tool: read_file",
      highlight: "plain",
      last_log_path: ".contubernium/logs/run-1.json",
      iteration: 3,
      log_timestamp: "2026-04-04T10:00:01Z",
    }),
  ])

  expect(merged).toHaveLength(2)
  expect(merged[0]?.title).toBe("turn_started • command")
  expect(merged[1]?.title).toBe("tool_result • command")
})
