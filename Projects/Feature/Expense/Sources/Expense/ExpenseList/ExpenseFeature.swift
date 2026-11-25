import SwiftUI
import ComposableArchitecture
import DomainInterface
import FeatureBudget

@Reducer
public struct ExpenseFeature {
    @ObservableState
    public struct State {
        @Shared public var expenses: [Expense]
        public var budget = Budget(limitAmount: 0)
        var path = StackState<Path.State>()
        @Presents var destination: Destination.State?

        public init(expenses: [Expense] = []) {
            self._expenses = Shared(value: expenses)
        }

        public init(expenses: Shared<[Expense]>) {
            self._expenses = expenses
        }
    }

    public enum Action {
        case addButtonTapped
        case budgetButtonTapped
        case budgetEdited(StackElementID, Budget)
        case deleteButtonTapped(id: Expense.ID)
        case destination(PresentationAction<Destination.Action>)
        case expenseDeleted(Expense.ID)
        case expenseTapped(Expense)
        case path(StackActionOf<Path>)

        public enum Alert {
            case confirmDeletion(id: Expense.ID)
        }
    }

    @Reducer
    public enum Path {
        case detail(ExpenseDetailFeature)
        case edit(EditExpenseFeature)
        case editBudget(EditBudgetFeature)
    }

    @Dependency(\.deleteExpenseUseCase) private var deleteExpenseUseCase

    public init() {}

    public var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .addButtonTapped:
                state.destination = .addExpense(AddExpenseFeature.State())
                return .none

            case .budgetButtonTapped:
                state.path.append(.editBudget(EditBudgetFeature.State(budget: state.budget)))
                return .none

            case let .budgetEdited(editID, budget):
                state.budget = budget
                state.path.pop(from: editID)
                return .none

            case let .deleteButtonTapped(id):
                state.destination = .alert(
                    AlertState {
                        TextState("지출 내역을 삭제할까요?")
                    } actions: {
                        ButtonState(role: .cancel) {
                            TextState("취소")
                        }
                        ButtonState(role: .destructive, action: .confirmDeletion(id: id)) {
                            TextState("삭제")
                        }
                    }
                )
                return .none

            case let .destination(.presented(.addExpense(.delegate(.addExpense(expense))))):
                state.$expenses.withLock { $0.append(expense) }
                return .none

            case let .destination(.presented(.alert(.confirmDeletion(id)))):
                state.destination = nil
                return .run { send in
                    try await deleteExpenseUseCase.execute(id)
                    await send(.expenseDeleted(id))
                }

            case let .expenseDeleted(id):
                state.$expenses.withLock { $0.removeAll { $0.id == id } }
                return .none

            case .destination:
                return .none

            case let .expenseTapped(expense):
                state.path.append(.detail(ExpenseDetailFeature.State(expense: expense)))
                return .none

            case let .path(.element(id: _, action: .detail(.delegate(.editRequested(expense))))):
                state.path.append(.edit(EditExpenseFeature.State(expense: expense)))
                return .none

            case let .path(.element(id: editID, action: .editBudget(.delegate(.budgetEdited(budget))))):
                return .send(.budgetEdited(editID, budget))

            case let .path(.element(id: editID, action: .edit(.delegate(.expenseEdited(expense))))):
                state.$expenses.withLock { expenses in
                    if let index = expenses.firstIndex(where: { $0.id == expense.id }) {
                        expenses[index] = expense
                    }
                }
                
                for detailID in state.path.ids {
                    if case let .detail(detailState) = state.path[id: detailID],
                       detailState.expense.id == expense.id {
                        state.path[id: detailID, case: \.detail]?.expense = expense
                    }
                }
                
                state.path.pop(from: editID)
                return .none

            case .path:
                return .none
            }
        }
        .ifLet(\.$destination, action: \.destination)
        .forEach(\.path, action: \.path)
    }
}

extension ExpenseFeature.State {
    var daySections: [DaySection] {
        let calendar = Calendar.current
        return Dictionary(grouping: expenses) { calendar.startOfDay(for: $0.date) }
            .map { date, expenses in
                DaySection(
                    date: date,
                    expenses: expenses.sorted {
                        if $0.date != $1.date { return $0.date > $1.date }
                        return $0.name.localizedStandardCompare($1.name) == .orderedAscending
                    }
                )
            }
            .sorted { $0.date > $1.date }
    }
    
    var totalAmount: Int {
        expenses.reduce(0) { $0 + $1.amount }
    }

    var remainingBudget: Int {
        budget.limitAmount - totalAmount
    }

    struct DaySection: Identifiable {
        let date: Date
        let expenses: [Expense]

        var id: Date { date }
    }
}

extension ExpenseFeature {
    @Reducer
    public enum Destination {
        case addExpense(AddExpenseFeature)
        @ReducerCaseIgnored
        case alert(AlertState<ExpenseFeature.Action.Alert>)

        @CasePathable
        public enum Action {
            case addExpense(AddExpenseFeature.Action)
            case alert(ExpenseFeature.Action.Alert)
        }
    }
}

public struct ExpenseView: View {
    @Bindable private var store: StoreOf<ExpenseFeature>

    public init(store: StoreOf<ExpenseFeature>) {
        self.store = store
    }

    public var body: some View {
        NavigationStack(path: $store.scope(state: \.path, action: \.path)) {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 0) {
                    Text("지출 내역")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(.horizontal)
                        .padding(.top)

                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("설정 예산")
                            Spacer()
                            Text(store.budget.limitAmount, format: .currency(code: "KRW"))
                        }

                        HStack {
                            Text("총 지출")
                            Spacer()
                            Text(store.totalAmount, format: .currency(code: "KRW"))
                        }

                        Divider()

                        HStack {
                            Text("남은 예산")
                            Spacer()
                            Text(store.remainingBudget, format: .currency(code: "KRW"))
                        }
                        .fontWeight(.bold)
                    }
                    .padding()

                    if store.expenses.isEmpty {
                        ContentUnavailableView("지출 내역이 없어요", systemImage: "creditcard")
                            .frame(maxWidth: .infinity)
                            .padding(.top, 40)
                    }

                    ForEach(store.daySections) { section in
                        Text(section.date, format: .dateTime.year().month().day())
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .padding(.horizontal)
                            .padding(.vertical, 8)

                        ForEach(section.expenses) { expense in
                            HStack {
                                Button {
                                    store.send(.expenseTapped(expense))
                                } label: {
                                    HStack {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(expense.name)
                                                .font(.headline)
                                            if !expense.details.isEmpty {
                                                Text(expense.details)
                                                    .font(.subheadline)
                                                    .foregroundStyle(.secondary)
                                                    .lineLimit(1)
                                            }
                                        }
                                        Spacer()
                                        Text(expense.amount, format: .currency(code: "KRW"))
                                            .fontWeight(.semibold)
                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                }
                                .buttonStyle(.plain)

                                Button("삭제", systemImage: "trash") {
                                    store.send(.deleteButtonTapped(id: expense.id))
                                }
                                .labelStyle(.iconOnly)
                                .buttonStyle(.borderless)
                            }
                            .padding(.horizontal)
                            .padding(.vertical, 12)

                            Divider()
                        }
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("예산") {
                        store.send(.budgetButtonTapped)
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("지출 추가", systemImage: "plus") {
                        store.send(.addButtonTapped)
                    }
                }
            }
        } destination: { store in
            switch store.case {
            case let .detail(store):
                ExpenseDetailView(store: store)
            case let .edit(store):
                EditExpenseView(store: store)
            case let .editBudget(store):
                EditBudgetView(store: store)
            }
        }
        .sheet(
            item: $store.scope(
                state: \.destination?.addExpense,
                action: \.destination.addExpense
            )
        ) { addExpenseStore in
            AddExpenseView(store: addExpenseStore)
        }
        .alert($store.scope(state: \.destination?.alert, action: \.destination.alert))
    }
}

#Preview {
    ExpenseView(store: Store(initialState: ExpenseFeature.State(expenses: [
        Expense(name: "점심", amount: 12000, date: .now, details: "식비"),
        Expense(name: "교통비", amount: 1500, date: Calendar.current.date(byAdding: .day, value: -1, to: .now) ?? .now)
    ])) {
        ExpenseFeature()
    })
}
