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

    //default map position (world view)
    @State private var position: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 23.0, longitude: -40.0),
            span: MKCoordinateSpan(latitudeDelta: 50.0, longitudeDelta: 120.0)
        )
    )

    //turns each instructor into a studio on the map
    var studioLocations: [StudioLocation] {
        //only get instructors with valid latitude, longitude, and studio name
        instructors.compactMap { instructor in
            guard let lat = instructor.latitude,
                let lng = instructor.longitude,
                !instructor.studioName.isEmpty
            else { return nil }

            return StudioLocation(
                id: instructor.id,
                name: instructor.studioName,
                address: instructor.fullAddress,
                //represents a geographical coordinate on the Earth
                coordinate: CLLocationCoordinate2D(
                    latitude: lat, longitude: lng),
                instructor: instructor
            )
        }
    }

    //main UI
    var body: some View {
        ZStack {
            Map(position: $position) {
                //poops through each studio location For each one creates an Annotation
                ForEach(studioLocations) { studio in
                    Annotation("", coordinate: studio.coordinate) {
                        StudioMapPin(studio: studio)
                    }
                }
            }
            .padding()
        }
        .onAppear {
            focusOnRandomStudio()
        }
    }

    private func focusOnRandomStudio() {
        guard let studio = studioLocations.randomElement() else { return }
        let newRegion = MKCoordinateRegion(  //creates a new map region
            center: studio.coordinate,  //center to the selected random one
            span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        )
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {  //wait 0.1 seconds then run the code (give time to load the map)
            //move the map to the new location - animate the movement smoothly
            withAnimation(.easeInOut(duration: 1.0)) {
                position = .region(newRegion)
            }
        }
    }
}

//model
struct StudioLocation: Identifiable {
    let id: String
    let name: String
    let address: String
    let coordinate: CLLocationCoordinate2D
    let instructor: Instructor
}

struct StudioMapPin: View {
    let studio: StudioLocation

    var body: some View {
        NavigationLink(
            destination: InstructorDetailsView(instructor: studio.instructor)
        ) {
            PinContent(studio: studio)
        }
    }
}

struct PinContent: View {
    let studio: StudioLocation

    var body: some View {
        VStack(spacing: 2) {
            //studio name badge
            Text(studio.name)
                .font(.caption2)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .padding(.horizontal, 8)
                .padding(.vertical, 2)
                .background(Color(red: 0.4, green: 0.3, blue: 0.8))
                .cornerRadius(12)

            //main map pin
            ZStack {
                Circle()
                    .fill(Color(red: 0.4, green: 0.3, blue: 0.8))
                    .frame(width: 40, height: 40)
                    .shadow(color: .black.opacity(0.3), radius: 3, x: 0, y: 2)

                Image(systemName: "building.2.fill")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
            }

            //instructor name
            Text(studio.instructor.fullName)
                .font(.system(size: 8))
                .foregroundColor(.primary)
                .padding(.horizontal, 4)
                .padding(.vertical, 1)
                .background(Color.white.opacity(0.8))
                .cornerRadius(4)
        }
        .frame(width: 120)
    }
}

struct StudiosMapView_Previews: PreviewProvider {
    static var previews: some View {
        StudiosMapView(instructors: [])
    }
}
