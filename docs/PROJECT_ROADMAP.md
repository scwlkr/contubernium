# 🗺️ Project Contubernium: Autonomous TUI Controller Roadmap

## Phase 1: The Command Center (State, Pulse, & Visibility)
**Objective:** Establish the local database, the controllable daemon lifecycle, and the Terminal User Interface (TUI) to monitor the swarm.

* **v0.1.0: SQLite Data Layer & Error Handling**
  * **Implementation:** Create `contubernium.db` with strict schemas for `jobs`, `agents`, and `system_logs`. Implement database connection pooling and lock-handling (to prevent database locked errors when multiple agents write simultaneously).
  * **Testing:** * *Unit Test:* Verify CRUD operations on the SQLite database.
    * *Error Handling Test:* Simulate concurrent writes to ensure the database properly queues transactions without locking or corrupting.

* **v0.2.0: Lifecycle Management (The On/Off Switch)**
  * **Implementation:** Build a Python CLI wrapper (`castra.py`). Implement `start`, `stop`, and `status` commands. The `start` command writes a `.pid` (Process ID) file so the system knows exactly which process to kill when you run `stop`.
  * **Testing:**
    * *Functional Test:* Run `start`, verify the daemon is running in the background. Run `stop`, verify the process terminates cleanly and the `.pid` file is deleted.
    * *Error Handling Test:* Attempt to run `start` when the daemon is already active; ensure it fails gracefully with a warning rather than creating duplicate processes.

* **v0.3.0: The Terminal User Interface (TUI) Dashboard**
  * **Implementation:** Utilize the `Textual` Python library to build a terminal dashboard. Include visual panels for: Active Jobs, Agent Status (Idle/Working), System Logs, and a manual Command Input bar. 
  * **Testing:**
    * *UI/Visual Test:* Use `textual.testing` to mount the app headlessly and assert that all panels render correctly without layout breaks or overlapping text.
    * *Integration Test:* Manually insert a job into SQLite and verify the TUI dynamically updates the "Active Jobs" panel in real-time.

## Phase 2: The Command Gateway (Telegram integration)
**Objective:** Securely connect the local engine to Telegram for remote control, while visualizing the network traffic in the TUI.

* **v0.4.0: Long-Polling Network Layer**
  * **Implementation:** Integrate Telegram API. The daemon fetches messages and pushes network status updates (e.g., "Connected", "Polling...") directly to the TUI logs panel.
  * **Testing:**
    * *Network Test:* Mock the Telegram API response to ensure the daemon correctly processes a simulated message.
    * *Error Handling Test:* Disconnect the internet. Ensure the daemon does not crash, logs a "Network Timeout" in the TUI, and automatically attempts to reconnect using exponential backoff.

* **v0.5.0: Command Parsing & Routing**
  * **Implementation:** Build the parser to turn Telegram text (`/deploy faber`) into SQLite database jobs.
  * **Testing:**
    * *Logic Test:* Feed the parser invalid commands, malformed text, and unauthorized User IDs. Verify it silently drops them or replies with an error, without halting the main daemon loop.

## Phase 3: Local Inference & Subprocess Orchestration
**Objective:** Safely trigger local models, monitor their VRAM usage/status in the TUI, and handle crashes.

* **v0.6.0: Subprocess Manager**
  * **Implementation:** Write the execution engine that spawns agent scripts (`subprocess.Popen`). Map the `stdout`/`stderr` of the running agent directly to the TUI so you can watch the agent "think" in real-time.
  * **Testing:**
    * *Integration Test:* Trigger a dummy agent script that simply counts to 10. Verify the subprocess starts, streams output to the TUI, and exits cleanly.
    * *Error Handling Test (Zombie Killer):* Force-crash the TUI. Ensure the subprocess manager catches the signal and safely kills all child agent processes so you don't leak VRAM or leave zombie processes running.

* **v0.7.0: Local LLM Handoff & Fallbacks**
  * **Implementation:** Agents format their prompts and ping the local inference server (e.g., Ollama/vLLM). 
  * **Testing:**
    * *Timeout Test:* Stop the local inference server and trigger an agent. Verify the agent catches the "Connection Refused" error, logs it to the TUI, updates the job status to "Failed", and terminates cleanly.
    * *Context Window Test:* Feed an agent an intentionally massive prompt to trigger an Out-Of-Memory (OOM) error from the local model. Ensure the system handles the crash gracefully and notifies the commander.

## Phase 4: Chronology & System Resilience
**Objective:** Introduce scheduled autonomy and self-healing mechanisms.

* **v0.8.0: The Cron Scheduler**
  * **Implementation:** Add an internal job scheduler that injects tasks into the SQLite database at specific times. Add a "Scheduled Jobs" panel to the TUI.
  * **Testing:**
    * *Time-Shift Test:* Mock the system clock to simulate a scheduled trigger time. Verify the cron system successfully inserts the job exactly when expected.

* **v0.9.0: The Watchdog & Recovery System**
  * **Implementation:** A background thread that specifically monitors the main event loop and the SQLite database for "stuck" jobs (e.g., an agent task that has been "pending" for over 30 minutes).
  * **Testing:**
    * *Resilience Test:* Manually edit the database to set an agent's status to "Working" for 2 hours. Verify the Watchdog detects the anomaly, kills any hung subprocesses, resets the job to "Pending", and logs a warning in the TUI.