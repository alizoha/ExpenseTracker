import SwiftUI
import Charts

struct AnalyticsView: View {
    let expenses: [Expense]
    
    var categoryTotals: [String: Double] {
        Dictionary(grouping: expenses, by: \.category)
            .mapValues { $0.reduce(0) { $0 + $1.amount } }
    }
    
    var chartData: [ChartData] {
        categoryTotals.map { ChartData(category: $0.key, amount: $0.value) }
            .sorted { $0.amount > $1.amount }
    }
    
    var totalAmount: Double {
        chartData.reduce(0) { $0 + $1.amount }
    }
    
    var body: some View {
        VStack {
            Text("Spending by Category")
                .font(.headline)
                .padding()
            
            if chartData.isEmpty {
                Text("No expenses to analyze")
                    .foregroundColor(.gray)
                Spacer()
            } else {
                Chart(chartData) { data in
                    BarMark(
                        x: .value("Category", data.category),
                        y: .value("Amount", data.amount)
                    )
                    .foregroundStyle(by: .value("Category", data.category))
                }
                .frame(height: 280)
                .padding()
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("Category Breakdown")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .padding(.horizontal)
                    
                    ForEach(chartData, id: \.category) { data in
                        HStack {
                            Text(data.category)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            VStack(alignment: .trailing, spacing: 4) {
                                Text("$\(String(format: "%.2f", data.amount))")
                                    .fontWeight(.bold)
                                Text("\(String(format: "%.1f", (data.amount / totalAmount) * 100))%")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal, 12)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                        .padding(.horizontal)
                    }
                }
                
                Spacer()
            }
        }
    }
}

struct ChartData: Identifiable {
    let id = UUID()
    let category: String
    let amount: Double
}

#Preview {
    AnalyticsView(expenses: [
        Expense(amount: 50, category: "Food"),
        Expense(amount: 30, category: "Transport"),
        Expense(amount: 25, category: "Entertainment")
    ])
}
