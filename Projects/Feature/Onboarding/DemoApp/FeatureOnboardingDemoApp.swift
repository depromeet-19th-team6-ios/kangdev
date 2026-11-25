import ComposableArchitecture
import DomainInterface
import FeatureOnboarding
import SwiftUI

@main
struct FeatureOnboardingDemoApp: App {
    var body: some Scene {
        WindowGroup {
            OnboardingView(store: Store(initialState: OnboardingFeature.State()) {
                OnboardingFeature()
            } withDependencies: {
                $0.saveBudgetUseCase = DemoSaveBudgetUseCase()
            })
        }
    }
}

@MainActor
private final class DemoSaveBudgetUseCase: SaveBudgetUseCase {
    private(set) var savedBudget: Budget?

    func execute(_ budget: Budget) throws {
        savedBudget = budget
    }
}
