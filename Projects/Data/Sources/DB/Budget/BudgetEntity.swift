import SwiftData

@Model
final class BudgetEntity {
    @Attribute(.unique) var id: String
    var limitAmount: Int

    init(limitAmount: Int) {
        self.id = "default"
        self.limitAmount = limitAmount
    }
}
