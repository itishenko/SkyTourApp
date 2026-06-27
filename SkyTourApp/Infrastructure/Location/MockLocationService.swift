import Foundation

@MainActor
final class MockLocationService: LocationService {
    private var state: LocationPermissionState = .notDetermined
    private let mockLocation = CoordinatePoint(latitude: 46.928, longitude: 28.931)

    func authorizationState() async -> LocationPermissionState {
        state
    }

    func requestWhenInUseAuthorization() async -> LocationPermissionState {
        state = .authorizedWhenInUse
        return state
    }

    func denyAuthorization() async -> LocationPermissionState {
        state = .denied
        return state
    }

    func currentLocation() async -> CoordinatePoint? {
        state.isAuthorized ? mockLocation : nil
    }

    func openSystemSettings() { }
}
