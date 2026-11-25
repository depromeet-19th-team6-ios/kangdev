import DomainInterface

@MainActor
public struct DeleteExpenseUseCaseImpl: DeleteExpenseUseCase {
    private let repository: any ExpenseRepository

    public init(repository: any ExpenseRepository) {
        self.repository = repository
    }

    public func execute(_ id: Expense.ID) throws {
        try repository.delete(id)
    }
}
