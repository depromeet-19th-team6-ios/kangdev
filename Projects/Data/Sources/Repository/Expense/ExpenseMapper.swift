import DomainInterface

enum ExpenseMapper {
    static func toDomain(_ entity: ExpenseEntity) -> Expense {
        Expense(
            id: entity.id,
            name: entity.name,
            amount: entity.amount,
            date: entity.date,
            category: Expense.Category(rawValue: entity.category) ?? .other,
            details: entity.details
        )
    }

    static func toEntity(_ expense: Expense) -> ExpenseEntity {
        ExpenseEntity(
            id: expense.id,
            name: expense.name,
            amount: expense.amount,
            date: expense.date,
            category: expense.category.rawValue,
            details: expense.details
        )
    }
}
