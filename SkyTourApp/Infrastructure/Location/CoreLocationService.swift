import CoreLocation
import Foundation
import UIKit

@MainActor
final class CoreLocationService: NSObject, LocationService {
    private let manager = CLLocationManager()
    private let updates: AsyncStream<CoordinatePoint?>
    private let updatesContinuation: AsyncStream<CoordinatePoint?>.Continuation

    private var latestLocation: CoordinatePoint?
    private var pendingAuthorizationContinuation: CheckedContinuation<LocationPermissionState, Never>?

    override init() {
        let stream: AsyncStream<CoordinatePoint?>
        let continuation: AsyncStream<CoordinatePoint?>.Continuation
        (stream, continuation) = AsyncStream.makeStream(of: CoordinatePoint?.self)
        self.updates = stream
        self.updatesContinuation = continuation
        super.init()

        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.distanceFilter = 50
        manager.pausesLocationUpdatesAutomatically = true
    }

    func authorizationState() async -> LocationPermissionState {
        mappedAuthorizationState(from: manager.authorizationStatus)
    }

    func requestWhenInUseAuthorization() async -> LocationPermissionState {
        let currentState = mappedAuthorizationState(from: manager.authorizationStatus)
        guard currentState == .notDetermined else {
            if currentState.isAuthorized {
                startUpdatingLocation()
            }
            return currentState
        }

        return await withCheckedContinuation { continuation in
            pendingAuthorizationContinuation = continuation
            manager.requestWhenInUseAuthorization()
        }
    }

    func denyAuthorization() async -> LocationPermissionState {
        .denied
    }

    func currentLocation() async -> CoordinatePoint? {
        guard mappedAuthorizationState(from: manager.authorizationStatus).isAuthorized else {
            return nil
        }

        startUpdatingLocation()
        manager.requestLocation()
        return latestLocation
    }

    func locationUpdates() -> AsyncStream<CoordinatePoint?> {
        updates
    }

    func startUpdatingLocation() {
        guard mappedAuthorizationState(from: manager.authorizationStatus).isAuthorized else { return }
        manager.startUpdatingLocation()
        manager.startUpdatingHeading()
    }

    func stopUpdatingLocation() {
        manager.stopUpdatingLocation()
        manager.stopUpdatingHeading()
    }

    func openSystemSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }

    private func mappedAuthorizationState(from status: CLAuthorizationStatus) -> LocationPermissionState {
        switch status {
        case .notDetermined:
            .notDetermined
        case .restricted:
            .restricted
        case .denied:
            .denied
        case .authorizedAlways:
            .authorizedAlways
        case .authorizedWhenInUse:
            .authorizedWhenInUse
        @unknown default:
            .restricted
        }
    }

    private func handleAuthorizationChange() {
        let state = mappedAuthorizationState(from: manager.authorizationStatus)

        if state.isAuthorized {
            startUpdatingLocation()
            manager.requestLocation()
        } else {
            latestLocation = nil
            updatesContinuation.yield(nil)
        }

        pendingAuthorizationContinuation?.resume(returning: state)
        pendingAuthorizationContinuation = nil
    }

    private func handleLocationUpdate(_ locations: [CLLocation]) {
        guard let location = locations.last else { return }
        latestLocation = CoordinatePoint(
            latitude: location.coordinate.latitude,
            longitude: location.coordinate.longitude
        )
        updatesContinuation.yield(latestLocation)
    }

    private func handleLocationFailure() {
        updatesContinuation.yield(latestLocation)
    }
}

extension CoreLocationService: CLLocationManagerDelegate {
    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        Task { @MainActor in
            handleAuthorizationChange()
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        Task { @MainActor in
            handleLocationUpdate(locations)
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        Task { @MainActor in
            handleLocationFailure()
        }
    }
}
