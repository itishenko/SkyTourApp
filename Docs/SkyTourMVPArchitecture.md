# SkyTour MVP Architecture

## 1. Product Understanding
SkyTour is an offline-first iPhone companion for approved sightseeing flights in small aviation. It helps pilots and passengers discover routes, preload route content, complete a preflight readiness check, and consume POI text, imagery, and prerecorded audio during flight. It is explicitly **not** an aviation navigation system.

## 2. MVP Scope
- iPhone-first native SwiftUI app
- Moldova pilot content with Chisinau / LUKK as the initial supported airport
- Welcome, disclaimer, permission, airport selection, route catalog, route details, route packages, offline manager, preflight checklist, flight mode, point details, free flight, settings
- Local JSON content and mock package downloads
- CoreLocation abstraction
- Mapbox abstraction with placeholder implementation in sprint 1
- AudioGuide abstraction with mock/local playback placeholder
- Offline readiness checks across route data, package state, media, and map availability

## 3. Out Of MVP
- Backend, CMS, auth, billing, subscriptions
- Certified aviation navigation
- Complex rerouting
- TTS or AI voice generation
- Full iPad productization
- Weather, avionics, Apple Watch

## 4. Architectural Style
- `SwiftUI + MVVM-flavored Clean Architecture`
- `AppState` owns cross-feature state and launch progression
- `DependencyContainer` wires repositories, services, and use cases
- `Presentation` renders SwiftUI screens and feature view models
- `Domain` contains entities, protocols, and use cases
- `Data` loads local JSON and persists lightweight offline/install state
- `Infrastructure` provides mock-first service implementations that can later be swapped for real CoreLocation, Mapbox, AVFoundation, and filesystem integrations

## 5. Project Structure
```text
SkyTourApp
├── App
├── Presentation
│   ├── Onboarding
│   ├── Disclaimer
│   ├── Permissions
│   ├── Home
│   ├── Airports
│   ├── Routes
│   ├── RouteDetails
│   ├── Packages
│   ├── Preflight
│   ├── FlightMap
│   ├── PointDetails
│   ├── FreeFlight
│   ├── Offline
│   ├── Settings
│   └── CommonComponents
├── Domain
│   ├── Entities
│   ├── Repositories
│   ├── ServicesProtocols
│   └── UseCases
├── Data
│   ├── LocalJSON
│   └── RepositoriesImpl
├── Infrastructure
│   ├── Location
│   ├── Mapbox
│   ├── Downloads
│   ├── Offline
│   └── Audio
└── Resources
    └── MockJSON
```

## 6. Data Model Set
- `Country`
- `Airport`
- `Route`
- `POI`
- `MediaAsset`
- `RoutePackage`
- `PackageManifest`
- `FlightSession`
- `PreflightCheckItem`
- `OfflineAvailabilityReport`

## 7. Service Contracts
- `LocationService`
- `MapService`
- `PackageDownloadService`
- `OfflineAvailabilityService`
- `POITriggerEngine`
- `AudioGuideService`
- `SettingsService`

## 8. Screen Inventory
- Welcome / onboarding
- Legal disclaimer
- Location permission
- Airport detection and manual airport selection
- Home dashboard
- Route list
- Route details
- Package list
- Package details with mock download state
- Preflight checklist
- Flight map with placeholder map abstraction
- Point details
- Free flight
- Offline manager
- Settings

## 9. Route Package Architecture
Each route package is the atomic offline unit for MVP:
- content metadata lives in local JSON
- runtime install state lives separately in local persistence
- manifest describes required files, checksums, schema version, and offline map expectation
- route readiness is derived from package state plus route-to-package membership

This keeps content data immutable and lets future backend/CMS delivery swap in without rewriting UI logic.

## 10. Mapbox Integration Plan
### Sprint 1
- ship `MapService` abstraction only
- render a native placeholder map card and route thumbnail
- keep flight UI independent from a concrete SDK view

### Sprint 2+
- add Mapbox Maps SDK through SPM
- create `MapboxMapService`
- wrap Mapbox camera, route polyline, POI annotations, heading, and offline region state
- introduce `MapContainerView` backed by `UIViewRepresentable`
- map errors surface into `FlightMapViewModel` and `PreflightChecklist`

## 11. Task Decomposition
1. Project bootstrap and XcodeGen spec
2. Architecture skeleton and DI
3. Codable models and Moldova mock content
4. Launch flow: welcome, disclaimer, permissions, airport detection
5. Home dashboard and navigation shell
6. Route and package browsing
7. Mock package download and offline state persistence
8. Preflight checklist
9. Flight session and flight map placeholder
10. Point details, free flight, offline manager, settings
11. Build verification

## 12. Key Risks And Mitigations
- Mapbox offline capability drift
  - Mitigation: isolate SDK behind `MapService`; keep fallback placeholder state in UI and checklist.
- Offline package size growth
  - Mitigation: package manifests, per-package size display, future storage budgeting in `OfflineStorageManager`.
- Unstable in-flight geolocation
  - Mitigation: `LocationService` abstraction, GPS status surfaced in UI, route logic resilient to manual airport choice and free flight.
- Battery drain
  - Mitigation: keep runtime services isolated so location frequency and heading updates can be tuned centrally.
- Route deviation complexity
  - Mitigation: MVP avoids rerouting; future `RouteDeviationService` chooses nearest relevant POI or free flight fallback.
- Package and manifest inconsistency
  - Mitigation: immutable content JSON plus separate persisted install state and explicit verification use case.
- Multi-language content drift
  - Mitigation: language codes live in content models and settings are centralized in `SettingsService`.
- User perceiving app as a navigator
  - Mitigation: disclaimer in launch flow, footer language across key screens, and flight mode copy that avoids navigation claims.
- Missing final native design system
  - Mitigation: sprint 1 uses a stable theme layer and reusable card/button primitives so later Figma tuning is localized.

## 13. Sprint 1 Deliverable
### Goal
Get a working native skeleton that covers the end-to-end demo flow without real backend, Mapbox, or AV playback.

### Included
- Xcode project generation via XcodeGen
- App state, router, dependency container
- Local JSON mock data for Moldova
- Mock services for permission, nearest airport, package downloads, offline checks, POI activation, and audio
- All core screens listed in the first technical sprint
- Placeholder flight map through `MapService`

### Explicit Assumptions
- Exact Figma nodes are not yet available, so sprint 1 uses the public Lovable prototype as style reference and the textual spec as source of truth
- Mapbox SDK integration is intentionally deferred to the next implementation slice because the current sprint only needs the placeholder abstraction
- Offline download in sprint 1 simulates progress and persists install state, but does not fetch real assets yet

