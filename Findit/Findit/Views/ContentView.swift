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
                Label(
                    R.string.localizable.viewsContentViewTabsArtists(),
                    systemImage: "music.mic"
                )
            }

            NavigationStack {
                VenueListView()
            }
            .tabItem {
                Label(
                    R.string.localizable.viewsContentViewTabsVenues(),
                    systemImage: "building.2"
                )
            }
        }
    }
}

#Preview {
    ContentView()
}
