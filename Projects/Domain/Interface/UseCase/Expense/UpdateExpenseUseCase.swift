import ComposableArchitecture

@MainActor
public protocol UpdateExpenseUseCase: Sendable {
    func execute(_ expense: Expense) throws
}

private enum UpdateExpenseUseCaseKey: DependencyKey {
    static var liveValue: any UpdateExpenseUseCase {
        fatalError("UpdateExpenseUseCase must be injected by ExpenseTracker")
    }
}

extension DependencyValues {
    public var updateExpenseUseCase: any UpdateExpenseUseCase {
        get { self[UpdateExpenseUseCaseKey.self] }
        set { self[UpdateExpenseUseCaseKey.self] = newValue }
    }
}
