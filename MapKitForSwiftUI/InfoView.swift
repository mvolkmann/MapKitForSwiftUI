import MapKit
import SwiftUI

struct InfoView: View {
    @State private var lookAroundScene: MKLookAroundScene?
    private var mapItem: MKMapItem
    private var route: MKRoute?

    init(mapItem: MKMapItem, route: MKRoute?) {
        self.mapItem = mapItem
        self.route = route
    }

    private func getLookAroundScene() {
        lookAroundScene = nil
        Task {
            let request = MKLookAroundSceneRequest(mapItem: mapItem)
            do {
                lookAroundScene = try await request.scene
            } catch {
                if let e = error as? MKError,
                   e.code == MKError.placemarkNotFound {
                    print("InfoView.getLookAroundScene: placemark not found")
                } else {
                    print(
                        "InfoView.getLookAroundScene: error =",
                        error.localizedDescription
                    )
                }
            }
        }
    }

    private var travelTime: String? {
        guard let route else { return nil }
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .abbreviated
        formatter.allowedUnits = [.hour, .minute]
        return formatter.string(from: route.expectedTravelTime)
    }

    var body: some View {
        LookAroundPreview(initialScene: lookAroundScene)
            .overlay(alignment: .bottomTrailing) {
                HStack {
                    Text(mapItem.name ?? "")
                    if let travelTime {
                        Text(travelTime)
                    }
                }
                .font(.caption)
                .foregroundStyle(.white)
                .padding(10)
            }
            .onAppear {
                getLookAroundScene()
            }
            .onChange(of: mapItem) {
                getLookAroundScene()
            }
    }
}
