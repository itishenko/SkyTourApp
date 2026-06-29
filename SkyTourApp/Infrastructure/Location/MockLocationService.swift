import Foundation

@MainActor
final class MockLocationService: LocationService {
    private var state: LocationPermissionState = .notDetermined
    private let mockLocation = CoordinatePoint(latitude: 46.928, longitude: 28.931)
    private let updates: AsyncStream<CoordinatePoint?>
    private let updatesContinuation: AsyncStream<CoordinatePoint?>.Continuation

    init() {
        let stream: AsyncStream<CoordinatePoint?>
        let continuation: AsyncStream<CoordinatePoint?>.Continuation
        (stream, continuation) = AsyncStream.makeStream(of: CoordinatePoint?.self)
        self.updates = stream
        self.updatesContinuation = continuation
    }

    func authorizationState() async -> LocationPermissionState {
        state
    }

    func requestWhenInUseAuthorization() async -> LocationPermissionState {
        state = .authorizedWhenInUse
        updatesContinuation.yield(mockLocation)
        return state
    }

    func denyAuthorization() async -> LocationPermissionState {
        state = .denied
        updatesContinuation.yield(nil)
        return state
    }

    func currentLocation() async -> CoordinatePoint? {
        state.isAuthorized ? mockLocation : nil
    }

    func locationUpdates() -> AsyncStream<CoordinatePoint?> {
        updates
    }

    func startUpdatingLocation() {
        guard state.isAuthorized else { return }
        updatesContinuation.yield(mockLocation)
    }

    func stopUpdatingLocation() {
        updatesContinuation.yield(nil)
    }

    func openSystemSettings() { }
}
