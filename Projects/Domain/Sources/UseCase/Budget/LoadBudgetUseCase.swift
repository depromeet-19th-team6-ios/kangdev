import DomainInterface

@MainActor
public struct LoadBudgetUseCaseImpl: LoadBudgetUseCase {
    private let repository: any BudgetRepository

    public init(repository: any BudgetRepository) {
        self.repository = repository
    }

    public func execute() throws -> Budget? {
        try repository.load()
    }
}
