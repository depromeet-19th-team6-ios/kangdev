@MainActor
public protocol ExpenseRepository: Sendable {
    func load() throws -> [Expense]
    func save(_ expense: Expense) throws
    func update(_ expense: Expense) throws
    func delete(_ id: Expense.ID) throws
}

public enum ExpenseRepositoryError: Error {
    case notFound
}
