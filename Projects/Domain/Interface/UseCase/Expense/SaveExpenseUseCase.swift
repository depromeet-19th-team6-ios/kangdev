import ComposableArchitecture

@MainActor
public protocol SaveExpenseUseCase: Sendable {
    func execute(_ expense: Expense) throws
}

private enum SaveExpenseUseCaseKey: DependencyKey {
    static var liveValue: any SaveExpenseUseCase {
        fatalError("SaveExpenseUseCase must be injected by ExpenseTracker")
    }
}

extension DependencyValues {
    public var saveExpenseUseCase: any SaveExpenseUseCase {
        get { self[SaveExpenseUseCaseKey.self] }
        set { self[SaveExpenseUseCaseKey.self] = newValue }
    }
}
