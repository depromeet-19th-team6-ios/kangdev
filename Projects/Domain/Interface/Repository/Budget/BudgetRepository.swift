@MainActor
public protocol BudgetRepository: Sendable {
    func load() throws -> Budget?
    func save(_ budget: Budget) throws
    func update(_ budget: Budget) throws
}
