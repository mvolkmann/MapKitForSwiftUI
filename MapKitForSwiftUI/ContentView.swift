import MapKit
import SwiftUI

struct Landmark: Hashable {
    let name: String
    let latitude: Double
    let longitude: Double
    let symbol: String
    let color: Color
}

private let londonLandmarks: [Landmark] = [
    Landmark(
        name: "Big Ben",
        latitude: 51.500713720703814,
        longitude: -0.12464558425220143,
        symbol: "building.columns",
        color: .yellow
    ),
    Landmark(
        name: "Buckingham Place",
        latitude: 51.50155095107456,
        longitude: -0.14133177297470625,
        symbol: "building.columns",
        color: .yellow
    ),
    Landmark(
        name: "Kensington Place",
        latitude: 51.50496237240371,
        longitude: -0.1876655611646256,
        symbol: "building.columns",
        color: .yellow
    ),
    Landmark(
        name: "Little Ben",
        latitude: 51.49647225103707,
        longitude: -0.14267796911741146,
        symbol: "building.columns",
        color: .yellow
    ),
    Landmark(
        name: "London Eye",
        latitude: 51.503445212367595,
        longitude: -0.11950794650283131,
        symbol: "building.columns",
        color: .yellow
    ),
    Landmark(
        name: "Park Plaza London Victoria",
        latitude: 51.494201497200315,
        longitude: -0.1419846404058454,
        symbol: "building.columns",
        color: .yellow
    ),
    Landmark(
        name: "Trafalgar Square",
        latitude: 51.50804988013744,
        longitude: -0.12800841818666414,
        symbol: "building.columns",
        color: .yellow
    ),
    Landmark(
        name: "Westminster Abbey",
        latitude: 51.49935670561984,
        longitude: -0.1273875153968162,
        symbol: "building.columns",
        color: .yellow
    )
]

private let rockyMountainLandmarks = [
    Landmark(
        name: "Alberta Falls",
        latitude: 40.30366445278945,
        longitude: -105.63800053616146,
        symbol: "drop.fill",
        color: .blue
    ),
    Landmark(
        name: "Bear Lake",
        latitude: 40.31321104615233,
        longitude: -105.64829485961543,
        symbol: "drop.fill",
        color: .blue
    ),
    Landmark(
        name: "Dream Lake",
        latitude: 40.30932173090186,
        longitude: -105.65922790208677,
        symbol: "drop.fill",
        color: .blue
    ),
    Landmark(
        name: "Emerald Lake",
        latitude: 40.309802847577075,
        longitude: -105.66834943288687,
        symbol: "drop.fill",
        color: .blue
    ),
    Landmark(
        name: "Lake Haiyaha",
        latitude: 40.30478867014698,
        longitude: -105.6624310367681,
        symbol: "drop.fill",
        color: .blue
    ),
    Landmark(
        name: "Nymph Lake",
        latitude: 40.310090181088064,
        longitude: -105.65143627375684,
        symbol: "drop.fill",
        color: .blue
    ),
    Landmark(
        name: "Parking Lot",
        latitude: 40.31175467533129,
        longitude: -105.64434112027384,
        symbol: "car",
        color: .red
    ),
]

let landmarks = londonLandmarks
// let landmarks = rockyMountainLandmarks

struct ContentView: View {
    @State private var position: MapCameraPosition = .automatic
    @State private var route: MKRoute?
    @State private var searchResults: [MKMapItem] = []
    @State private var selectedResult: MKMapItem?
    @State private var userLocation: CLLocationCoordinate2D?
    @State private var visibleRegion: MKCoordinateRegion?

    private func getDirections() {
        route = nil
        guard let userLocation else { return }
        guard let selectedResult else { return }

        let request = MKDirections.Request()
        let startCoordinate = userLocation
        request.source =
            MKMapItem(placemark: MKPlacemark(coordinate: startCoordinate))
        request.destination = selectedResult

        Task {
            let directions = MKDirections(request: request)
            let response = try? await directions.calculate()
            route = response?.routes.first
        }
    }

    private var myOverlay: some View {
        VStack {
            if let selectedResult {
                InfoView(selectedResult: selectedResult, route: route)
                    .frame(height: 128)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .padding([.top, .horizontal])
            }
            HStack {
                Button {
                    search(for: "books")
                } label: {
                    Label("Books", systemImage: "books.vertical.fill")
                }
                .buttonStyle(.borderedProminent)

                Button {
                    search(for: "pizza")
                } label: {
                    Label("Pizza", systemImage: "fork.knife")
                }
                .buttonStyle(.borderedProminent)
            }
        }
    }

    private func search(for query: String) {
        print("search entered")
        guard let center = visibleRegion?.center else {
            searchResults = []
            return
        }

        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        request.resultTypes = .pointOfInterest
        let delta = 0.0000001 // TODO: Why does this seem to have no effect?
        request.region = MKCoordinateRegion(
            center: center,
            span: MKCoordinateSpan(latitudeDelta: delta, longitudeDelta: delta)
        )
        Task {
            let search = MKLocalSearch(request: request)
            let response = try? await search.start()
            searchResults = response?.mapItems ?? []
        }
    }

    var body: some View {
        VStack {
            // The Map view automatically displays the Apple Maps logo
            // and a "Legal" link in the lower-left corner.
            //
            // The map is automatically zoomed to show all its content.
            // In this case that is all the landmarks.
            //
            // This triggers the warning "Publishing changes from within view
            // updates is not allowed, this will cause undefined behavior"
            // even when my code doesn't change any state!
            //
            // When running in the Simulator:
            // - to pan the map, drag it in any direction
            // - to zoom in, double-click
            // - to zoom out, hold down the option key and click
            // - to rotate the map, hold down the option key and drag
            // - to change the pitch,
            //   hold down the shift and option keys and drag
            Map(
                position: $position,
                selection: $selectedResult
            ) {
                // Marker("label", coordinate: coordinate)

                ForEach(landmarks, id: \.self) { landmark in
                    let coordinate = CLLocationCoordinate2D(
                        latitude: landmark.latitude,
                        longitude: landmark.longitude
                    )

                    // This displays a balloon icon.
                    // Marker(landmark.name, coordinate: coordinate)

                    // This can display any SwiftUI view.
                    // This triggers the warning "Publishing changes from
                    // within view // updates is not allowed, this will cause
                    // undefined behavior" for each landmark even though
                    // my code doesn't change any state!
                    Annotation(
                        landmark.name,
                        coordinate: coordinate,
                        // This specifies the point in the annotation
                        // that should be at the coordinate.
                        anchor: .center
                    ) {
                        Image(systemName: landmark.symbol)
                            // .padding(3)
                            // .background(.yellow)
                            // .cornerRadius(4)
                            .foregroundColor(landmark.color)
                    }
                }

                ForEach(searchResults, id: \.self) { result in
                    // This displays a map pin balloon and automatically selects
                    // its color and an icon to display inside the balloon
                    // based on the kind of place it represents.
                    // Marker(item: result)

                    // The contents of the map pin ballon
                    // can be customized as follows.
                    let mark = result.placemark
                    Marker(
                        mark.name ?? "?",
                        // image: "{image-asset-name}" // custom image
                        // monogram: "RMV", // can be up to three characters
                        systemImage: "car.fill",
                        coordinate: mark.coordinate
                    )
                    .tint(.green)
                }
                // .annotationTitles(.hidden) // hides marker titles

                if let route {
                    MapPolyline(route)
                        .stroke(.blue, lineWidth: 5)
                }

                // Other supported content includes
                // MapCircle, MapPolyline, and MapPolygon.

                // This shows the current location of the user
                // with a filled blue circle.
                // To set the user location used by the Simulator,
                // select Features ... Location ... Custom Location...
                // and enter latitude and longitude values.
                // TODO: I can't get this to display in the Simulator!
                UserAnnotation()
                    .foregroundStyle(.red)
                    .stroke(.purple, lineWidth: 3)
                    .tint(.green)
            }

            // This renders additional map controls in their default locations
            // which varies by platform.  Descriptions below assume iOS.
            // Each map control is a SwiftUI view.
            // To render them in another location:
            // - Add the `@Namespace var mapScope` property to the view.
            // - Pass it to Map.  For example, `Map(scope: mapScope)`
            // - Pass it to each map control.  For example,
            //   `MapUserLocationButton(scope: mapScope)`
            // add them to your own container (ex. VStack).
            .mapControls {
                // Tapping this scrolls map to user location.
                // It seems this does not work in the Simulator.
                MapUserLocationButton()

                // This shows a compass near the upper-right corner of the map
                // if it has been rotated so north is not straight up.
                // The letter inside it indicates the nearest primary direction
                // that is up.
                MapCompass()

                // This shows the current map scale in the upper-left corner
                // of the map only while the user is zooming in or out.
                // To cause it to always be visible,
                // add the mapControlVisibility modifier.
                // It will only appear after the user interacts with the map.
                MapScaleView()
                    .mapControlVisibility(.visible)
            }

            // Renders a drawn view, not satellite images.
            // .mapStyle(.standard(elevation: .realistic))

            // Renders a satellite view with no labels.
            // .mapStyle(.imagery(elevation: .realistic))

            // Renders a satellite view with labels for roads and other
            // items.
            .mapStyle(.hybrid(elevation: .realistic))

            .onChange(of: selectedResult) {
                getDirections()
            }

            // This is only called when the user
            // stops interacting with the map.
            .onMapCameraChange { context in
                Task { @MainActor in
                    visibleRegion = context.region
                }
            }

            // This allows displaying a view on top of the map.
            .safeAreaInset(edge: .bottom) { myOverlay }

            /* TODO: Try something like this to set heading and pitch for camera.
             position = .camera(
                 MapCamera(
                     centerCoordinate: CLLocationCoordinate2D(
                         latitude: some-value,
                         longitude: some-value
                     ),
                     distance: 980,
                     heading: 242,
                     pitch: 60
                 )
             )
             */

            /* To automatically scroll the map as the user moves ...
             position = .userLocation(fallback: .automatic)
             position.followUserLocation = true
             position.positionedByUser is true of the map was dragged.
             */
        }
    }
}

#Preview {
    ContentView()
}
