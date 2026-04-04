import type { TranscriptEntry } from "./transcript"

export type RuntimeLogFile = {
  events?: RuntimeLogRecord[]
}

export type RuntimeLogRecord = {
  timestamp?: string
  iteration?: number
  actor?: string
  lane?: string
  action?: string
  status?: string
  tool?: string
  summary?: string
  error_text?: string
}

export type RuntimeLogBridgeEvent = {
  kind: "run_log_event"
  tone: string
  actor: string
  title: string
  text: string
  highlight: string
  last_log_path: string
  iteration: number
  log_timestamp: string
}

function runtimeLogTone(status: string | undefined): string {
  switch (status) {
    case "blocked":
    case "error":
      return "danger"
    case "success":
    case "complete":
      return "success"
    case "requested":
    case "captured":
      return "tool"
    case "warning":
      return "warning"
    default:
      return "info"
  }
}

function runtimeLogTitle(event: RuntimeLogRecord): string {
  const action = event.action || "event"
  return event.lane ? `${action} • ${event.lane}` : action
}

function runtimeLogBody(event: RuntimeLogRecord): string {
  return [event.summary, event.tool ? `tool: ${event.tool}` : "", event.error_text ? `error: ${event.error_text}` : ""]
    .filter(Boolean)
    .join("\n")
}

function runtimeLogEntryId(
  actor: string,
  title: string,
  text: string,
  iteration: number,
  timestamp: string,
  fallbackIndex: number,
): string {
  return [
    `run-log`,
    timestamp || `no-ts-${fallbackIndex}`,
    String(iteration),
    actor || "runtime",
    title || "event",
    text || "empty",
  ].join("::")
}

export function runtimeLogEntryFromRecord(event: RuntimeLogRecord, index: number, sourcePath: string): TranscriptEntry {
  const actor = event.actor ?? ""
  const title = runtimeLogTitle(event)
  const text = runtimeLogBody(event)
  const iteration = event.iteration ?? 0
  const timestamp = event.timestamp ?? ""

  return {
    id: runtimeLogEntryId(actor, title, text, iteration, timestamp, index),
    kind: "run_log_event",
    tone: runtimeLogTone(event.status),
    actor,
    title,
    text,
    highlight: "plain",
    sourcePath,
  }
}

export function runtimeLogEntryFromBridgeEvent(event: RuntimeLogBridgeEvent): TranscriptEntry {
  return {
    id: runtimeLogEntryId(event.actor, event.title, event.text, event.iteration, event.log_timestamp, 0),
    kind: event.kind,
    tone: event.tone || "info",
    actor: event.actor,
    title: event.title,
    text: event.text,
    highlight: event.highlight || "plain",
    sourcePath: event.last_log_path,
  }
}

export function runtimeLogEntriesFromFile(log: RuntimeLogFile, sourcePath: string): TranscriptEntry[] {
  return (log.events ?? []).map((event, index) => runtimeLogEntryFromRecord(event, index, sourcePath))
}

export function mergeTranscriptEntries(base: TranscriptEntry[], incoming: TranscriptEntry[]): TranscriptEntry[] {
  const merged: TranscriptEntry[] = []
  const seen = new Set<string>()

  for (const entry of base) {
    if (seen.has(entry.id)) continue
    seen.add(entry.id)
    merged.push(entry)
  }

  for (const entry of incoming) {
    if (seen.has(entry.id)) continue
    seen.add(entry.id)
    merged.push(entry)
  }

  return merged
}
