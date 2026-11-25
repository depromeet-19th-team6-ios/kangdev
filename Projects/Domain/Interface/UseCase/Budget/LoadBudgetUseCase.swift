import ComposableArchitecture

@MainActor
public protocol LoadBudgetUseCase: Sendable {
    func execute() throws -> Budget?
}

private enum LoadBudgetUseCaseKey: DependencyKey {
    static var liveValue: any LoadBudgetUseCase {
        fatalError("LoadBudgetUseCase must be injected by ExpenseTracker")
    }
}

extension DependencyValues {
    public var loadBudgetUseCase: any LoadBudgetUseCase {
        get { self[LoadBudgetUseCaseKey.self] }
        set { self[LoadBudgetUseCaseKey.self] = newValue }
    }
}
