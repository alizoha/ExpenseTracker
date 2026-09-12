import SwiftUI

struct ContentView: View {
    @State private var showingAddExpense = false
    @State private var showingReceiptScanner = false
    @State private var expenses: [Expense] = []
    @State private var searchText: String = ""
    @State private var selectedCategory: String = "All"
    @State private var sortOption: String = "Date"
    @State private var monthlyBudget: Double = 0
    @State private var selectedDateRange: String = "All Time"
    @State private var startDate: Date = Calendar.current.date(byAdding: .month, value: -1, to: Date()) ?? Date()
    @State private var endDate: Date = Date()
    
    var totalSpent: Double {
        expenses.reduce(0) { $0 + $1.amount }
    }
    
    var currentMonthSpent: Double {
        let calendar = Calendar.current
        let now = Date()
        let monthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: now))!
        let monthEnd = calendar.date(byAdding: .month, value: 1, to: monthStart)!
        
        return expenses.filter { $0.date >= monthStart && $0.date < monthEnd }.reduce(0) { $0 + $1.amount }
    }
    
    var budgetProgress: Double {
        guard monthlyBudget > 0 else { return 0 }
        return min(currentMonthSpent / monthlyBudget, 1.0)
    }
    
    var budgetPercentage: String {
        guard monthlyBudget > 0 else { return "0" }
        return String(format: "%.0f", budgetProgress * 100)
    }
    
    var filteredExpenses: [Expense] {
        var result = expenses
        
        if !searchText.isEmpty {
            result = result.filter { expense in
                expense.category.localizedCaseInsensitiveContains(searchText) ||
                String(format: "%.2f", expense.amount).contains(searchText) ||
                expense.notes.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        if selectedCategory != "All" {
            result = result.filter { $0.category == selectedCategory }
        }
        
        switch selectedDateRange {
        case "This Week":
            let calendar = Calendar.current
            let weekStart = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date()))!
            result = result.filter { $0.date >= weekStart }
        case "This Month":
            let calendar = Calendar.current
            let monthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: Date()))!
            result = result.filter { $0.date >= monthStart }
        case "Last 30 Days":
            let thirtyDaysAgo = Calendar.current.date(byAdding: .day, value: -30, to: Date())!
            result = result.filter { $0.date >= thirtyDaysAgo }
        case "Custom Range":
            result = result.filter { $0.date >= startDate && $0.date <= endDate }
        default:
            break
        }
        
        switch sortOption {
        case "Amount (High to Low)":
            result.sort { $0.amount > $1.amount }
        case "Amount (Low to High)":
            result.sort { $0.amount < $1.amount }
        case "Category":
            result.sort { $0.category < $1.category }
        default:
            result.sort { $0.date > $1.date }
        }
        
        return result
    }
    
    var categories: [String] {
        var cats = Set(expenses.map { $0.category })
        return ["All"] + cats.sorted()
    }
    
    var monthlyData: [(month: String, amount: Double)] {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM"
        
        var monthlyDict: [String: Double] = [:]
        
        for expense in expenses {
            let monthKey = dateFormatter.string(from: expense.date)
            monthlyDict[monthKey, default: 0] += expense.amount
        }
        
        let months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
        return months.compactMap { month in
            if let amount = monthlyDict[month] {
                return (month, amount)
            }
            return nil
        }
    }
    
    var body: some View {
        TabView {
            NavigationView {
                VStack {
                    if monthlyBudget > 0 {
                        VStack(spacing: 12) {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text("Monthly Budget")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                    Text("$\(String(format: "%.2f", currentMonthSpent)) / $\(String(format: "%.2f", monthlyBudget))")
                                        .font(.headline)
                                }
                                Spacer()
                                VStack(alignment: .trailing) {
                                    Text("\(budgetPercentage)%")
                                        .font(.headline)
                                        .foregroundColor(budgetProgress > 1.0 ? .red : .blue)
                                }
                            }
                            
                            ProgressView(value: budgetProgress)
                                .tint(budgetProgress > 1.0 ? .red : .blue)
                            
                            if currentMonthSpent > monthlyBudget {
                                HStack {
                                    Image(systemName: "exclamationmark.circle.fill")
                                        .foregroundColor(.red)
                                    Text("Over budget by $\(String(format: "%.2f", currentMonthSpent - monthlyBudget))")
                                        .font(.caption)
                                        .foregroundColor(.red)
                                }
                            }
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                        .padding()
                    }
                    
                    VStack {
                        Text("Total Spent")
                            .font(.caption)
                            .foregroundColor(.gray)
                        
                        Text("$\(String(format: "%.2f", totalSpent))")
                            .font(.system(size: 36, weight: .bold))
                            .foregroundColor(.blue)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.1), Color.cyan.opacity(0.1)]), startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
                    .cornerRadius(12)
                    .padding()
                    .transition(.scale.combined(with: .opacity))
                    
                    VStack(spacing: 8) {
                        HStack {
                            Text("Set Monthly Budget:")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                            Spacer()
                        }
                        HStack {
                            Text("$")
                                .foregroundColor(.gray)
                            TextField("Enter budget amount", value: $monthlyBudget, format: .number)
                                .textFieldStyle(.roundedBorder)
                                .keyboardType(.decimalPad)
                        }
                    }
                    .padding(.horizontal)
                    
                    VStack(spacing: 12) {
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.gray)
                            TextField("Search expenses...", text: $searchText)
                                .textFieldStyle(.roundedBorder)
                        }
                        .padding(.horizontal)
                        
                        HStack {
                            Text("Category:")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                            Picker("Category", selection: $selectedCategory) {
                                ForEach(categories, id: \.self) { category in
                                    Text(category).tag(category)
                                }
                            }
                            .pickerStyle(.segmented)
                        }
                        .padding(.horizontal)
                        
                        HStack {
                            Text("Date Range:")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                            Picker("Date Range", selection: $selectedDateRange) {
                                Text("All Time").tag("All Time")
                                Text("This Week").tag("This Week")
                                Text("This Month").tag("This Month")
                                Text("Last 30 Days").tag("Last 30 Days")
                                Text("Custom").tag("Custom Range")
                            }
                            .pickerStyle(.menu)
                        }
                        .padding(.horizontal)
                        
                        if selectedDateRange == "Custom Range" {
                            VStack(spacing: 8) {
                                DatePicker("Start Date", selection: $startDate, displayedComponents: .date)
                                DatePicker("End Date", selection: $endDate, displayedComponents: .date)
                            }
                            .padding(.horizontal)
                        }
                        
                        HStack {
                            Text("Sort:")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                            Picker("Sort", selection: $sortOption) {
                                Text("Date").tag("Date")
                                Text("Amount (High to Low)").tag("Amount (High to Low)")
                                Text("Amount (Low to High)").tag("Amount (Low to High)")
                                Text("Category").tag("Category")
                            }
                            .pickerStyle(.menu)
                        }
                        .padding(.horizontal)
                    }
                    .padding(.vertical, 8)
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .padding(.horizontal)
                    
                    if filteredExpenses.isEmpty {
                        VStack(spacing: 16) {
                            Image(systemName: "list.bullet.rectangle")
                                .font(.system(size: 48))
                                .foregroundColor(.gray)
                            Text("No expenses found")
                                .font(.headline)
                                .foregroundColor(.gray)
                            Text("Try adjusting your filters or add a new expense")
                                .font(.caption)
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                        .frame(maxHeight: .infinity, alignment: .center)
                        .transition(.opacity)
                    } else {
                        List {
                            ForEach(filteredExpenses) { expense in
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack {
                                        VStack(alignment: .leading, spacing: 4) {
                                            HStack {
                                                Text(expense.category)
                                                    .font(.headline)
                                                    .fontWeight(.semibold)
                                                
                                                if expense.isFromReceipt {
                                                    Image(systemName: "receipt.fill")
                                                        .font(.caption)
                                                        .foregroundColor(.blue)
                                                }
                                            }
                                            Text(expense.date.formatted(date: .abbreviated, time: .omitted))
                                                .font(.caption)
                                                .foregroundColor(.gray)
                                        }
                                        Spacer()
                                        VStack(alignment: .trailing, spacing: 4) {
                                            Text("$\(String(format: "%.2f", expense.amount))")
                                                .font(.headline)
                                                .fontWeight(.semibold)
                                                .foregroundColor(.blue)
                                        }
                                    }
                                    
                                    if !expense.notes.isEmpty {
                                        Text(expense.notes)
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                            .lineLimit(2)
                                    }
                                }
                                .padding(.vertical, 4)
                                .transition(.scale.combined(with: .opacity))
                            }
                            .onDelete(perform: deleteExpense)
                        }
                        .animation(.spring(response: 0.5, dampingFraction: 0.7), value: filteredExpenses.count)
                    }
                    
                    Spacer()
                }
                .navigationTitle("Expense Tracker")
                .toolbar {
                    ToolbarItemGroup(placement: .navigationBarTrailing) {
                        Button(action: { showingReceiptScanner = true }) {
                            Image(systemName: "camera.fill")
                                .foregroundColor(.blue)
                        }
                        
                        Button(action: { showingAddExpense = true }) {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 24))
                                .foregroundColor(.blue)
                        }
                    }
                }
                .sheet(isPresented: $showingAddExpense) {
                    AddExpenseView(expenses: $expenses, isPresented: $showingAddExpense)
                }
                .sheet(isPresented: $showingReceiptScanner) {
                    ReceiptScannerIntegrationView(expenses: $expenses, isPresented: $showingReceiptScanner)
                }
                .onAppear {
                    loadExpenses()
                }
            }
            .tabItem {
                Image(systemName: "list.bullet")
                Text("Expenses")
            }
            
            NavigationView {
                VStack {
                    Text("Monthly Summary")
                        .font(.headline)
                        .padding()
                    
                    if monthlyData.isEmpty {
                        VStack {
                            Text("No data yet")
                                .foregroundColor(.gray)
                        }
                        .frame(maxHeight: .infinity, alignment: .center)
                    } else {
                        List {
                            ForEach(monthlyData, id: \.month) { data in
                                HStack {
                                    Text(data.month)
                                        .font(.headline)
                                    Spacer()
                                    VStack(alignment: .trailing) {
                                        Text("$\(String(format: "%.2f", data.amount))")
                                            .fontWeight(.semibold)
                                    }
                                }
                            }
                        }
                    }
                    
                    Spacer()
                }
                .navigationTitle("Monthly Summary")
            }
            .tabItem {
                Image(systemName: "calendar")
                Text("Monthly")
            }
            
            NavigationView {
                AnalyticsView(expenses: expenses)
                    .navigationTitle("Analytics")
            }
            .tabItem {
                Image(systemName: "chart.pie")
                Text("Analytics")
            }
        }
    }
    
    private func deleteExpense(at offsets: IndexSet) {
        expenses.remove(atOffsets: offsets)
        saveExpenses()
    }
    
    private func saveExpenses() {
        if let encoded = try? JSONEncoder().encode(expenses) {
            UserDefaults.standard.set(encoded, forKey: "expenses")
        }
    }
    
    private func loadExpenses() {
        if let data = UserDefaults.standard.data(forKey: "expenses") {
            if let decoded = try? JSONDecoder().decode([Expense].self, from: data) {
                expenses = decoded
            }
        }
    }
}

#Preview {
    ContentView()
}
