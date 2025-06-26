# JobTwister

An experimental macOS application built with SwiftUI and SwiftData for managing job applications.

This was built mostly with GitHub Copilot. I’m not responsible for your data, nor do I make any promises that this will work.

Feel free to clone the repo and build it locally. I’m not providing a pre-built app as I don’t know how well the app is written.

## About

JobTwister is an experimental project exploring modern Apple technologies:
- **SwiftUI** for the user interface
- **SwiftData** for persistent storage
- **Charts** for data visualization

The app helps users track their job search by managing:
- Job applications with details like company, role, salary range, and URLs
- Application status tracking (pending, interview scheduled, denied)
- Work type preferences (remote, hybrid, in-office)
- Interview scheduling and tracking
- Detailed notes for each application
- CSV import/export for data portability
- Interactive dashboard with application statistics
- Real-time search across all job details
- Multiple sort options (date added, last modified, alphabetical)

## Technical Details

This project experiments with:
- NavigationSplitView for a modern three-column macOS layout
- SwiftData for local data persistence and schema migrations
- Responsive layouts that adapt to window size
- Real-time search and filtering capabilities
- Dynamic sorting with multiple criteria
- CSV data import/export functionality
- Native macOS UI patterns and keyboard shortcuts
- Dynamic charts and statistics dashboard
- Form validation and data integrity checks

## Status

This is an experimental project meant to explore SwiftUI and SwiftData capabilities on macOS. It's not intended for production use but rather as a learning platform for modern Apple development practices.

## Requirements

- macOS 14.0 or later
- Xcode 15.0 or later

### Development
The project uses:
- SwiftUI for the interface
- SwiftData for data persistence
- No external dependencies required
