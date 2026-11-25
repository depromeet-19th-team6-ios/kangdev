import ProjectDescription

let project = Project(
    name: "FeatureBudget",
    targets: [
        .target(
            name: "FeatureBudget",
            destinations: [.iPhone],
            product: .framework,
            bundleId: "com.example.expensetracker.budget",
            deploymentTargets: .iOS("18.0"),
            infoPlist: .default,
            sources: ["Sources/**"],
            dependencies: [
                .external(name: "ComposableArchitecture"),
                .project(target: "DomainInterface", path: "../../Domain")
            ]
        )
    ]
)
