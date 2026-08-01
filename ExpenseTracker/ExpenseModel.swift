import Foundation

struct Expense: Identifiable, Codable {
    var id: UUID = UUID()
    var amount: Double
    var category: String
    var date: Date
    
    init(amount: Double, category: String, date: Date = Date()) {
        self.amount = amount
        self.category = category
        self.date = date
        self.id = UUID()
    }
}
