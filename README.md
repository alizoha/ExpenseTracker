# Expense Tracker

A professional SwiftUI-based expense tracking application for managing daily expenses, monitoring budgets, and analyzing spending patterns.

## Features

### Core Features

* Add and manage daily expenses
* Categorize expenses
* Select expense dates
* Add optional notes and descriptions
* Persist data locally on the device
* Search expenses by category, amount, or notes
* Filter expenses by category and date range
* Sort expenses by date, amount, or category

### Advanced Features

* Analytics dashboard with spending breakdowns
* Monthly budget tracking
* Monthly spending summaries
* Historical spending analysis
* Date range filtering
* Real-time budget progress tracking
* Over-budget alerts
* Automatic monthly budget reset

## User Interface

* Tab-based navigation
* Responsive SwiftUI interface
* Gradient-based visual design
* Smooth animations and transitions
* Intuitive expense management workflow
* Form validation for reliable data entry

## Technology Stack

* **Language:** Swift
* **Framework:** SwiftUI
* **Visualization:** SwiftUI Charts
* **Storage:** UserDefaults with JSON encoding and decoding
* **Minimum iOS Version:** iOS 16+
* **Architecture:** MVVM-inspired architecture

## Project Structure

### Views

* `ContentView.swift` — Main expense management screen with search, filtering, sorting, and expense listing
* `AddExpenseView.swift` — Form for creating new expenses
* `AnalyticsView.swift` — Spending analytics and category breakdowns

### Models

* `ExpenseModel.swift` — Expense data model implementing `Codable`

## Key Components

### Expense Management

Users can create, view, and manage expenses by entering:

* Amount
* Category
* Date
* Optional notes

### Search, Filtering, and Sorting

Expenses can be searched in real time and filtered using:

* Category
* This Week
* This Month
* Last 30 Days
* Custom date range

Results can also be sorted by:

* Date
* Amount
* Category

### Analytics

The analytics dashboard provides a visual representation of spending patterns, including:

* Spending breakdown by category
* Total spending
* Category-wise amounts
* Percentage distribution

### Budget Tracking

Users can set a monthly budget and monitor their spending through:

* Monthly budget limit
* Real-time progress indicator
* Remaining budget
* Over-budget status
* Automatic monthly reset

### Monthly Summary

The Monthly Summary section provides:

* Monthly spending totals
* Historical spending data
* Month-to-month comparisons
* Spending trend analysis

## Development Timeline

| Day | Focus                          | Status   |
| --- | ------------------------------ | -------- |
| 1–2 | Core UI and data persistence   | Complete |
| 3   | Charts and analytics           | Complete |
| 4   | Search, filtering, and sorting | Complete |
| 5   | UI polish and animations       | Complete |
| 6–7 | Testing and documentation      | Complete |
| 8+  | Advanced features              | Complete |

## Testing

The application has been tested for:

* Data persistence
* Expense creation and management
* Form validation
* Search functionality
* Filtering and sorting
* Budget calculations
* Monthly aggregation
* Analytics calculations
* UI animations
* Application stability

## Installation

### Requirements

* Xcode 14.0 or later
* iOS 16.0 or later
* Swift 5.7 or later
* macOS with Xcode installed

### Setup

Clone the repository:

```bash
git clone https://github.com/alizoha/ExpenseTracker.git
```

Navigate to the project directory:

```bash
cd ExpenseTracker
```

Open the project in Xcode:

```bash
open ExpenseTracker.xcodeproj
```

Select an iOS Simulator or connected device and press **Cmd + R** to build and run the application.

## Future Enhancements

Planned improvements include:

* Budget notifications
* Advanced analytics and reporting
* CSV and PDF export
* Custom expense tags
* iCloud synchronization
* Enhanced Dark Mode support
* Multi-currency support

## Learning Outcomes

This project demonstrates experience with:

* Swift programming
* SwiftUI development
* State management and reactive programming
* Local data persistence
* JSON encoding and decoding
* Form design and validation
* Data visualization with SwiftUI Charts
* MVVM-inspired application architecture
* UI/UX design principles
* Git and GitHub version control

## Author

**Ali Zoha**

GitHub: [@alizoha](https://github.com/alizoha)

## License

This project is open source and available under the MIT License.

## Support

For questions, feedback, or bug reports, please open an issue in the GitHub repository.

---

**Status:** Production-Ready
**Last Updated:** August 2026
