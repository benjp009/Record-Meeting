# Meeting Recorder for macOS

A native macOS application for recording meetings with smart detection, cloud sync, and easy organization.

## Project Overview

This project implements a strategic plan to build a Meeting Recording App for macOS in phases:

- **Phase 0**: Foundation & Setup (Infrastructure)
- **Phase 1**: MVP - Record & Save Locally
- **Phase 2**: Meeting Detection & Smart Launch
- **Phase 3**: Quality of Life Improvements
- **Phase 4**: Storage & Organization
- **Phase 5**: Cloud Sync

## Tech Stack

- **Language**: Swift 5.9+
- **UI Framework**: SwiftUI
- **Target**: macOS 13.0+
- **Audio Capture**: AVFoundation
- **Build System**: Swift Package Manager

## Prerequisites

- macOS 13.0 or later
- Swift 5.9+ (included with Xcode 15.0+)
- Git

## Quick Start

### 1. Clone and Navigate

```bash
git clone <repository-url>
cd MeetingRecorder
```

### 2. Build Locally

```bash
# Make build script executable
chmod +x "Record Meeting/build.sh"

# Build debug version
"Record Meeting/build.sh" debug

# Build release version
"Record Meeting/build.sh" release
```

### 3. Run the App

```bash
swift run MeetingRecorder
```

## Project Structure

```
MeetingRecorder/
├── MeetingRecorderApp.swift      # App entry point
├── ContentView.swift              # Home page UI
├── Package.swift                  # Swift Package manifest
├── .github/
│   └── workflows/
│       └── ci-cd.yml             # GitHub Actions pipeline
├── scripts/
│   └── build.sh                  # Build automation script
└── Tests/                        # Unit tests (to be added)
```

## Development Workflow

### Making Changes

1. Create a feature branch: `git checkout -b feature/your-feature`
2. Make your changes
3. Test locally: `swift test`
4. Push and create a pull request
5. CI/CD pipeline automatically runs tests and builds

### Code Quality

- Swift build enforces strict warnings on CI/CD
- All commits should pass `swift build -v`
- Tests added to `/Sources` as needed

## CI/CD Pipeline

The GitHub Actions workflow (`.github/workflows/ci-cd.yml`) automatically:

✅ **On every push/PR to main or develop**:
- Runs Swift tests
- Builds the app
- Checks code quality

📦 **On release creation**:
- Creates DMG installer (coming in Phase 0)
- Uploads to GitHub releases

View pipeline status in GitHub Actions tab.

## Phase 0 Deliverables ✅

- [x] Development environment ready
- [x] Swift + SwiftUI project structure
- [x] GitHub repo with CI/CD pipeline
- [x] Basic home page UI
- [x] Build scripts
- [x] First commit ready to push

## Next Steps: Phase 1

- Implement "Start Recording" button
- Integrate AVFoundation audio capture
- Create "Stop Recording" functionality
- Implement local file saving
- Create .dmg installer

## Contributing

1. Make sure your code builds: `swift build`
2. Run tests: `swift test`
3. Follow Swift naming conventions
4. Add comments for complex logic

## License

[To be determined]

## Support

For questions or issues, please create a GitHub issue.
