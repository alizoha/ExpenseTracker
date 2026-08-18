import SwiftUI

struct AddExpenseView: View {
    @Binding var expenses: [Expense]
    @Binding var isPresented: Bool
    
    @State private var amount: String = ""
    @State private var category: String = "Food"
    @State private var date: Date = Date()
    @State private var notes: String = ""
    
    let categories = ["Food", "Transport", "Entertainment", "Shopping", "Other"]
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Amount")) {
                    TextField("Enter amount", text: $amount)
                        .keyboardType(.decimalPad)
                }
                
                Section(header: Text("Category")) {
                    Picker("Category", selection: $category) {
                        ForEach(categories, id: \.self) { category in
                            Text(category).tag(category)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                
                Section(header: Text("Date")) {
                    DatePicker("Select date", selection: $date, displayedComponents: .date)
                }
                
                Section(header: Text("Notes (Optional)")) {
                    TextEditor(text: $notes)
                        .frame(height: 100)
                        .placeholder(when: notes.isEmpty) {
                            Text("Add description or details about this expense...")
                                .foregroundColor(.gray)
                        }
                }
            }
            .navigationTitle("Add Expense")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { isPresented = false }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") { saveExpense() }
                        .disabled(amount.isEmpty)
                }
            }
        }
    }
    
    private func saveExpense() {
        guard let amountDouble = Double(amount) else { return }
        let newExpense = Expense(amount: amountDouble, category: category, date: date, notes: notes)
        expenses.append(newExpense)
        
        if let encoded = try? JSONEncoder().encode(expenses) {
            UserDefaults.standard.set(encoded, forKey: "expenses")
        }
        isPresented = false
    }
}

extension View {
    func placeholder<Content: View>(when shouldShow: Bool, alignment: Alignment = .leading, @ViewBuilder placeholder: () -> Content) -> some View {
        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}

#Preview {
    @State var expenses: [Expense] = []
    @State var isPresented = true
    return AddExpenseView(expenses: $expenses, isPresented: $isPresented)
}
