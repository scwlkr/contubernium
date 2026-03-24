# 🗺️ Project Contubernium: Lean Autonomous Controller Roadmap (Local Inference)

## Phase 1: The Core Engine (State & Pulse)
**Objective:** Replace the local JSON state with a robust local database and establish a zero-cost system heartbeat.
* **v0.1.0: SQLite Migration**
  * Script a schema in SQLite (`contubernium.db`) to track Jobs, Tasks, and Agent Statuses.
  * Update the Decanus logic to read/write to SQLite instead of `contubernium_state.json`.
* **v0.2.0: The Async Heartbeat**
  * Write a lightweight Python/Node daemon (`castra_daemon`).
  * Implement an event loop that ticks every 60 seconds to check the SQLite `Jobs` table for pending items. 
  * **Rule:** The loop must execute using standard code logic. Zero LLM inference is permitted during the polling phase to protect VRAM.

## Phase 2: The Command Gateway (Telegram)
**Objective:** Establish secure, remote communication without exposing your local servers to the internet.
* **v0.3.0: Telegram Long-Polling**
  * Integrate the Telegram Bot API using long-polling.
  * Hardcode a whitelist of your specific Telegram User ID. The daemon silently drops messages from unauthorized users.
* **v0.4.0: Command Parsing**
  * Implement basic slash commands (`/status`, `/halt`, `/deploy [agent]`).
  * Map Telegram inputs directly to SQLite inserts (e.g., sending a command inserts a new job into the database, which the Heartbeat picks up on its next tick).

## Phase 3: Agent Execution & Local Inference Handoff
**Objective:** Allow the daemon to autonomously spin up agents and route them to your local models when work is detected.
* **v0.5.0: Subprocess Execution**
  * When the Heartbeat finds a pending task, it uses standard OS subprocesses to spin up the required agent's script. 
  * The agent formats the prompt and sends the inference request to your local server (e.g., Ollama, vLLM).
  * The agent does the work, updates the SQLite database to "Complete", and terminates itself to free up system memory.
* **v0.6.0: Asynchronous Reporting**
  * Add a listener to the daemon. When an agent updates a database row to "Complete", the daemon instantly pushes a Telegram message to your phone.

## Phase 4: Chronology & Automation
**Objective:** Implement time-based autonomy without running constant model inferences.
* **v0.7.0: Local Cron Integration**
  * Integrate a standard cron-parser into the daemon.
  * Allow inserting time-based jobs into SQLite (e.g., "Trigger the Explorator script every Tuesday at 8 AM").
* **v0.8.0: The Daily Standup**
  * Create a lightweight, scheduled function that queries the SQLite database for the previous 24 hours of activity and sends a formatted status report to your Telegram every morning.