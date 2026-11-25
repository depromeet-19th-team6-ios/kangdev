import ComposableArchitecture

@MainActor
public protocol LoadExpensesUseCase: Sendable {
    func execute() throws -> [Expense]
}

private enum LoadExpensesUseCaseKey: DependencyKey {
    static var liveValue: any LoadExpensesUseCase {
        fatalError("LoadExpensesUseCase must be injected by ExpenseTracker")
    }
}

extension DependencyValues {
    public var loadExpensesUseCase: any LoadExpensesUseCase {
        get { self[LoadExpensesUseCaseKey.self] }
        set { self[LoadExpensesUseCaseKey.self] = newValue }
    }
}
