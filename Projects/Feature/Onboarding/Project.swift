import ProjectDescription

let project = Project(
    name: "FeatureOnboarding",
    targets: [
        .target(
            name: "FeatureOnboarding",
            destinations: [.iPhone],
            product: .framework,
            bundleId: "com.example.expensetracker.onboarding",
            deploymentTargets: .iOS("18.0"),
            infoPlist: .default,
            sources: ["Sources/**"],
            dependencies: [
                .external(name: "ComposableArchitecture"),
                .project(target: "DomainInterface", path: "../../Domain")
            ]
        ),
        .target(
            name: "FeatureOnboardingDemoApp",
            destinations: [.iPhone],
            product: .app,
            bundleId: "com.example.expensetracker.onboarding.demo",
            deploymentTargets: .iOS("18.0"),
            infoPlist: .extendingDefault(with: [
                "CFBundleDisplayName": "온보딩 데모"
            ]),
            sources: ["DemoApp/**"],
            dependencies: [
                .external(name: "ComposableArchitecture"),
                .project(target: "DomainInterface", path: "../../Domain"),
                .target(name: "FeatureOnboarding")
            ]
        )
    ]
)
