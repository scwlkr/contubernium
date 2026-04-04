export type TranscriptEntry = {
  id: string
  kind: string
  tone: string
  actor: string
  title: string
  text: string
  highlight: string
  streaming?: boolean
  sourcePath?: string
}

export type TranscriptEvent = {
  kind: string
  tone: string
  actor: string
  title: string
  text: string
  highlight: string
}

type WrapPrefix = {
  indent: number
  marker?: string
}

type ListItem = {
  leadingSpaces: number
  marker: string
  text: string
}

const transcriptRightGutter = 2
const transcriptFallbackText = "..."
const transcriptThinkingText = "thinking..."
const transcriptVisiblePlaceholder = "..."

export function applyTimelineEvent(current: TranscriptEntry[], event: TranscriptEvent, stamp = Date.now()): TranscriptEntry[] {
  const actorLabel = event.actor || "runtime"
  const finalizedTitle = event.title || `${actorLabel} report`

  if (event.kind === "stream_start") {
    return [
      ...current,
      {
        id: `stream-${actorLabel}-${stamp}`,
        kind: event.kind,
        tone: "agent",
        actor: event.actor,
        title: `${actorLabel} thinking`,
        text: transcriptThinkingText,
        highlight: "plain",
        streaming: true,
      },
    ]
  }

  if (event.kind === "thinking_chunk" || event.kind === "stream_chunk") {
    return current
  }

  if (event.kind === "stream_finalize") {
    const targetIndex = [...current].reverse().findIndex((entry) => entry.streaming && entry.actor === event.actor)
    if (targetIndex >= 0) {
      const next = [...current]
      const resolvedIndex = next.length - 1 - targetIndex
      next[resolvedIndex] = {
        ...next[resolvedIndex],
        kind: event.kind,
        title: finalizedTitle,
        text: event.text,
        highlight: event.highlight || next[resolvedIndex].highlight,
        streaming: false,
      }
      return next
    }

    return [
      ...current,
      {
        id: `final-${actorLabel}-${stamp}`,
        kind: event.kind,
        tone: event.tone || "agent",
        actor: event.actor,
        title: finalizedTitle,
        text: event.text,
        highlight: event.highlight || "summary",
      },
    ]
  }

  return [
    ...current,
    {
      id: `${event.kind}-${stamp}-${current.length}`,
      kind: event.kind,
      tone: event.tone,
      actor: event.actor,
      title: event.title,
      text: event.text,
      highlight: event.highlight || "plain",
    },
  ]
}

export function formatTranscriptEntryLines(entry: Pick<TranscriptEntry, "text" | "highlight" | "streaming">, width: number): string[] {
  const body = entry.text || (entry.streaming ? transcriptThinkingText : transcriptFallbackText)
  if (entry.highlight === "json") {
    const normalized = normalizeNewlines(body)
    return normalized.length > 0 ? normalized.split("\n") : [transcriptVisiblePlaceholder]
  }
  return formatMarkdownLite(body, width)
}

export function formatMarkdownLite(text: string, width: number): string[] {
  const normalized = normalizeNewlines(text)
  const lines = normalized.split("\n")
  const rendered: string[] = []

  for (let index = 0; index < lines.length; ) {
    const line = lines[index]
    const trimmed = line.trim()

    if (!trimmed) {
      rendered.push("")
      index += 1
      continue
    }

    if (isFenceLine(trimmed)) {
      rendered.push(`  ${line}`)
      index += 1
      while (index < lines.length) {
        rendered.push(`  ${lines[index]}`)
        if (isFenceLine(lines[index].trim())) {
          index += 1
          break
        }
        index += 1
      }
      continue
    }

    const heading = parseHeading(trimmed)
    if (heading) {
      rendered.push(...wrapText(trimmed.slice(heading.length).trim(), width, { indent: 2, marker: heading }, { indent: 2 + heading.length }))
      index += 1
      continue
    }

    const listItem = parseListItem(line)
    if (listItem) {
      const flow = collectFlowText(lines, index + 1, listItem.text)
      rendered.push(
        ...wrapText(
          flow.text,
          width,
          { indent: 2 + listItem.leadingSpaces, marker: listItem.marker },
          { indent: 2 + listItem.leadingSpaces + listItem.marker.length },
        ),
      )
      index = flow.nextIndex
      continue
    }

    const flow = collectFlowText(lines, index + 1, line)
    rendered.push(...wrapText(flow.text, width, { indent: 2 }, { indent: 2 }))
    index = flow.nextIndex
  }

  return rendered.length > 0 ? rendered : [transcriptVisiblePlaceholder]
}

function normalizeNewlines(text: string): string {
  return text.replace(/\r\n/g, "\n").replace(/\r/g, "\n")
}

function collectFlowText(lines: string[], startIndex: number, initialLine: string): { text: string; nextIndex: number } {
  const parts = [initialLine.trim()].filter(Boolean)
  let index = startIndex

  while (index < lines.length) {
    const line = lines[index]
    const trimmed = line.trim()
    if (!trimmed) break
    if (isFenceLine(trimmed) || parseHeading(trimmed) || parseListItem(line)) break
    parts.push(trimmed)
    index += 1
  }

  return {
    text: parts.join(" "),
    nextIndex: index,
  }
}

function wrapText(text: string, width: number, firstPrefix: WrapPrefix, restPrefix: WrapPrefix): string[] {
  const rendered: string[] = []
  let remaining = text.trim()
  let prefix = firstPrefix

  if (!remaining) {
    rendered.push(renderLine("", firstPrefix))
    return rendered
  }

  while (remaining.length > 0) {
    const budget = wrapBudget(width, prefix)
    const end = wrappedLineEnd(remaining, budget)
    rendered.push(renderLine(remaining.slice(0, end).trimEnd(), prefix))
    remaining = remaining.slice(end).trimStart()
    prefix = restPrefix
  }

  return rendered
}

function renderLine(text: string, prefix: WrapPrefix): string {
  return `${" ".repeat(prefix.indent)}${prefix.marker ?? ""}${text}`
}

function wrapBudget(width: number, prefix: WrapPrefix): number {
  const available = Math.max(1, width - transcriptRightGutter)
  const prefixLength = prefix.indent + (prefix.marker?.length ?? 0)
  return Math.max(1, available - prefixLength)
}

function wrappedLineEnd(text: string, budget: number): number {
  if (text.length <= budget) return text.length

  let lastBreak = -1
  for (let index = 0; index < text.length && index < budget; index += 1) {
    if (/\s/.test(text[index])) lastBreak = index
  }
  if (lastBreak > 0) return lastBreak

  let cursor = budget
  while (cursor < text.length && !/\s/.test(text[cursor])) cursor += 1
  return cursor
}

function parseHeading(trimmed: string): string | null {
  const match = /^(#{1,6} )/.exec(trimmed)
  return match?.[1] ?? null
}

function parseListItem(line: string): ListItem | null {
  const orderedMatch = /^(\s*)(\d+\. )(.+)$/.exec(line)
  if (orderedMatch) {
    return {
      leadingSpaces: orderedMatch[1].length,
      marker: orderedMatch[2],
      text: orderedMatch[3],
    }
  }

  const unorderedMatch = /^(\s*)([-*+] )(.+)$/.exec(line)
  if (unorderedMatch) {
    return {
      leadingSpaces: unorderedMatch[1].length,
      marker: unorderedMatch[2],
      text: unorderedMatch[3],
    }
  }

  return null
}

function isFenceLine(trimmed: string): boolean {
  return trimmed.startsWith("```")
}
