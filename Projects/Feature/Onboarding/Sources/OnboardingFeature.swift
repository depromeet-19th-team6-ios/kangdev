import ComposableArchitecture
import DomainInterface
import SwiftUI

@Reducer
public struct OnboardingFeature {
    @ObservableState
    public struct State {
        var step = Step.intro
        var budgetAmount = 0

        enum Step {
            case intro
            case budget
        }

        public init() {}
    }

    public enum Action: BindableAction {
        case binding(BindingAction<State>)
        case nextButtonTapped
        case completeButtonTapped
        case delegate(Delegate)

        @CasePathable
        public enum Delegate {
            case completed
        }
    }

    @Dependency(\.saveBudgetUseCase) private var saveBudgetUseCase

    public init() {}

    public var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .binding, .delegate:
                return .none

            case .nextButtonTapped:
                state.step = .budget
                return .none

            case .completeButtonTapped:
                guard state.budgetAmount > 0 else { return .none }
                let budget = Budget(limitAmount: state.budgetAmount)
                return .run { send in
                    try await saveBudgetUseCase.execute(budget)
                    await send(.delegate(.completed))
                }
            }
        }
    }
}

public struct OnboardingView: View {
    @Bindable private var store: StoreOf<OnboardingFeature>

    public init(store: StoreOf<OnboardingFeature>) {
        self.store = store
    }

    public var body: some View {
        VStack(spacing: 24) {
            Spacer()

            if store.step == .intro {
                Image(systemName: "chart.bar.xaxis")
                    .font(.system(size: 72))
                    .foregroundStyle(.blue)
                    .frame(width: 160, height: 160)
                    .background(.blue.opacity(0.12), in: Circle())

                Text("지출을 한눈에")
                    .font(.largeTitle.bold())

                Text("매일의 지출을 기록하고\n예산 흐름을 확인해 보세요.")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            } else {
                Text("예산을 설정해 주세요")
                    .font(.largeTitle.bold())

                Text("지출을 관리할 기준 금액을 입력하세요.")
                    .foregroundStyle(.secondary)

                TextField("예산 금액", value: $store.budgetAmount, format: .number)
                    .keyboardType(.numberPad)
                    .textFieldStyle(.roundedBorder)
            }

            Spacer()

            if store.step == .intro {
                Button("다음") {
                    store.send(.nextButtonTapped)
                }
                .buttonStyle(.borderedProminent)
            } else {
                Button("시작하기") {
                    store.send(.completeButtonTapped)
                }
                .buttonStyle(.borderedProminent)
                .disabled(store.budgetAmount <= 0)
            }
        }
        .padding(32)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    OnboardingView(store: Store(initialState: OnboardingFeature.State()) {
        OnboardingFeature()
    })
}
