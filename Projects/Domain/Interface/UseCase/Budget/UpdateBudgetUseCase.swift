import ComposableArchitecture

@MainActor
public protocol UpdateBudgetUseCase: Sendable {
    func execute(_ budget: Budget) throws
}

private enum UpdateBudgetUseCaseKey: DependencyKey {
    static var liveValue: any UpdateBudgetUseCase {
        fatalError("UpdateBudgetUseCase must be injected by ExpenseTracker")
    }
}

extension DependencyValues {
    public var updateBudgetUseCase: any UpdateBudgetUseCase {
        get { self[UpdateBudgetUseCaseKey.self] }
        set { self[UpdateBudgetUseCaseKey.self] = newValue }
    }
}
