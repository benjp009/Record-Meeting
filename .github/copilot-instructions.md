<!-- .github/copilot-instructions.md for Record Meeting -->
# Copilot / AI Agent Instructions — Meeting Recorder

This file gives focused, actionable guidance for AI coding agents working in this repo. Keep suggestions small, verifiable, and repository-aware.

1. Project overview
- App: native macOS SwiftUI app (Swift 5.9+, macOS 13+).
- Entry point: `Record Meeting/MeetingRecorderApp.swift`.
- UI: `Record Meeting/ContentView.swift` (placeholder home screen).
- Config & constants: `Record Meeting/Config.swift` (feature flags, recording defaults).
- Build automation: `Record Meeting/build.sh` (produces `dist/MeetingRecorder`).
- Manifest: top-level `Package.swift` declares an executable named `MeetingRecorder`.

2. High-level architecture notes
- Single-target Swift app following standard SPM layout: sources in `Record Meeting/`, tests in `Tests/MeetingRecorderTests/`.
- Recording and audio capture will use AVFoundation (not implemented yet). Place new audio code under `Record Meeting/` (keep feature code near UI until a clear service boundary forms).
- App-level flags live in `Config.swift` (toggle `AppConfig.Features.enableCloudSync`, `enableMeetingDetection`, etc.). Update these to test feature branches quickly.

3. Important developer workflows & commands
- Build via the project script (run from repository root):
  - `cd "Record Meeting"`
  - `chmod +x build.sh`
  - `./build.sh debug` or `./build.sh release`
- Run locally via SwiftPM:
  - `swift run MeetingRecorder`
  - Build system now correctly recognizes sources in `Record Meeting/`
- Tests: `swift test` (add under `Tests/MeetingRecorderTests/` following SPM layout).

4. Project-specific conventions & patterns
- Feature flags & tuning: change behavior via `Record Meeting/Config.swift` (e.g., `AppConfig.Recording.defaultFolder`, `autoStopDelay`).
- Logging: use the `Logger.log(_:level:file:function:line:)` utility for debug messages; tests/CI expect builds to be quiet in non-DEBUG modes.
- Recording storage: default folder is defined by `AppConfig.Recording.defaultFolder` (defaults to `~/Documents/Meetings`). Use that constant when adding file I/O.
- UI entry point: keep primary view composition in `ContentView.swift` and route new screens from there.

5. Integration points & external dependencies
- AVFoundation is the intended audio backend (not yet added). When introducing it, add minimal wrappers and unit-testable components.
- CI/CD: `.github/workflows/ci-cd.yml` runs builds and tests on push/PR. Keep changes to `build.sh` backward compatible with CI expectations.

6. What to watch for (known architectural notes)
- Source files now live in `Record Meeting/` following standard SPM convention.
- Build script is `Record Meeting/build.sh`. All documentation reflects this path.

7. Suggested first tasks for an AI agent
- Implement Phase 1 MVP scaffolding: add a `Start Recording` / `Stop Recording` control in `ContentView.swift` that toggles a simple recording service stub.
- Add a `Sources/` layout or update `Package.swift` if adding many new Swift files for SwiftPM compatibility.
- Implement a small `AudioRecorder` wrapper that uses AVFoundation and saves to `AppConfig.Recording.defaultFolder`.

8. Quick examples (code pointers)
- Toggle a feature flag for testing:
  - Edit `Record Meeting/Config.swift` → `AppConfig.Features.enableMeetingDetection = true`
- Read/write recordings path:
  - Use `AppConfig.Recording.defaultFolder` (already resolves to `Documents/Meetings`).

9. Commit & PR conventions
- Create feature branches: `feature/<short-description>`.
- Keep changes small and testable; include a short PR summary outlining files changed and why.

10. Questions for the maintainer (when uncertain)
- Where do you prefer new long-lived modules: inside `Record Meeting/` or in a separate `Sources/Services/` subdirectory for clear separation?
- Intended release packaging (.app vs .dmg) and code signing strategy for CI?

If anything in these instructions is unclear or missing, tell me what sections you'd like expanded or examples to include.
