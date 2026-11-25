import Foundation

public struct Expense: Identifiable, Equatable, Sendable {
    public enum Category: String, CaseIterable, Hashable, Sendable {
        case food = "식비"
        case transportation = "교통"
        case shopping = "쇼핑"
        case housing = "주거"
        case other = "기타"
    }

    public let id: UUID
    public var name: String
    public var amount: Int
    public var date: Date
    public var category: Category
    public var details: String

    public var isValid: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && amount > 0
    }

    public init(id: UUID = UUID(), name: String, amount: Int, date: Date, category: Category = .other, details: String = "") {
        self.id = id
        self.name = name
        self.amount = amount
        self.date = date
        self.category = category
        self.details = details
    }
}
