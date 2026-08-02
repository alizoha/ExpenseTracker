import SwiftUI

struct ContentView: View {
    @State private var showingAddExpense = false
    @State private var expenses: [Expense] = []
    
    var totalSpent: Double {
        expenses.reduce(0) { $0 + $1.amount }
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
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.blue)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    .padding()
                    
                    if expenses.isEmpty {
                        VStack {
                            Text("No expenses yet")
                                .foregroundColor(.gray)
                            Text("Tap + to add your first expense")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        .frame(maxHeight: .infinity, alignment: .center)
                    } else {
                        List {
                            ForEach(expenses) { expense in
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text(expense.category)
                                            .font(.headline)
                                        Text(expense.date.formatted(date: .abbreviated, time: .omitted))
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }
                                    Spacer()
                                    Text("$\(String(format: "%.2f", expense.amount))")
                                        .font(.headline)
                                }
                            }
                            .onDelete(perform: deleteExpense)
                        }
                    }
                    
                    Spacer()
                }
                .navigationTitle("Expense Tracker")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: { showingAddExpense = true }) {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 24))
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
