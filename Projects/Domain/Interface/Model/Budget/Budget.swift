public struct Budget: Equatable, Sendable {
    public var limitAmount: Int

    public init(limitAmount: Int) {
        self.limitAmount = limitAmount
    }
}
