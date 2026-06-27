import Foundation

@MainActor
final class MockAudioGuideService: AudioGuideService {
    private(set) var currentPOI: POI?

    func play(_ poi: POI) async {
        currentPOI = poi
    }

    func pause() async { }

    func stop() async {
        currentPOI = nil
    }
}
