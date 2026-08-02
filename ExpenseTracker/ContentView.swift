import SwiftUI

struct ContentView: View {
    @State private var showingAddExpense = false
    @State private var expenses: [Expense] = []
    @State private var searchText: String = ""
    @State private var selectedCategory: String = "All"
    @State private var sortOption: String = "Date"
    
    var totalSpent: Double {
        expenses.reduce(0) { $0 + $1.amount }
    }
    
    var filteredExpenses: [Expense] {
        var result = expenses
        
        if !searchText.isEmpty {
            result = result.filter { expense in
                expense.category.localizedCaseInsensitiveContains(searchText) ||
                String(format: "%.2f", expense.amount).contains(searchText)
            }
        }
        
        if selectedCategory != "All" {
            result = result.filter { $0.category == selectedCategory }
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
        let cats = Set(expenses.map { $0.category })
        return ["All"] + cats.sorted()
    }
    
    var body: some View {
        TabView {
            NavigationView {
                VStack {
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
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(expense.category)
                                            .font(.headline)
                                            .fontWeight(.semibold)
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
                    ToolbarItem(placement: .navigationBarTrailing) {
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
                .onAppear {
                    loadExpenses()
                }
            }
            .tabItem {
                Image(systemName: "list.bullet")
                Text("Expenses")
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
