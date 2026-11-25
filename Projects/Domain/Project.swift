import ProjectDescription

let project = Project(
    name: "Domain",
    targets: [
        .target(
            name: "Domain",
            destinations: [.iPhone],
            product: .framework,
            bundleId: "com.example.expensetracker.domain",
            deploymentTargets: .iOS("18.0"),
            infoPlist: .default,
            sources: ["Sources/**"],
            dependencies: [
                .target(name: "DomainInterface")
            ]
        ),
        .target(
            name: "DomainInterface",
            destinations: [.iPhone],
            product: .framework,
            bundleId: "com.example.expensetracker.domaininterface",
            deploymentTargets: .iOS("18.0"),
            infoPlist: .default,
            sources: ["Interface/**"],
            dependencies: [
                .external(name: "ComposableArchitecture")
            ]
        )
    ]
)
