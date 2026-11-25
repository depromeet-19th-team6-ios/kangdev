import SwiftUI
import ComposableArchitecture
import DomainInterface

@Reducer
public struct ExpenseDetailFeature {
    @ObservableState
    public struct State {
        public var expense: Expense

        public init(expense: Expense) {
            self.expense = expense
        }
    }

    public enum Action {
        case editButtonTapped
        case delegate(Delegate)

        @CasePathable
        public enum Delegate {
            case editRequested(Expense)
        }
    }

    public init() {}

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .editButtonTapped:
                return .send(.delegate(.editRequested(state.expense)))
            case .delegate:
                return .none
            }
        }
    }
}

struct ExpenseDetailView: View {
    let store: StoreOf<ExpenseDetailFeature>

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(store.expense.name)
                    .font(.title)
                    .fontWeight(.bold)
                Text(store.expense.amount, format: .currency(code: "KRW"))
                    .font(.title2)
                Text(store.expense.date, format: .dateTime.year().month().day())
                    .foregroundStyle(.secondary)
                if !store.expense.details.isEmpty {
                    Text(store.expense.details)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("수정") {
                    store.send(.editButtonTapped)
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        ExpenseDetailView(
            store: Store(
                initialState: ExpenseDetailFeature.State(expense: Expense(name: "점심", amount: 12000, date: .now, details: "식비")),
                reducer: {
                    ExpenseDetailFeature()
                })
        )
    }
}
