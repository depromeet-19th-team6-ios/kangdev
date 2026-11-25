import ProjectDescription

let project = Project(
    name: "ExpenseTracker",
    targets: [
        .target(
            name: "ExpenseTracker",
            destinations: [.iPhone],
            product: .app,
            bundleId: "com.example.expensetracker",
            deploymentTargets: .iOS("18.0"),
            infoPlist: .extendingDefault(with: [
                "CFBundleDisplayName": "지출 관리",
                "CFBundleShortVersionString": "1.0",
                "CFBundleVersion": "1",
                "UILaunchStoryboardName": "LaunchScreen"
            ]),
            sources: ["Sources/**"],
            resources: ["../Resources/LaunchScreen.storyboard"],
            dependencies: [
                .external(name: "ComposableArchitecture"),
                .project(target: "Data", path: "../Data"),
                .project(target: "Domain", path: "../Domain"),
                .project(target: "DomainInterface", path: "../Domain"),
                .project(target: "FeatureExpense", path: "../Feature/Expense"),
                .project(target: "FeatureOnboarding", path: "../Feature/Onboarding")
            ]
        )
    ]
)
