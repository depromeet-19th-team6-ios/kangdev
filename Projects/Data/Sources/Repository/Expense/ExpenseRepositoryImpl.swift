import DomainInterface
import Foundation
import SwiftData

@MainActor
public struct ExpenseRepositoryImpl: ExpenseRepository {
    public init() {}

    public func load() throws -> [Expense] {
        let context = try Persistence.context()
        return try context.fetch(FetchDescriptor<ExpenseEntity>()).map(ExpenseMapper.toDomain)
    }

    public func save(_ expense: Expense) throws {
        let context = try Persistence.context()
        context.insert(ExpenseMapper.toEntity(expense))
        try context.save()
    }

    public func update(_ expense: Expense) throws {
        let context = try Persistence.context()
        let id = expense.id
        var descriptor = FetchDescriptor<ExpenseEntity>(predicate: #Predicate { $0.id == id })
        descriptor.fetchLimit = 1

        guard let _ = try context.fetch(descriptor).first else {
            throw ExpenseRepositoryError.notFound
        }

        context.insert(ExpenseMapper.toEntity(expense))
        try context.save()
    }

    public func delete(_ id: Expense.ID) throws {
        let context = try Persistence.context()
        try context.delete(model: ExpenseEntity.self, where: #Predicate { $0.id == id })
        try context.save()
    }
}
