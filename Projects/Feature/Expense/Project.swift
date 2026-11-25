import ProjectDescription

let project = Project(
    name: "FeatureExpense",
    targets: [
        .target(
            name: "FeatureExpense",
            destinations: [.iPhone],
            product: .framework,
            bundleId: "com.example.expensetracker.expense",
            deploymentTargets: .iOS("18.0"),
            infoPlist: .default,
            sources: ["Sources/**"],
            dependencies: [
                .external(name: "ComposableArchitecture"),
                .project(target: "DomainInterface", path: "../../Domain"),
                .project(target: "FeatureBudget", path: "../Budget")
            ]
        ),
        .target(
            name: "FeatureExpenseDemoApp",
            destinations: [.iPhone],
            product: .app,
            bundleId: "com.example.expensetracker.expense.demo",
            deploymentTargets: .iOS("18.0"),
            infoPlist: .extendingDefault(with: [
                "CFBundleDisplayName": "지출 데모"
            ]),
            sources: ["DemoApp/**"],
            dependencies: [
                .external(name: "ComposableArchitecture"),
                .project(target: "DomainInterface", path: "../../Domain"),
                .target(name: "FeatureExpense")
            ]
        )
    ]
)
