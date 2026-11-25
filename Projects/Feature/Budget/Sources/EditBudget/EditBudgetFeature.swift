import ComposableArchitecture
import DomainInterface
import SwiftUI

@Reducer
public struct EditBudgetFeature {
    @ObservableState
    public struct State {
        var budget: Budget

        public init(budget: Budget) {
            self.budget = budget
        }
    }

    public enum Action: BindableAction {
        case binding(BindingAction<State>)
        case completeButtonTapped
        case delegate(Delegate)

        @CasePathable
        public enum Delegate {
            case budgetEdited(Budget)
        }
    }

    @Dependency(\.updateBudgetUseCase) private var updateBudgetUseCase

    public init() {}

    public var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .binding, .delegate:
                return .none

            case .completeButtonTapped:
                let budget = state.budget
                return .run { send in
                    try await updateBudgetUseCase.execute(budget)
                    await send(.delegate(.budgetEdited(budget)))
                }
            }
        }
    }
}

public struct EditBudgetView: View {
    @Bindable private var store: StoreOf<EditBudgetFeature>

    public init(store: StoreOf<EditBudgetFeature>) {
        self.store = store
    }

    public var body: some View {
        Form {
            Section("예산 금액") {
                TextField("예산 금액", value: $store.budget.limitAmount, format: .number)
                    .keyboardType(.numberPad)
            }
        }
        .navigationTitle("예산 수정")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("완료") {
                    store.send(.completeButtonTapped)
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        EditBudgetView(store: Store(initialState: EditBudgetFeature.State(budget: Budget(limitAmount: 300_000))) {
            EditBudgetFeature()
        })
    }
}
