import SwiftUI
import ComposableArchitecture
import DomainInterface

@Reducer
public struct EditExpenseFeature {
    @ObservableState
    public struct State {
        var expense: Expense

        public init(expense: Expense) {
            self.expense = expense
        }
    }

    public enum Action: BindableAction {
        case binding(BindingAction<State>)
        case completeButtonTapped
        case delegate(Delegate)

        @CasePathable
        public enum Delegate {
            case expenseEdited(Expense)
        }
    }

    @Dependency(\.updateExpenseUseCase) private var updateExpenseUseCase

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
                    try await updateExpenseUseCase.execute(expense)
                    await send(.delegate(.expenseEdited(expense)))
                }
            }
        }
    }
}

struct EditExpenseView: View {
    @Bindable var store: StoreOf<EditExpenseFeature>

    var body: some View {
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
        .navigationTitle("지출 수정")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("완료") {
                    store.send(.completeButtonTapped)
                }
                .disabled(!store.expense.isValid)
            }
        }
    }
}

#Preview {
    NavigationStack {
        EditExpenseView(store: Store(initialState: EditExpenseFeature.State(expense: Expense(name: "점심", amount: 12000, date: .now)), reducer: {
            EditExpenseFeature()
        }))
    }
}
