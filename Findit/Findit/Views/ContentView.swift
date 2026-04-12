//
//  ContentView.swift
//  Findit
//
//  Created by Diego Mieth on 2026-04-09.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            NavigationStack {
                ArtistListView()
            }
            .tabItem {
                Label("Artists", systemImage: "music.mic")
            }

            NavigationStack {
                VenueListView()
            }
            .tabItem {
                Label("Venues", systemImage: "building.2")
            }
        }
    }
}

#Preview {
    ContentView()
}
