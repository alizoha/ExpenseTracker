import SwiftUI
import UIKit

struct ReceiptScannerView: View {
    @Environment(\.dismiss) var dismiss
    @State private var showCamera = false
    @State private var showPhotoPicker = false
    @State private var selectedImage: UIImage?
    @State private var ocrState: OCRState = .idle
    @State private var receipt: Receipt?
    @State private var showPreview = false
    
    var body: some View {
        NavigationView {
            VStack {
                if selectedImage == nil {
                    // Initial State - Choose Source
                    VStack(spacing: 20) {
                        Image(systemName: "receipt.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.blue)
                        
                        Text("SnapBudget Receipt Scanner")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("Take a photo of your receipt to automatically add expenses")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        Spacer()
                        
                        VStack(spacing: 12) {
                            Button(action: { showCamera = true }) {
                                HStack {
                                    Image(systemName: "camera.fill")
                                    Text("Take Photo")
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                            }
                            
                            Button(action: { showPhotoPicker = true }) {
                                HStack {
                                    Image(systemName: "photo.fill")
                                    Text("Choose from Library")
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue.opacity(0.7))
                                .foregroundColor(.white)
                                .cornerRadius(10)
                            }
                        }
                        .padding()
                    }
                    .frame(maxHeight: .infinity, alignment: .center)
                } else if let image = selectedImage {
                    // Image Selected - Show Preview & Processing
                    ScrollView {
                        VStack(spacing: 16) {
                            // Image Preview
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                                .frame(maxHeight: 300)
                                .cornerRadius(10)
                                .padding()
                            
                            // Processing State
                            switch ocrState {
                            case .idle:
                                Button("Extract Receipt Data") {
                                    processReceipt(image)
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                                .padding()
                                
                            case .processing:
                                VStack(spacing: 12) {
                                    ProgressView()
                                        .scaleEffect(1.5)
                                    Text("Processing receipt...")
                                        .foregroundColor(.gray)
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                
                            case .success(let result):
                                ReceiptPreviewView(result: result) { receipt in
                                    self.receipt = receipt
                                    showPreview = true
                                }
                                
                            case .error(let error):
                                VStack(spacing: 12) {
                                    Image(systemName: "exclamationmark.circle")
                                        .font(.system(size: 40))
                                        .foregroundColor(.red)
                                    Text("Processing Failed")
                                        .font(.headline)
                                    Text(error)
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                        .multilineTextAlignment(.center)
                                    
                                    Button("Try Again") {
                                        selectedImage = nil
                                        ocrState = .idle
                                    }
                                    .foregroundColor(.blue)
                                }
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.red.opacity(0.1))
                                .cornerRadius(10)
                                .padding()
                            }
                        }
                    }
                }
            }
            .navigationTitle("Scan Receipt")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
            }
            .sheet(isPresented: $showCamera) {
                CameraViewControllerRepresentable { image in
                    selectedImage = image
                    ocrState = .idle
                } onCancel: {
                    showCamera = false
                }
            }
            .sheet(isPresented: $showPhotoPicker) {
                PhotoPickerRepresentable { image in
                    selectedImage = image
                    ocrState = .idle
                } onCancel: {
                    showPhotoPicker = false
                }
            }
            .sheet(isPresented: $showPreview) {
                if let receipt = receipt {
                    ReceiptConfirmationView(receipt: receipt, onConfirm: {
                        dismiss()
                    })
                }
            }
        }
    }
    
    private func processReceipt(_ image: UIImage) {
        ocrState = .processing
        
        Task {
            do {
                // Extract text using Vision framework
                let text = try await ReceiptOCREngine.extractTextFromImage(image)
                
                // Parse receipt
                let result = ReceiptOCREngine.parseReceiptText(text)
                
                // Create receipt object
                var receipt = Receipt(
                    imageData: image.jpegData(compressionQuality: 0.7),
                    extractedText: text,
                    items: result.items,
                    totalAmount: result.totalAmount,
                    confidence: result.confidence,
                    storeName: result.storeName,
                    errors: result.errors
                )
                
                self.receipt = receipt
                
                DispatchQueue.main.async {
                    if result.errors.isEmpty && result.items.count > 0 {
                        ocrState = .success(result)
                    } else {
                        let errorMsg = result.errors.isEmpty ?
                            "Could not extract items from receipt" :
                            result.errors.joined(separator: "\n")
                        ocrState = .error(errorMsg)
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    ocrState = .error(error.localizedDescription)
                }
            }
        }
    }
}

// MARK: - Receipt Preview

struct ReceiptPreviewView: View {
    let result: ReceiptParsingResult
    var onConfirm: (Receipt) -> Void
    
    @State private var selectedItems: Set<UUID> = []
    @State private var selectedCategory = "Shopping"
    
    let categories = ["Food", "Shopping", "Transport", "Entertainment", "Other"]
    
    var body: some View {
        VStack(spacing: 16) {
            // Store Name
            VStack(alignment: .leading) {
                Text("Store")
                    .font(.caption)
                    .foregroundColor(.gray)
                Text(result.storeName)
                    .font(.headline)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(10)
            
            // Confidence Level
            HStack {
                Text("Recognition Confidence")
                    .font(.subheadline)
                Spacer()
                Text("\(Int(result.confidence * 100))%")
                    .fontWeight(.semibold)
                    .foregroundColor(result.confidence > 0.7 ? .green : .orange)
            }
            .padding(.horizontal)
            
            if !result.errors.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "exclamationmark.circle")
                            .foregroundColor(.orange)
                        Text("Warnings")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                    }
                    
                    ForEach(result.errors, id: \.self) { error in
                        Text(error)
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                .padding()
                .background(Color.orange.opacity(0.1))
                .cornerRadius(10)
            }
            
            // Items List
            VStack(alignment: .leading) {
                Text("Items (\(result.items.count))")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .padding(.horizontal)
                
                ScrollView {
                    VStack(spacing: 8) {
                        ForEach(result.items) { item in
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(item.name)
                                        .font(.subheadline)
                                    Text("Qty: \(item.quantity)")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                                Spacer()
                                Text("$\(String(format: "%.2f", item.totalPrice))")
                                    .fontWeight(.semibold)
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                        }
                    }
                    .padding(.horizontal)
                }
            }
            
            // Total
            HStack {
                Text("Total Amount")
                    .font(.subheadline)
                Spacer()
                Text("$\(String(format: "%.2f", result.totalAmount))")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
            }
            .padding()
            .background(Color.blue.opacity(0.1))
            .cornerRadius(10)
            
            // Category Selection
            VStack(alignment: .leading) {
                Text("Categorize as")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Picker("Category", selection: $selectedCategory) {
                    ForEach(categories, id: \.self) { category in
                        Text(category).tag(category)
                    }
                }
                .pickerStyle(.segmented)
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(10)
            
            // Add Button
            Button(action: {
                var receipt = Receipt(
                    items: result.items,
                    totalAmount: result.totalAmount,
                    confidence: result.confidence,
                    storeName: result.storeName,
                    errors: result.errors
                )
                receipt.previewExpenses = result.items.map { item in
                    Expense(
                        amount: item.totalPrice,
                        category: selectedCategory,
                        date: Date(),
                        notes: "\(item.name) from \(result.storeName)",
                        isFromReceipt: true
                    )
                }
                onConfirm(receipt)
            }) {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                    Text("Add \(result.items.count) Expenses")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            
            Spacer()
        }
        .padding()
    }
}

// MARK: - Receipt Confirmation

struct ReceiptConfirmationView: View {
    @Environment(\.dismiss) var dismiss
    let receipt: Receipt
    var onConfirm: () -> Void
    
    @State private var expenses: [Expense] = []
    @State private var showSuccess = false
    
    var body: some View {
        NavigationView {
            VStack {
                if showSuccess {
                    VStack(spacing: 20) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.green)
                        
                        Text("Expenses Added!")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("\(receipt.previewExpenses.count) expenses from \(receipt.storeName)")
                            .foregroundColor(.gray)
                        
                        Button("Done") {
                            dismiss()
                            onConfirm()
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    .padding()
                    .frame(maxHeight: .infinity, alignment: .center)
                } else {
                    ScrollView {
                        VStack(spacing: 16) {
                            VStack(alignment: .leading) {
                                Text(receipt.storeName)
                                    .font(.headline)
                                Text("Total: $\(String(format: "%.2f", receipt.totalAmount))")
                                    .font(.subheadline)
                                    .foregroundColor(.blue)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                            
                            VStack(alignment: .leading) {
                                Text("Expenses to Add")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                
                                ForEach(receipt.previewExpenses) { expense in
                                    HStack {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(expense.notes.split(separator: " ").first.map(String.init) ?? "Expense")
                                                .font(.subheadline)
                                            Text(expense.category)
                                                .font(.caption)
                                                .foregroundColor(.gray)
                                        }
                                        Spacer()
                                        Text("$\(String(format: "%.2f", expense.amount))")
                                            .fontWeight(.semibold)
                                    }
                                    .padding()
                                    .background(Color(.systemGray6))
                                    .cornerRadius(8)
                                }
                            }
                            
                            Button(action: { addExpensesAndClose() }) {
                                HStack {
                                    Image(systemName: "checkmark.circle.fill")
                                    Text("Confirm & Add All")
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Confirm Receipt")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private func addExpensesAndClose() {
        // This will be connected to main expense list
        showSuccess = true
        
        // Simulate adding expenses
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            onConfirm()
        }
    }
}

#Preview {
    ReceiptScannerView()
}
