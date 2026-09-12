import Foundation

struct Expense: Identifiable, Codable {
    var id: UUID = UUID()
    var amount: Double
    var category: String
    var date: Date
    var notes: String = ""
    var receiptId: UUID?  // Link to receipt source
    var isFromReceipt: Bool = false  // Flag for receipt-sourced expenses
    
    init(amount: Double, category: String, date: Date = Date(), notes: String = "", receiptId: UUID? = nil, isFromReceipt: Bool = false) {
        self.amount = amount
        self.category = category
        self.date = date
        self.notes = notes
        self.receiptId = receiptId
        self.isFromReceipt = isFromReceipt
        self.id = UUID()
    }
}
