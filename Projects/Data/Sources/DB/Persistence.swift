import SwiftData

@MainActor
enum Persistence {
    private static let containerResult: Result<ModelContainer, Error> = Result {
        try ModelContainer(for: ExpenseEntity.self, BudgetEntity.self)
    }

    static func context() throws -> ModelContext {
        try containerResult.get().mainContext
    }
}
