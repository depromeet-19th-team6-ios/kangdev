import SwiftUI
import ComposableArchitecture
import DomainInterface

@Reducer
public struct AddExpenseFeature {
    @ObservableState
    public struct State {
        var expense = Expense(name: "", amount: 0, date: .now)
        @Presents var alert: AlertState<Action.Alert>?

        public init() {}
    }

    public enum Action: BindableAction {
        case alert(PresentationAction<Alert>)
        case binding(BindingAction<State>)
        case budgetChecked(Bool)
        case completeButtonTapped
        case delegate(Delegate)
        case saveExpense

        public enum Alert {
            case confirmAddition
        }

        @CasePathable
        public enum Delegate {
            case addExpense(Expense)
        }
    }

    @Dependency(\.dismiss) var dismiss
    @Dependency(\.exceedsBudgetUseCase) private var exceedsBudgetUseCase
    @Dependency(\.saveExpenseUseCase) private var saveExpenseUseCase

    public init() {}

    public var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .binding, .delegate:
                return .none
            case .completeButtonTapped:
                guard state.expense.isValid else { return .none }
                let expense = state.expense
                return .run { send in
                    await send(.budgetChecked(try await exceedsBudgetUseCase.execute(expense)))
                }

            case let .budgetChecked(exceedsBudget):
                if exceedsBudget {
                    state.alert = AlertState {
                        TextState("해당 지출로 현재 예산을 넘깁니다. 괜찮으신가요?")
                    } actions: {
                        ButtonState(role: .cancel) {
                            TextState("취소")
                        }
                        ButtonState(action: .confirmAddition) {
                            TextState("추가")
                        }
                    }
                    return .none
                }
                return .send(.saveExpense)

            case .alert(.presented(.confirmAddition)):
                return .send(.saveExpense)

            case .alert:
                return .none

            case .saveExpense:
                let expense = state.expense
                return .run { send in
                    try await saveExpenseUseCase.execute(expense)
                    await send(.delegate(.addExpense(expense)))
                    await dismiss()
                }
            }
        }
        .ifLet(\.$alert, action: \.alert)
    }
}

struct AddExpenseView: View {
    @Bindable var store: StoreOf<AddExpenseFeature>

    var body: some View {
        NavigationStack {
            Form {
                Section("지출 항목") {
                    TextField("지출 항목", text: $store.expense.name)
                }

                Section("금액") {
                    TextField("금액", value: $store.expense.amount, format: .number)
                        .keyboardType(.numberPad)
                }

                Section("날짜") {
                    DatePicker("지출 날짜", selection: $store.expense.date, displayedComponents: .date)
                }

                Section("카테고리") {
                    Picker("카테고리", selection: $store.expense.category) {
                        ForEach(Expense.Category.allCases, id: \.self) { category in
                            Text(category.rawValue).tag(category)
                        }
                    }
                }

                Section("설명") {
                    TextEditor(text: $store.expense.details)
                }
            }
            .navigationTitle("지출 추가")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("완료") {
                        store.send(.completeButtonTapped)
                    }
                    .disabled(!store.expense.isValid)
                }
            }
        }
        .alert($store.scope(state: \.alert, action: \.alert))
    }
}

#Preview {
    AddExpenseView(store: Store(initialState: AddExpenseFeature.State(), reducer: {
        AddExpenseFeature()
    }))
}
