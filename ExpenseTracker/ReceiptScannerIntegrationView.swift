import SwiftUI

struct ReceiptScannerIntegrationView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var expenses: [Expense]
    @Binding var isPresented: Bool
    
    @State private var showReceiptScanner = true
    @State private var processedReceipt: Receipt?
    @State private var showSuccess = false
    @State private var successMessage = ""
    
    var body: some View {
        ZStack {
            if showReceiptScanner {
                ReceiptScannerView()
                    .onDisappear {
                        if let receipt = processedReceipt {
                            addExpensesFromReceipt(receipt)
                        } else {
                            isPresented = false
                        }
                    }
            }
            
            if showSuccess {
                VStack(spacing: 20) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.green)
                    
                    Text("Success!")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text(successMessage)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                    
                    Button("Done") {
                        isPresented = false
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(15)
                .padding()
            }
        }
    }
    
    private func addExpensesFromReceipt(_ receipt: Receipt) {
        for expense in receipt.previewExpenses {
            var newExpense = expense
            newExpense.receiptId = receipt.id
            newExpense.isFromReceipt = true
            expenses.append(newExpense)
        }
        
        saveExpenses()
        successMessage = "Added \(receipt.previewExpenses.count) expenses from \(receipt.storeName)"
        showSuccess = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            isPresented = false
        }
    }
    
    private func saveExpenses() {
        if let encoded = try? JSONEncoder().encode(expenses) {
            UserDefaults.standard.set(encoded, forKey: "expenses")
        }
    }
}
