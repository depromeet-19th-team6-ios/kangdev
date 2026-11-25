import DomainInterface

@MainActor
public struct UpdateBudgetUseCaseImpl: UpdateBudgetUseCase {
    private let repository: any BudgetRepository

    public init(repository: any BudgetRepository) {
        self.repository = repository
    }

    public func execute(_ budget: Budget) throws {
        try repository.update(budget)
    }
}
