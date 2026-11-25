import ComposableArchitecture
import DomainInterface
import SwiftUI

@Reducer
public struct StatisticsFeature {
    @ObservableState
    public struct State {
        @Shared public var expenses: [Expense]

        public init(expenses: [Expense] = []) {
            self._expenses = Shared(value: expenses)
        }

        public init(expenses: Shared<[Expense]>) {
            self._expenses = expenses
        }
    }

    public init() {}
}

extension StatisticsFeature.State {
    var totalAmount: Int {
        expenses.reduce(0) { $0 + $1.amount }
    }

    var amountsByCategory: [Expense.Category: Int] {
        expenses.reduce(into: [:]) { result, expense in
            result[expense.category, default: 0] += expense.amount
        }
    }
}

public struct StatisticsView: View {
    let store: StoreOf<StatisticsFeature>

    public init(store: StoreOf<StatisticsFeature>) {
        self.store = store
    }

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text("통계")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                VStack(alignment: .leading, spacing: 4) {
                    Text("총 지출")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Text(store.totalAmount, format: .currency(code: "KRW"))
                        .font(.title)
                        .fontWeight(.bold)
                }

                VStack(alignment: .leading, spacing: 12) {
                    Text("카테고리별 지출")
                        .font(.headline)

                    ForEach(Expense.Category.allCases, id: \.self) { category in
                        HStack {
                            Text(category.rawValue)
                            Spacer()
                            Text(store.amountsByCategory[category, default: 0], format: .currency(code: "KRW"))
                        }
                        Divider()
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
        }
    }
}
