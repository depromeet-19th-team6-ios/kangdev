import DomainInterface

@MainActor
public struct ExceedsBudgetUseCaseImpl: ExceedsBudgetUseCase {
    private let loadBudgetUseCase: any LoadBudgetUseCase
    private let loadExpensesUseCase: any LoadExpensesUseCase

    public init(
        loadBudgetUseCase: any LoadBudgetUseCase,
        loadExpensesUseCase: any LoadExpensesUseCase
    ) {
        self.loadBudgetUseCase = loadBudgetUseCase
        self.loadExpensesUseCase = loadExpensesUseCase
    }

    public func execute(_ expense: Expense) throws -> Bool {
        guard let budget = try loadBudgetUseCase.execute() else { return false }
        let spentAmount = try loadExpensesUseCase.execute().reduce(0) { $0 + $1.amount }
        return spentAmount <= budget.limitAmount && expense.amount > budget.limitAmount - spentAmount
    }
}
