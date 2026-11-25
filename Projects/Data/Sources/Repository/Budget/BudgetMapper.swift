import DomainInterface

enum BudgetMapper {
    static func toDomain(_ entity: BudgetEntity) -> Budget {
        Budget(limitAmount: entity.limitAmount)
    }

    static func toEntity(_ budget: Budget) -> BudgetEntity {
        BudgetEntity(limitAmount: budget.limitAmount)
    }
}
