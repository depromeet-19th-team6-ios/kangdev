import DomainInterface

@MainActor
public struct UpdateExpenseUseCaseImpl: UpdateExpenseUseCase {
    private let repository: any ExpenseRepository

    public init(repository: any ExpenseRepository) {
        self.repository = repository
    }

    public func execute(_ expense: Expense) throws {
        try repository.update(expense)
    }
}
