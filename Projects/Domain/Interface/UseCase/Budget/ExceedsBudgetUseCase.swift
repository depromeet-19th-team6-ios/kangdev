import ComposableArchitecture

@MainActor
public protocol ExceedsBudgetUseCase: Sendable {
    func execute(_ expense: Expense) throws -> Bool
}

private enum ExceedsBudgetUseCaseKey: DependencyKey {
    static var liveValue: any ExceedsBudgetUseCase {
        fatalError("ExceedsBudgetUseCase must be injected by ExpenseTracker")
    }
}

extension DependencyValues {
    public var exceedsBudgetUseCase: any ExceedsBudgetUseCase {
        get { self[ExceedsBudgetUseCaseKey.self] }
        set { self[ExceedsBudgetUseCaseKey.self] = newValue }
    }
}
