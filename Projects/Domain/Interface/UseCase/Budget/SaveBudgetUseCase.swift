import ComposableArchitecture

@MainActor
public protocol SaveBudgetUseCase: Sendable {
    func execute(_ budget: Budget) throws
}

private enum SaveBudgetUseCaseKey: DependencyKey {
    static var liveValue: any SaveBudgetUseCase {
        fatalError("SaveBudgetUseCase must be injected by ExpenseTracker")
    }
}

extension DependencyValues {
    public var saveBudgetUseCase: any SaveBudgetUseCase {
        get { self[SaveBudgetUseCaseKey.self] }
        set { self[SaveBudgetUseCaseKey.self] = newValue }
    }
}
