import MapKit
import SwiftUI

struct Landmark: Hashable {
    let name: String
    let latitude: Double
    let longitude: Double
    let symbol: String
    let color: Color
}

private let londonLandmarks = [
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

private let rockyMountainlandmarks = [
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

struct ContentView: View {
    // TODO: How can this be updated when the user drags the map?
    @State private var currentCenter = CLLocationCoordinate2D(
        latitude: 51.50155095107456,
        longitude: -0.14133177297470625
    )

    @State private var searchResults: [MKMapItem] = []

    private var searchButtons: some View {
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

    private func search(for query: String) {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        request.resultTypes = .pointOfInterest
        let delta = 0.0000001 // TODO: Why does this seem to have no effect?
        request.region = MKCoordinateRegion(
            center: currentCenter,
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
            // The map is automatically zoomed to show all its content.
            // In this case that is all the landmarks.
            Map {
                // This displays a balloon icon.
                // Marker("label", coordinate: coordinate)

                ForEach(londonLandmarks, id: \.self) { landmark in
                    let coordinate = CLLocationCoordinate2D(
                        latitude: landmark.latitude,
                        longitude: landmark.longitude
                    )
                    // This can display any SwiftUI view.
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
                    let _ = print("mark =", mark)
                    Marker(
                        mark.name ?? "?",
                        // image: "{image-asset-name}" // custom image
                        // monogram: "RMV", // can be up to three characters
                        systemImage: "car.fill",
                        coordinate: mark.coordinate
                    )
                    .tint(.green)
                }

                // Other supported content includes
                // MapCircle, MapPolyline, and MapPolygon.
            }
            /*
             .onDrag {
                 print("got drag")
             }
             */

            // Drawn view, not satellite images.
            // .mapStyle(.standard(elevation: .realistic))

            // Satellite view with no labels.
            .mapStyle(.imagery(elevation: .realistic))

            // Satellite view with labels for roads and other items.
            .mapStyle(.hybrid(elevation: .realistic))

            // This allows displaying the buttons on top of the map.
            .safeAreaInset(edge: .bottom) {
                searchButtons
            }
        }
    }
}

#Preview {
    ContentView()
}
