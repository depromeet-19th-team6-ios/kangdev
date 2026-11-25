import ComposableArchitecture
import DomainInterface
import FeatureExpense
import SwiftUI

@main
struct FeatureExpenseDemoApp: App {
    var body: some Scene {
        WindowGroup {
            ExpenseView(store: makeStore())
        }
    }

    private func makeStore() -> StoreOf<ExpenseFeature> {
        let useCases = DemoExpenseUseCases(expenses: DemoData.expenses, budget: DemoData.budget)
        var state = ExpenseFeature.State(expenses: DemoData.expenses)
        state.budget = DemoData.budget

        return Store(initialState: state) {
            ExpenseFeature()
        } withDependencies: {
            $0.deleteExpenseUseCase = useCases
            $0.exceedsBudgetUseCase = useCases
            $0.saveExpenseUseCase = useCases
            $0.updateExpenseUseCase = useCases
            $0.updateBudgetUseCase = useCases
        }
    }
}

private enum DemoData {
    static let budget = Budget(limitAmount: 100_000)
    static let expenses = [
        Expense(name: "점심", amount: 12_000, date: .now, category: .food),
        Expense(name: "버스", amount: 1_500, date: .now, category: .transportation),
        Expense(name: "책", amount: 18_000, date: .now, category: .shopping)
    ]
}

@MainActor
private final class DemoExpenseUseCases: DeleteExpenseUseCase, ExceedsBudgetUseCase, SaveExpenseUseCase,
    UpdateExpenseUseCase, UpdateBudgetUseCase {
    private var expenses: [Expense]
    private var budget: Budget

    init(expenses: [Expense], budget: Budget) {
        self.expenses = expenses
        self.budget = budget
    }

    func execute(_ expense: Expense) throws -> Bool {
        let spentAmount = expenses.reduce(0) { $0 + $1.amount }
        return spentAmount <= budget.limitAmount && expense.amount > budget.limitAmount - spentAmount
    }

    func execute(_ expense: Expense) throws {
        if let index = expenses.firstIndex(where: { $0.id == expense.id }) {
            expenses[index] = expense
        } else {
            expenses.append(expense)
        }
    }

    func execute(_ id: Expense.ID) throws {
        expenses.removeAll { $0.id == id }
    }

    func execute(_ budget: Budget) throws {
        self.budget = budget
    }
}
