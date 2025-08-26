//
//  StudiosMapView.swift
//  AdoraWellness
//
//  Created by Created by Hashini Ranasinghe on 2025-08-26.
//

import MapKit
import SwiftUI

struct StudiosMapView: View {
    let instructors: [Instructor]
    @State private var position: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 23.0, longitude: -40.0),
            span: MKCoordinateSpan(latitudeDelta: 50.0, longitudeDelta: 120.0)
        )
    )

    //group instructors by studio location
    var studioLocations: [StudioLocation] {
        let filtered = instructors.filter { instructor in
            if let lat = instructor.latitude,
                let lng = instructor.longitude,
                !instructor.studioName.isEmpty
            {
                return true
            } else {
                print(
                    "filtering out instructor \(instructor.fullName) - lat: \(instructor.latitude ?? 0), lng: \(instructor.longitude ?? 0), studio: '\(instructor.studioName)'"
                )
                return false
            }
        }

        print("found \(filtered.count) instructors")

        let grouped = Dictionary(grouping: filtered) { instructor in
            "\(instructor.studioName)-\(instructor.latitude ?? 0)-\(instructor.longitude ?? 0)"
        }

        let locations = grouped.compactMap {
            (key, instructors) -> StudioLocation? in
            guard let firstInstructor = instructors.first,
                let latitude = firstInstructor.latitude,
                let longitude = firstInstructor.longitude
            else {
                return nil
            }

            return StudioLocation(
                id: key,
                name: firstInstructor.studioName,
                address: firstInstructor.fullAddress,
                coordinate: CLLocationCoordinate2D(
                    latitude: latitude, longitude: longitude),
                instructors: instructors
            )
        }

        print("created \(locations.count) studio locations")
        return locations
    }

    var body: some View {
        ZStack {
            Map(position: $position) {
                ForEach(studioLocations) { studio in
                    Annotation("", coordinate: studio.coordinate) {
                        StudioMapPin(studio: studio)
                    }
                }
            }
            .padding()
        }
        .onAppear {
            updateMapRegion()
        }
    }

    private func updateMapRegion() {
        guard let randomStudio = studioLocations.randomElement() else {
            print("no studios found")
            return
        }

        let newRegion = MKCoordinateRegion(
            center: randomStudio.coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        )

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.easeInOut(duration: 1.0)) {
                position = .region(newRegion)
            }
        }
    }
}

struct StudioLocation: Identifiable, Equatable {
    let id: String
    let name: String
    let address: String
    let coordinate: CLLocationCoordinate2D
    let instructors: [Instructor]

    static func == (lhs: StudioLocation, rhs: StudioLocation) -> Bool {
        return lhs.id == rhs.id
    }
}

struct StudioMapPin: View {
    let studio: StudioLocation

    var body: some View {
        //navigate to instructor details
        if let instructor = studio.instructors.first {
            NavigationLink(
                destination: InstructorDetailsView(instructor: instructor)
            ) {
                PinContent(studio: studio)
            }
        }
    }
}

struct PinContent: View {
    let studio: StudioLocation

    var body: some View {
        VStack(spacing: 2) {
            Text(studio.name)
                .font(.caption2)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .padding(.horizontal, 8)
                .padding(.vertical, 2)
                .background(Color(red: 0.4, green: 0.3, blue: 0.8))
                .cornerRadius(12)

            //main pin
            ZStack {
                Circle()
                    .fill(Color(red: 0.4, green: 0.3, blue: 0.8))
                    .frame(width: 40, height: 40)
                    .shadow(color: .black.opacity(0.3), radius: 3, x: 0, y: 2)

                VStack(spacing: 1) {
                    Image(systemName: "building.2.fill")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                }
            }

            //instructor name
            if let instructor = studio.instructors.first {
                Text(instructor.fullName).font(.system(size: 8))
                    .foregroundColor(.primary).padding(.horizontal, 4).padding(
                        .vertical, 1
                    ).background(Color.white.opacity(0.8)).cornerRadius(4)
            }
        }
        .frame(width: 120)
    }
}

struct StudiosMapView_Previews: PreviewProvider {
    static var previews: some View {
        StudiosMapView(instructors: [])
    }
}
