import Foundation

// MARK: - Receipt Data Models

struct Receipt: Identifiable, Codable {
    var id: UUID = UUID()
    var imageData: Data?  // Stored photo (optional for space)
    var extractedText: String = ""  // Raw OCR text
    var items: [ReceiptItem] = []
    var totalAmount: Double = 0
    var confidence: Double = 0  // 0-1, how confident we are
    var date: Date = Date()
    var isProcessed: Bool = false
    var errors: [String] = []  // Parsing errors
    var storeName: String = "Unknown Store"
    var currency: String = "$"
    
    // For preview before adding to expenses
    var previewExpenses: [Expense] = []
}

struct ReceiptItem: Codable, Identifiable {
    var id: UUID = UUID()
    var name: String
    var price: Double
    var quantity: Int = 1
    
    var totalPrice: Double {
        price * Double(quantity)
    }
}

// MARK: - Receipt Parsing Result

struct ReceiptParsingResult {
    var totalAmount: Double
    var items: [ReceiptItem]
    var storeName: String
    var confidence: Double
    var errors: [String]
}

// MARK: - OCR Recognition State

enum OCRState {
    case idle
    case processing
    case success(ReceiptParsingResult)
    case error(String)
}
