import ComposableArchitecture
import DomainInterface
import FeatureExpense
import FeatureOnboarding
import SwiftUI

@Reducer
struct AppFeature {
    @ObservableState
    struct State {
        @Shared var expenses: [Expense]
        @Shared(.appStorage("hasCompletedOnboarding")) var hasCompletedOnboarding = false
        var onboarding = OnboardingFeature.State()
        var expense: ExpenseFeature.State
        var statistics: StatisticsFeature.State

        init() {
            let expenses = Shared<[Expense]>(value: [])
            self._expenses = expenses
            self.expense = ExpenseFeature.State(expenses: expenses)
            self.statistics = StatisticsFeature.State(expenses: expenses)
        }
    }

    enum Action {
        case started
        case loadInitialData
        case initialDataLoaded([Expense], Budget?)
        case onboarding(OnboardingFeature.Action)
        case expense(ExpenseFeature.Action)
        case statistics(StatisticsFeature.Action)
    }

    @Dependency(\.loadBudgetUseCase) private var loadBudgetUseCase
    @Dependency(\.loadExpensesUseCase) private var loadExpensesUseCase

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .started:
                return state.hasCompletedOnboarding ? .send(.loadInitialData) : .none

            case .loadInitialData:
                return .run { send in
                    await send(.initialDataLoaded(
                        try await loadExpensesUseCase.execute(),
                        try await loadBudgetUseCase.execute()
                    ))
                }

            case let .initialDataLoaded(expenses, budget):
                state.$expenses.withLock { $0 = expenses }
                if let budget {
                    state.expense.budget = budget
                }
                return .none

            case .onboarding(.delegate(.completed)):
                state.$hasCompletedOnboarding.withLock { $0 = true }
                return .send(.loadInitialData)

            case .onboarding, .expense, .statistics:
                return .none
            }
        }

        Scope(state: \.onboarding, action: \.onboarding) {
            OnboardingFeature()
        }
        Scope(state: \.expense, action: \.expense) {
            ExpenseFeature()
        }
        Scope(state: \.statistics, action: \.statistics) {
            StatisticsFeature()
        }
    }
}

struct AppView: View {
    let store: StoreOf<AppFeature>

    var body: some View {
        Group {
            if !store.hasCompletedOnboarding {
                OnboardingView(store: store.scope(state: \.onboarding, action: \.onboarding))
            } else {
                TabView {
                    ExpenseView(store: store.scope(state: \.expense, action: \.expense))
                        .tabItem {
                            Label("지출", systemImage: "list.bullet")
                        }

                    StatisticsView(store: store.scope(state: \.statistics, action: \.statistics))
                        .tabItem {
                            Label("통계", systemImage: "chart.bar")
                        }
                }
            }
        }
        .task {
            await store.send(.started).finish()
        }
    }
}
