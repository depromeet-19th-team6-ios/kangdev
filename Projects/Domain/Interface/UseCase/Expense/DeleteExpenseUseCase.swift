import ComposableArchitecture

@MainActor
public protocol DeleteExpenseUseCase: Sendable {
    func execute(_ id: Expense.ID) throws
}

private enum DeleteExpenseUseCaseKey: DependencyKey {
    static var liveValue: any DeleteExpenseUseCase {
        fatalError("DeleteExpenseUseCase must be injected by ExpenseTracker")
    }
}

extension DependencyValues {
    public var deleteExpenseUseCase: any DeleteExpenseUseCase {
        get { self[DeleteExpenseUseCaseKey.self] }
        set { self[DeleteExpenseUseCaseKey.self] = newValue }
    }
}
