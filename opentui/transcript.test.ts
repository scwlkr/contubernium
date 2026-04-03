import { expect, test } from "bun:test"
import { applyTimelineEvent, formatMarkdownLite, formatTranscriptEntryLines } from "./transcript"

test("markdown-lite formatting preserves list indentation and fenced code at narrow widths", () => {
  const lines = formatMarkdownLite(
    "- Bullet item wraps across lines cleanly\n```sh\nbun test opentui\necho ok\n```",
    18,
  )

  expect(lines[0]).toBe("  - Bullet item")
  expect(lines[1]?.startsWith("    ")).toBe(true)
  expect(lines[2]?.startsWith("    ")).toBe(true)
  expect(lines[3]?.startsWith("    ")).toBe(true)
  expect(lines[4]).toBe("    cleanly")
  expect(lines.slice(5)).toEqual(["  ```sh", "  bun test opentui", "  echo ok", "  ```"])
})

test("stream_start placeholder is replaced by stream_finalize summary", () => {
  const started = applyTimelineEvent(
    [],
    {
      kind: "stream_start",
      tone: "agent",
      actor: "decanus",
      title: "",
      text: "",
      highlight: "plain",
    },
    1,
  )

  expect(started).toHaveLength(1)
  expect(started[0]?.text).toBe("thinking...")
  expect(started[0]?.streaming).toBe(true)

  const finalized = applyTimelineEvent(
    started,
    {
      kind: "stream_finalize",
      tone: "agent",
      actor: "decanus",
      title: "",
      text: "action: finish",
      highlight: "summary",
    },
    2,
  )

  expect(finalized).toHaveLength(1)
  expect(finalized[0]?.title).toBe("decanus report")
  expect(finalized[0]?.text).toBe("action: finish")
  expect(finalized[0]?.highlight).toBe("summary")
  expect(finalized[0]?.streaming).toBe(false)
})

test("raw thinking and content chunks do not append transcript card bodies", () => {
  const started = applyTimelineEvent(
    [],
    {
      kind: "stream_start",
      tone: "agent",
      actor: "faber",
      title: "",
      text: "",
      highlight: "plain",
    },
    1,
  )

  const afterThinking = applyTimelineEvent(
    started,
    {
      kind: "thinking_chunk",
      tone: "agent",
      actor: "faber",
      title: "",
      text: "raw model thought",
      highlight: "plain",
    },
    2,
  )
  const afterContent = applyTimelineEvent(
    afterThinking,
    {
      kind: "stream_chunk",
      tone: "agent",
      actor: "faber",
      title: "",
      text: "raw partial content",
      highlight: "plain",
    },
    3,
  )

  expect(afterContent).toHaveLength(1)
  expect(afterContent[0]?.text).toBe("thinking...")
  expect(afterContent[0]?.streaming).toBe(true)
})

test("json highlight entries render verbatim", () => {
  const lines = formatTranscriptEntryLines(
    {
      text: "{\n  \"action\": \"finish\"\n}",
      highlight: "json",
      streaming: false,
    },
    10,
  )

  expect(lines).toEqual(["{", "  \"action\": \"finish\"", "}"])
})
