import ComposableArchitecture
import Data
import Domain
import DomainInterface
import SwiftUI

@main
struct ExpenseTrackerApp: App {
    var body: some Scene {
        WindowGroup {
            AppView(store: Store(initialState: AppFeature.State(), reducer: {
                AppFeature()
            }, withDependencies: {
                let budgetRepository = BudgetRepositoryImpl()
                let expenseRepository = ExpenseRepositoryImpl()
                let loadBudgetUseCase = LoadBudgetUseCaseImpl(repository: budgetRepository)
                let loadExpensesUseCase = LoadExpensesUseCaseImpl(repository: expenseRepository)
                $0.exceedsBudgetUseCase = ExceedsBudgetUseCaseImpl(
                    loadBudgetUseCase: loadBudgetUseCase,
                    loadExpensesUseCase: loadExpensesUseCase
                )
                $0.loadBudgetUseCase = loadBudgetUseCase
                $0.saveBudgetUseCase = SaveBudgetUseCaseImpl(repository: budgetRepository)
                $0.updateBudgetUseCase = UpdateBudgetUseCaseImpl(repository: budgetRepository)
                $0.deleteExpenseUseCase = DeleteExpenseUseCaseImpl(repository: expenseRepository)
                $0.loadExpensesUseCase = loadExpensesUseCase
                $0.saveExpenseUseCase = SaveExpenseUseCaseImpl(repository: expenseRepository)
                $0.updateExpenseUseCase = UpdateExpenseUseCaseImpl(repository: expenseRepository)
            }))
        }
    }
}
