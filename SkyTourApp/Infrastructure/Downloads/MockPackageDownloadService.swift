import Foundation

@MainActor
struct MockPackageDownloadService: PackageDownloadService {
    func download(
        package: RoutePackage,
        progress: @escaping @MainActor (DownloadProgressSnapshot) -> Void
    ) async throws {
        let components = [
            DownloadComponent(id: "route-json", title: "Route JSON"),
            DownloadComponent(id: "poi-json", title: "POI JSON"),
            DownloadComponent(id: "images", title: "Фото"),
            DownloadComponent(id: "audio", title: "Аудио"),
            DownloadComponent(id: "map", title: "Map tiles"),
            DownloadComponent(id: "manifest", title: "Manifest")
        ]

        for index in components.indices {
            try await Task.sleep(for: .milliseconds(220))
            let completed = Array(components.prefix(index + 1)).map(\.title)
            await progress(
                DownloadProgressSnapshot(
                    packageID: package.id,
                    currentStep: components[index].title,
                    fractionCompleted: Double(index + 1) / Double(components.count),
                    completedComponents: completed,
                    totalComponents: components.count
                )
            )
        }
    }
}
