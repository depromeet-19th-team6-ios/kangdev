import DomainInterface

@MainActor
public struct LoadExpensesUseCaseImpl: LoadExpensesUseCase {
    private let repository: any ExpenseRepository

    public init(repository: any ExpenseRepository) {
        self.repository = repository
    }

    public func execute() throws -> [Expense] {
        try repository.load()
    }
}
