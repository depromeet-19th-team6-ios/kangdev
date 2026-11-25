import Foundation
import SwiftData

@Model
final class ExpenseEntity {
    @Attribute(.unique) var id: UUID
    var name: String
    var amount: Int
    var date: Date
    var category: String
    var details: String

    init(id: UUID, name: String, amount: Int, date: Date, category: String, details: String) {
        self.id = id
        self.name = name
        self.amount = amount
        self.date = date
        self.category = category
        self.details = details
    }
}
