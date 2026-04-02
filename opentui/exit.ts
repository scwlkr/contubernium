export type BridgePayload = Record<string, unknown>
export type ExitBridgeSender = (payload: BridgePayload) => void
export type ExitShutdown = (code: number) => void

export function requestOpenTuiExit(sendBridge: ExitBridgeSender, shutdown: ExitShutdown, code = 0): void {
  sendBridge({ type: "exit" })
  shutdown(code)
}
