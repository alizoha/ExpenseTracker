import Foundation

struct Expense: Identifiable, Codable {
    var id: UUID = UUID()
    var amount: Double
    var category: String
    var date: Date
    var notes: String = ""
    
    init(amount: Double, category: String, date: Date = Date(), notes: String = "") {
        self.amount = amount
        self.category = category
        self.date = date
        self.notes = notes
        self.id = UUID()
    }
}
