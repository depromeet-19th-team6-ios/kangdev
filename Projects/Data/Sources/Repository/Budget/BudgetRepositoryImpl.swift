import DomainInterface
import SwiftData

public enum BudgetRepositoryError: Error {
    case notFound
}

@MainActor
public struct BudgetRepositoryImpl: BudgetRepository {
    public init() {}

    public func load() throws -> Budget? {
        let context = try Persistence.context()
        return try context.fetch(FetchDescriptor<BudgetEntity>()).first.map(BudgetMapper.toDomain)
    }

    public func save(_ budget: Budget) throws {
        let context = try Persistence.context()
        context.insert(BudgetMapper.toEntity(budget))
        try context.save()
    }

    public func update(_ budget: Budget) throws {
        let context = try Persistence.context()
        guard let entity = try context.fetch(FetchDescriptor<BudgetEntity>()).first else {
            throw BudgetRepositoryError.notFound
        }

        entity.limitAmount = budget.limitAmount
        try context.save()
    }
}
