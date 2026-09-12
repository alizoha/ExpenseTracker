import Foundation
import Vision
import UIKit

class ReceiptOCREngine: NSObject {
    
    // MARK: - OCR Recognition
    
    static func extractTextFromImage(_ image: UIImage) async throws -> String {
        guard let cgImage = image.cgImage else {
            throw OCRError.invalidImage
        }
        
        let request = VNRecognizeTextRequest()
        request.recognitionLanguages = ["en-US"]
        request.recognitionLevel = .accurate
        
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        
        var recognizedText = ""
        
        try handler.perform([request])
        
        guard let results = request.results as? [VNRecognizedTextObservation] else {
            throw OCRError.noTextFound
        }
        
        if results.isEmpty {
            throw OCRError.noTextFound
        }
        
        for result in results {
            if let topCandidate = result.topCandidates(1).first {
                recognizedText += topCandidate.string + "\n"
            }
        }
        
        return recognizedText
    }
    
    // MARK: - Receipt Parsing
    
    static func parseReceiptText(_ text: String) -> ReceiptParsingResult {
        var errors: [String] = []
        var items: [ReceiptItem] = []
        var totalAmount: Double = 0
        var storeName = "Unknown Store"
        var confidence: Double = 0.5
        
        let lines = text.split(separator: "\n").map(String.init)
        
        // Extract store name (usually first few lines)
        if !lines.isEmpty {
            storeName = lines[0].trimmingCharacters(in: .whitespaces)
        }
        
        // Extract items and prices
        for line in lines {
            // Look for price patterns: $X.XX or X.XX
            if let price = extractPrice(from: line) {
                let itemName = extractItemName(from: line, before: price)
                if !itemName.isEmpty && itemName.count > 2 {
                    items.append(ReceiptItem(name: itemName, price: price, quantity: 1))
                }
            }
        }
        
        // Extract total (usually the largest price or marked with "TOTAL")
        totalAmount = extractTotal(from: text, items: items)
        
        // Calculate confidence
        confidence = min(Double(items.count) / 10.0, 1.0)
        
        // Validate results
        if items.isEmpty {
            errors.append("No items found in receipt")
            confidence = 0.1
        }
        
        if totalAmount <= 0 {
            errors.append("Could not extract valid total amount")
            confidence = max(0.1, confidence - 0.2)
        }
        
        return ReceiptParsingResult(
            totalAmount: totalAmount,
            items: items,
            storeName: storeName,
            confidence: confidence,
            errors: errors
        )
    }
    
    // MARK: - Helper Methods
    
    private static func extractPrice(from line: String) -> Double? {
        // Pattern: $123.45 or 123.45
        let patterns = [
            "\\$\\s*([0-9]+\\.?[0-9]{0,2})",  // $X.XX
            "([0-9]+\\.[0-9]{2})",             // X.XX
            "([0-9]+,?[0-9]{2}\\.[0-9]{2})"    // X,XXX.XX
        ]
        
        for pattern in patterns {
            if let regex = try? NSRegularExpression(pattern: pattern) {
                let range = NSRange(line.startIndex..<line.endIndex, in: line)
                if let match = regex.firstMatch(in: line, range: range) {
                    if let priceRange = Range(match.range(at: 1), in: line) {
                        let priceString = String(line[priceRange])
                            .replacingOccurrences(of: "$", with: "")
                            .replacingOccurrences(of: ",", with: "")
                        
                        if let price = Double(priceString) {
                            return price
                        }
                    }
                }
            }
        }
        return nil
    }
    
    private static func extractItemName(from line: String, before price: Double) -> String {
        // Remove the price from line to get item name
        let priceString = String(format: "%.2f", price)
        
        if let range = line.range(of: priceString) {
            let itemPart = String(line[..<range.lowerBound])
            return itemPart
                .replacingOccurrences(of: "$", with: "")
                .trimmingCharacters(in: .whitespaces)
        }
        
        return line.trimmingCharacters(in: .whitespaces)
    }
    
    private static func extractTotal(from text: String, items: [ReceiptItem]) -> Double {
        let lines = text.split(separator: "\n").map(String.init)
        var totals: [(value: Double, lineIndex: Int)] = []
        
        // Find all monetary amounts
        for (index, line) in lines.enumerated() {
            if let price = extractPrice(from: line) {
                totals.append((price, index))
            }
        }
        
        // Look for "TOTAL" keyword
        for (index, line) in lines.enumerated() {
            if line.uppercased().contains("TOTAL") ||
               line.uppercased().contains("SUBTOTAL") ||
               line.uppercased().contains("AMOUNT DUE") {
                if let price = extractPrice(from: line) {
                    return price
                }
            }
        }
        
        // Calculate sum of items
        let itemSum = items.reduce(0) { $0 + $1.totalPrice }
        
        // Return the largest amount if no total found
        if let maxTotal = totals.max(by: { $0.value < $1.value }) {
            return maxTotal.value
        }
        
        return itemSum > 0 ? itemSum : 0
    }
}

// MARK: - Error Handling

enum OCRError: LocalizedError {
    case invalidImage
    case noTextFound
    case processingFailed(String)
    case parsingFailed(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidImage:
            return "The image could not be processed. Please ensure the photo is clear."
        case .noTextFound:
            return "No text could be recognized in this image. Try a clearer photo."
        case .processingFailed(let message):
            return "Processing failed: \(message)"
        case .parsingFailed(let message):
            return "Could not parse receipt: \(message)"
        }
    }
}
