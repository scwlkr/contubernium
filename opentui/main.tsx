#!/usr/bin/env bun

import { createCliRenderer, type SelectOption } from "@opentui/core"
import { createRoot, useKeyboard, useTerminalDimensions } from "@opentui/react"
import React, { useEffect, useMemo, useRef, useState } from "react"
import { readFile } from "node:fs/promises"
import { spawn, type ChildProcessWithoutNullStreams } from "node:child_process"
import path from "node:path"
import { requestOpenTuiExit } from "./exit"

type BridgeKind =
  | "log"
  | "stream_start"
  | "stream_chunk"
  | "stream_finalize"
  | "state_snapshot"
  | "approval_request"
  | "model_roster"

type BridgeEvent = {
  kind: BridgeKind
  tone: string
  actor: string
  title: string
  text: string
  highlight: string
  project_name: string
  provider_type: string
  model: string
  logs_dir: string
  approval_mode: string
  global_status: string
  runtime_status: string
  loop_status: string
  approval_status: string
  current_actor: string
  active_tool: string
  active_lane: string
  last_step_kind: string
  last_step_summary: string
  current_goal: string
  last_tool_result: string
  last_error: string
  last_log_path: string
  iteration: number
  max_iterations: number
  estimated_prompt_chars: number
  estimated_prompt_tokens: number
  context_window_tokens: number
  response_reserve_tokens: number
  remaining_context_tokens: number
  context_used_percent: number
  condensation_count: number
  condensed_history_events: number
}

type Snapshot = Omit<BridgeEvent, "kind" | "tone" | "actor" | "title" | "text" | "highlight">

type TimelineEntry = {
  id: string
  kind: BridgeKind | "local"
  tone: string
  actor: string
  title: string
  text: string
  streaming?: boolean
}

type PendingApproval = {
  toolName: string
  detail: string
}

type RuntimeLog = {
  events?: RuntimeLogEvent[]
}

type RuntimeLogEvent = {
  timestamp?: string
  actor?: string
  lane?: string
  action?: string
  status?: string
  tool?: string
  summary?: string
  error_text?: string
}

const palette = {
  shell: "#090a0d",
  panel: "#111112",
  panelAlt: "#171715",
  border: "#2f2c28",
  gold: "#c8a65a",
  ivory: "#e8dfd1",
  muted: "#8f877c",
  blue: "#5e95d8",
  bronze: "#d99152",
  success: "#8fd19a",
  danger: "#d47b72",
}

const projectCwd = process.env.CONTUBERNIUM_PROJECT_CWD || process.cwd()
const bridgeExe = process.env.CONTUBERNIUM_BRIDGE_EXE

function emptySnapshot(): Snapshot {
  return {
    project_name: "UNASSIGNED",
    provider_type: "",
    model: "",
    logs_dir: ".contubernium/logs",
    approval_mode: "",
    global_status: "idle",
    runtime_status: "idle",
    loop_status: "awaiting_initial_prompt",
    approval_status: "idle",
    current_actor: "decanus",
    active_tool: "",
    active_lane: "command",
    last_step_kind: "think",
    last_step_summary: "",
    current_goal: "",
    last_tool_result: "",
    last_error: "",
    last_log_path: "",
    iteration: 0,
    max_iterations: 24,
    estimated_prompt_chars: 0,
    estimated_prompt_tokens: 0,
    context_window_tokens: 32768,
    response_reserve_tokens: 4096,
    remaining_context_tokens: 28672,
    context_used_percent: 0,
    condensation_count: 0,
    condensed_history_events: 0,
  }
}

function toneColor(tone: string): string {
  switch (tone) {
    case "success":
      return palette.success
    case "danger":
      return palette.danger
    case "warning":
    case "tool":
      return palette.gold
    case "agent":
      return palette.blue
    case "mission":
      return palette.bronze
    default:
      return palette.ivory
  }
}

function entryTextColor(entry: TimelineEntry): string {
  if (entry.streaming) return palette.blue
  if (entry.tone === "mission") return palette.bronze
  return palette.ivory
}

function formatHeading(entry: TimelineEntry): string {
  if (entry.title) return entry.title
  if (entry.actor) return entry.actor
  switch (entry.kind) {
    case "approval_request":
      return "Approval Required"
    case "model_roster":
      return "Model Roster"
    case "local":
      return "OpenTUI"
    default:
      return "Runtime"
  }
}

function parseModels(text: string): string[] {
  return text
    .split("\n")
    .map((line) => line.trim())
    .filter(Boolean)
    .map((line) => {
      const closeIndex = line.indexOf("]")
      const remainder = closeIndex >= 0 ? line.slice(closeIndex + 1).trim() : line
      return remainder.replace(/\s+\(current\)$/, "")
    })
}

function resolveLogPath(candidate: string): string {
  return path.isAbsolute(candidate) ? candidate : path.join(projectCwd, candidate)
}

async function loadRuntimeLog(logPath: string): Promise<TimelineEntry[]> {
  if (!logPath || !logPath.endsWith(".json")) return []

  try {
    const raw = await readFile(resolveLogPath(logPath), "utf8")
    const parsed = JSON.parse(raw) as RuntimeLog
    return (parsed.events ?? []).map((event, index) => {
      const body = [event.summary, event.tool ? `tool: ${event.tool}` : "", event.error_text ? `error: ${event.error_text}` : ""]
        .filter(Boolean)
        .join("\n")
      return {
        id: `log-${index}-${event.timestamp ?? index}`,
        kind: "log",
        tone: event.status === "blocked" ? "danger" : event.status === "complete" ? "success" : "info",
        actor: event.actor ?? "",
        title: `${event.action ?? "event"}${event.lane ? ` • ${event.lane}` : ""}`,
        text: body,
      }
    })
  } catch (error) {
    return [
      {
        id: "log-load-error",
        kind: "local",
        tone: "danger",
        actor: "opentui",
        title: "Run Log Unavailable",
        text: error instanceof Error ? error.message : String(error),
      },
    ]
  }
}

function snapshotFromEvent(event: BridgeEvent, current: Snapshot): Snapshot {
  return {
    project_name: event.project_name || current.project_name,
    provider_type: event.provider_type || current.provider_type,
    model: event.model || current.model,
    logs_dir: event.logs_dir || current.logs_dir,
    approval_mode: event.approval_mode || current.approval_mode,
    global_status: event.global_status || current.global_status,
    runtime_status: event.runtime_status || current.runtime_status,
    loop_status: event.loop_status || current.loop_status,
    approval_status: event.approval_status || current.approval_status,
    current_actor: event.current_actor || current.current_actor,
    active_tool: event.active_tool,
    active_lane: event.active_lane || current.active_lane,
    last_step_kind: event.last_step_kind || current.last_step_kind,
    last_step_summary: event.last_step_summary || current.last_step_summary,
    current_goal: event.current_goal,
    last_tool_result: event.last_tool_result,
    last_error: event.last_error,
    last_log_path: event.last_log_path,
    iteration: event.iteration,
    max_iterations: event.max_iterations || current.max_iterations,
    estimated_prompt_chars: event.estimated_prompt_chars,
    estimated_prompt_tokens: event.estimated_prompt_tokens,
    context_window_tokens: event.context_window_tokens || current.context_window_tokens,
    response_reserve_tokens: event.response_reserve_tokens || current.response_reserve_tokens,
    remaining_context_tokens: event.remaining_context_tokens,
    context_used_percent: event.context_used_percent,
    condensation_count: event.condensation_count,
    condensed_history_events: event.condensed_history_events,
  }
}

function App() {
  const bridgeRef = useRef<ChildProcessWithoutNullStreams | null>(null)
  const stdoutBufferRef = useRef("")
  const [snapshot, setSnapshot] = useState<Snapshot>(emptySnapshot)
  const [timeline, setTimeline] = useState<TimelineEntry[]>([])
  const [logEntries, setLogEntries] = useState<TimelineEntry[]>([])
  const [composer, setComposer] = useState("")
  const [pendingApproval, setPendingApproval] = useState<PendingApproval | null>(null)
  const [models, setModels] = useState<string[]>([])
  const [activePane, setActivePane] = useState<"timeline" | "logs">("timeline")
  const [statusNote, setStatusNote] = useState("OpenTUI bridge idle")
  const { width } = useTerminalDimensions()

  const modelOptions: SelectOption[] = useMemo(
    () => models.map((model) => ({ name: model, value: model, description: model })),
    [models],
  )

  const sendBridge = (payload: Record<string, unknown>) => {
    bridgeRef.current?.stdin.write(`${JSON.stringify(payload)}\n`)
  }

  const cycleModel = (direction: "up" | "down") => {
    if (models.length === 0) {
      sendBridge({ type: "models" })
      setStatusNote("Model roster requested")
      return
    }

    const currentIndex = models.findIndex((model) => model === snapshot.model)
    const startIndex = currentIndex >= 0 ? currentIndex : 0
    const offset = direction === "up" ? -1 : 1
    const nextIndex = (startIndex + offset + models.length) % models.length
    const nextModel = models[nextIndex]

    sendBridge({ type: "set_model", model: nextModel })
    setStatusNote(`Requested model ${nextModel}`)
  }

  const appendLocalEntry = (title: string, text: string, tone = "info") => {
    setTimeline((current) => [
      ...current,
      {
        id: `local-${Date.now()}-${current.length}`,
        kind: "local",
        tone,
        actor: "opentui",
        title,
        text,
      },
    ])
  }

  useEffect(() => {
    if (!bridgeExe) {
      appendLocalEntry("Bridge Missing", "CONTUBERNIUM_BRIDGE_EXE was not provided by the CLI launcher.", "danger")
      return
    }

    const bridge = spawn(bridgeExe, ["ui-bridge"], {
      cwd: projectCwd,
      env: process.env,
      stdio: ["pipe", "pipe", "inherit"],
    })
    bridgeRef.current = bridge

    const handleEvent = async (event: BridgeEvent) => {
      if (event.kind === "state_snapshot") {
        setSnapshot((current) => snapshotFromEvent(event, current))
        if (event.last_log_path) {
          setLogEntries(await loadRuntimeLog(event.last_log_path))
        }
        return
      }

      if (event.kind === "approval_request") {
        setPendingApproval({ toolName: event.title, detail: event.text })
      }

      if (event.kind === "model_roster") {
        setModels(parseModels(event.text))
      }

      if (event.kind === "stream_start") {
        setTimeline((current) => [
          ...current,
          {
            id: `stream-${event.actor}-${Date.now()}`,
            kind: event.kind,
            tone: "agent",
            actor: event.actor,
            title: `${event.actor} thinking`,
            text: "",
            streaming: true,
          },
        ])
        return
      }

      if (event.kind === "stream_chunk") {
        setTimeline((current) => {
          const next = [...current]
          const target = [...next].reverse().find((entry) => entry.streaming && entry.actor === event.actor)
          if (target) {
            target.text += event.text
            return next
          }
          return [
            ...next,
            {
              id: `stream-${event.actor}-${Date.now()}`,
              kind: event.kind,
              tone: "agent",
              actor: event.actor,
              title: `${event.actor} thinking`,
              text: event.text,
              streaming: true,
            },
          ]
        })
        return
      }

      if (event.kind === "stream_finalize") {
        setTimeline((current) => {
          const next = [...current]
          const target = [...next].reverse().find((entry) => entry.streaming && entry.actor === event.actor)
          if (target) {
            target.streaming = false
            target.kind = event.kind
            target.text = event.text
            return next
          }
          return [
            ...next,
            {
              id: `final-${event.actor}-${Date.now()}`,
              kind: event.kind,
              tone: "agent",
              actor: event.actor,
              title: `${event.actor} report`,
              text: event.text,
            },
          ]
        })
        return
      }

      setTimeline((current) => [
        ...current,
        {
          id: `${event.kind}-${Date.now()}-${current.length}`,
          kind: event.kind,
          tone: event.tone,
          actor: event.actor,
          title: event.title,
          text: event.text,
        },
      ])
    }

    bridge.stdout.on("data", (chunk) => {
      stdoutBufferRef.current += chunk.toString("utf8")
      const lines = stdoutBufferRef.current.split("\n")
      stdoutBufferRef.current = lines.pop() ?? ""

      for (const line of lines) {
        const trimmed = line.trim()
        if (!trimmed) continue
        try {
          void handleEvent(JSON.parse(trimmed) as BridgeEvent)
        } catch (error) {
          appendLocalEntry("Bridge Decode Failed", error instanceof Error ? error.message : String(error), "danger")
        }
      }
    })

    bridge.on("exit", (code) => {
      setStatusNote(code === 0 ? "Bridge exited cleanly" : `Bridge exited with code ${code ?? "unknown"}`)
    })

    sendBridge({ type: "snapshot" })
    sendBridge({ type: "models" })

    return () => {
      try {
        sendBridge({ type: "exit" })
      } catch {}
      bridge.kill()
    }
  }, [])

  useEffect(() => {
    if (!snapshot.last_log_path) return
    const interval = setInterval(() => {
      void loadRuntimeLog(snapshot.last_log_path).then(setLogEntries)
    }, 1000)
    return () => clearInterval(interval)
  }, [snapshot.last_log_path])

  useKeyboard((key) => {
    if (pendingApproval) {
      if (key.ctrl && key.name === "a") {
        sendBridge({ type: "approval", approved: true })
        setPendingApproval(null)
      } else if (key.ctrl && key.name === "d") {
        sendBridge({ type: "approval", approved: false })
        setPendingApproval(null)
      }
      return
    }

    if (key.ctrl && key.name === "l") {
      setActivePane((current) => (current === "timeline" ? "logs" : "timeline"))
      return
    }
    if (key.name === "up") {
      cycleModel("up")
      return
    }
    if (key.name === "down") {
      cycleModel("down")
      return
    }
    if (key.ctrl && key.name === "r") {
      sendBridge({ type: "resume" })
      setStatusNote("Resume requested")
      return
    }
    if (key.ctrl && key.name === "d") {
      sendBridge({ type: "doctor" })
      setStatusNote("Doctor requested")
      return
    }
    if (key.ctrl && key.name === "m") {
      sendBridge({ type: "models" })
      setStatusNote("Model roster requested")
      return
    }
    if (key.ctrl && key.name === "c") {
      sendBridge({ type: "interrupt" })
      setStatusNote("Interrupt requested")
      return
    }
    if (key.name === "escape") {
      return requestOpenTuiExit(sendBridge, shutdown)
    }
  })

  const showRail = width >= 124
  const transcriptEntries = activePane === "timeline" ? timeline : logEntries
  const composerTrimmed = composer.trimStart()
  const composerLooksLikeCommand = composerTrimmed.startsWith("/")
  const composerTextColor =
    composerTrimmed.length === 0 ? palette.ivory : composerLooksLikeCommand ? palette.blue : palette.bronze
  const composerPlaceholderColor = composerLooksLikeCommand ? palette.blue : palette.muted

  const submitComposer = (value: string) => {
    const input = value.trim()
    if (!input) return

    if (!input.startsWith("/")) {
      sendBridge({ type: "mission", prompt: input })
      setTimeline((current) => [
        ...current,
        {
          id: `mission-${Date.now()}-${current.length}`,
          kind: "local",
          tone: "mission",
          actor: "user",
          title: "Mission",
          text: input,
        },
      ])
      setComposer("")
      return
    }

    const parts = input.slice(1).trim().split(/\s+/)
    const command = parts[0] ?? ""
    const remainder = input.slice(command.length + 2).trim()

    switch (command) {
      case "resume":
        sendBridge({ type: "resume" })
        setStatusNote("Resume requested")
        break
      case "doctor":
        sendBridge({ type: "doctor" })
        setStatusNote("Doctor requested")
        break
      case "models":
        sendBridge({ type: "models" })
        setStatusNote("Model roster requested")
        break
      case "model": {
        if (!remainder) {
          appendLocalEntry("Model Command", "usage: /model <n|name>", "danger")
          break
        }
        const index = Number(remainder)
        const resolved = Number.isInteger(index) && index > 0 ? models[index - 1] : remainder
        if (!resolved) {
          appendLocalEntry("Model Command", "model roster is empty; run /models first", "danger")
          break
        }
        sendBridge({ type: "set_model", model: resolved })
        setStatusNote(`Requested model ${resolved}`)
        break
      }
      case "interrupt":
        sendBridge({ type: "interrupt" })
        setStatusNote("Interrupt requested")
        break
      case "status":
        sendBridge({ type: "snapshot" })
        setStatusNote("Snapshot refreshed")
        break
      case "clear":
        setTimeline([])
        setStatusNote("OpenTUI transcript cleared")
        break
      case "exit":
      case "quit":
        return requestOpenTuiExit(sendBridge, shutdown)
      default:
        appendLocalEntry("Unknown Command", input, "danger")
        break
    }

    setComposer("")
  }

  return (
    <box
      style={{
        width: "100%",
        height: "100%",
        flexDirection: "column",
        backgroundColor: palette.shell,
        padding: 1,
        gap: 1,
      }}
    >
      <box
        style={{
          border: true,
          borderColor: palette.border,
          backgroundColor: palette.panel,
          paddingLeft: 1,
          paddingRight: 1,
          height: 3,
          alignItems: "center",
          justifyContent: "space-between",
          flexDirection: "row",
        }}
      >
        <text fg={palette.gold}>
          CONTUBERNIUM
          <span fg={palette.muted}> OPENTUI</span>
        </text>
        <text fg={palette.muted}>
          {snapshot.current_actor} • {snapshot.active_lane} • {snapshot.global_status}
        </text>
      </box>

      {timeline.length === 0 && !snapshot.current_goal ? (
        <box
          style={{
            border: true,
            borderColor: palette.border,
            backgroundColor: palette.panelAlt,
            padding: 2,
            minHeight: 10,
            justifyContent: "center",
            alignItems: "center",
          }}
        >
          <ascii-font text="CONTUBERNIUM" font="tiny" />
          <text fg={palette.gold}>OpenTUI command tent for the Zig runtime</text>
          <text fg={palette.muted}>Enter a mission below or use Up/Down, Ctrl+R, Ctrl+D, Ctrl+M.</text>
        </box>
      ) : null}

      <box style={{ flexDirection: showRail ? "row" : "column", flexGrow: 1, gap: 1 }}>
        <box
          title={activePane === "timeline" ? "Live Transcript" : "Structured Run Log"}
          style={{
            border: true,
            borderColor: palette.border,
            backgroundColor: palette.panel,
            flexGrow: 1,
            minHeight: 16,
          }}
        >
          <scrollbox
            focused
            style={{
              rootOptions: { backgroundColor: palette.panel },
              viewportOptions: { backgroundColor: palette.panel },
              contentOptions: { backgroundColor: palette.panel },
              scrollbarOptions: {
                showArrows: false,
                trackOptions: {
                  foregroundColor: palette.blue,
                  backgroundColor: palette.panelAlt,
                },
              },
            }}
          >
            {transcriptEntries.length === 0 ? (
              <box style={{ padding: 1 }}>
                <text fg={palette.muted}>No OpenTUI transcript yet.</text>
              </box>
            ) : (
              transcriptEntries.map((entry) => (
                <box
                  key={entry.id}
                  style={{
                    border: true,
                    borderColor: palette.border,
                    backgroundColor: palette.panelAlt,
                    marginBottom: 1,
                    padding: 1,
                    width: "100%",
                  }}
                >
                  <text fg={toneColor(entry.tone)}>
                    {formatHeading(entry)}
                    {entry.actor ? <span fg={palette.muted}> • {entry.actor}</span> : null}
                  </text>
                  <text fg={entryTextColor(entry)}>{entry.text || "…"}</text>
                </box>
              ))
            )}
          </scrollbox>
        </box>

        <box
          title="Runtime Rail"
          style={{
            border: true,
            borderColor: palette.border,
            backgroundColor: palette.panelAlt,
            width: showRail ? 38 : "100%",
            minHeight: 16,
            padding: 1,
            flexDirection: "column",
            gap: 1,
          }}
        >
          <text fg={palette.gold}>Mission</text>
          <text fg={snapshot.current_goal ? palette.ivory : palette.muted}>{snapshot.current_goal || "idle"}</text>

          <text fg={palette.gold}>Loop</text>
          <text fg={palette.ivory}>
            turn {snapshot.iteration}/{snapshot.max_iterations}
          </text>
          <text fg={palette.muted}>
            {snapshot.last_step_kind} • {snapshot.last_step_summary || "waiting"}
          </text>

          <text fg={palette.gold}>Budget</text>
          <text fg={snapshot.context_used_percent >= 85 ? palette.danger : palette.ivory}>
            {snapshot.estimated_prompt_tokens} tok • {snapshot.context_used_percent}% used
          </text>
          <text fg={palette.muted}>{snapshot.remaining_context_tokens} tokens left</text>

          <text fg={palette.gold}>Latest</text>
          <text fg={snapshot.last_tool_result ? palette.ivory : palette.muted}>
            {snapshot.last_tool_result || "none"}
          </text>

          <text fg={palette.gold}>Model</text>
          <text fg={palette.ivory}>{snapshot.model || "unassigned"}</text>
          <text fg={palette.muted}>{snapshot.provider_type || "provider unavailable"}</text>
          <text fg={palette.muted}>Up/Down cycle roster</text>

          {modelOptions.length > 0 ? (
            <box title="Models" style={{ border: true, borderColor: palette.border, height: 8 }}>
              <select
                style={{ height: "100%" }}
                options={modelOptions}
                onChange={(_, option) => {
                  if (option?.value) {
                    sendBridge({ type: "set_model", model: option.value })
                    setStatusNote(`Requested model ${option.value}`)
                  }
                }}
              />
            </box>
          ) : null}

          {snapshot.last_error ? (
            <>
              <text fg={palette.gold}>Error</text>
              <text fg={palette.danger}>{snapshot.last_error}</text>
            </>
          ) : null}
        </box>
      </box>

      {pendingApproval ? (
        <box
          title="Approval Required"
          style={{
            border: true,
            borderColor: palette.gold,
            backgroundColor: palette.panelAlt,
            padding: 1,
          }}
        >
          <text fg={palette.gold}>{pendingApproval.toolName}</text>
          <text fg={palette.ivory}>{pendingApproval.detail}</text>
          <text fg={palette.muted}>Ctrl+A approve • Ctrl+D deny</text>
        </box>
      ) : null}

      <box
        title="Command Tent"
        style={{
          border: true,
          borderColor: palette.border,
          backgroundColor: palette.panel,
          height: 3,
        }}
      >
        <input
          placeholder="Mission or /resume /doctor /models /model <n|name> /interrupt /status /clear /exit"
          focused={!pendingApproval}
          value={composer}
          textColor={composerTextColor}
          focusedTextColor={composerTextColor}
          placeholderColor={composerPlaceholderColor}
          onInput={setComposer}
          onSubmit={submitComposer}
        />
      </box>

      <box style={{ flexDirection: "row", justifyContent: "space-between", paddingLeft: 1, paddingRight: 1 }}>
        <text fg={palette.muted}>{projectCwd}</text>
        <text fg={palette.muted}>{statusNote} • Up/Down models • Ctrl+L transcript/log • Esc exit</text>
      </box>
    </box>
  )
}

const renderer = await createCliRenderer({
  exitOnCtrlC: false,
})

const shutdown = (code: number) => {
  renderer.destroy()
  process.exit(code)
}

process.on("uncaughtException", (error) => {
  console.error(error)
  shutdown(1)
})

process.on("unhandledRejection", (error) => {
  console.error(error)
  shutdown(1)
})

process.on("SIGINT", () => shutdown(0))
process.on("SIGTERM", () => shutdown(0))

createRoot(renderer).render(<App />)
