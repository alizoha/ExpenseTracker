import Foundation

// Mock data for testing without camera

class ReceiptTestingUtilities {
    
    static let sampleReceiptTexts = [
        // Clear receipt
        """
        WHOLE FOODS
        123 Main Street
        
        Organic Milk        $5.99
        Bread               $3.49
        Chicken Breast      $8.99
        Vegetables          $4.50
        
        Subtotal           $22.97
        Tax                 $1.84
        TOTAL              $24.81
        """,
        
        // Blurry receipt (challenging)
        """
        STARBUCKS
        
        Grande Latte       5.9X
        Blueberry Muffin   4.2X
        
        TOTAL             10.2X
        """,
        
        // Restaurant receipt
        """
        PIZZA PALACE
        456 Oak Ave
        
        Margherita Pizza    $16.99
        Caesar Salad        $9.99
        Garlic Bread        $4.99
        Iced Tea            $2.99
        
        Subtotal           $34.96
        Tax                 $2.80
        Tip                 $7.00
        TOTAL              $44.76
        """
    ]
    
    static func parseTestReceipt(_ index: Int) -> ReceiptParsingResult {
        guard index < sampleReceiptTexts.count else {
            return ReceiptParsingResult(
                totalAmount: 0,
                items: [],
                storeName: "Unknown",
                confidence: 0,
                errors: ["Invalid test index"]
            )
        }
        
        return ReceiptOCREngine.parseReceiptText(sampleReceiptTexts[index])
    }
}

