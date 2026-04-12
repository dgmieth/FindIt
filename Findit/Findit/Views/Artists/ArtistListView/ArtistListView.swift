import SwiftUI

struct ArtistListView: View {
    @StateObject private var viewModel = ArtistListViewModel()

    @State private var searchText: String = ""
    
    private var filteredArtists: [Artist] {
        if searchText.isEmpty {
            return viewModel.artists
        }
        return viewModel.artists.filter {
            $0.name.localizedCaseInsensitiveContains(searchText) ||
            $0.genre.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    var body: some View {
        Group {
            if viewModel.isLoading {
                ProgressView(R.string.localizable.viewsArtistsListsStateLoading())
            } else if let message = viewModel.errorMessage {
                ContentUnavailableView(
                    R.string.localizable.viewsArtistsListsStateError(),
                    systemImage: "exclamationmark.triangle",
                    description: Text(message)
                )
            } else {
                List(self.filteredArtists) { artist in
                    NavigationLink(
                        destination: ArtistDetailView(artist: artist)
                    ) {
                        ArtistRowView(artist: artist)
                    }
                }
                .listStyle(.plain)
            }
        }
        .searchable(
            text: self.$searchText,
            placement: .navigationBarDrawer,
            prompt: Text(R.string.localizable.viewsArtistsListsSearchPlaceholder())
        )
        .navigationTitle(R.string.localizable.viewsArtistsListsNavBarTitle())
        .task { await viewModel.loadArtists() }
    }
}

// MARK: - Row
private struct ArtistRowView: View {
    let artist: Artist

    var body: some View {
        HStack(spacing: 14) {
            ImageView(url: artist.imageURL, size: 56)
            VStack(alignment: .leading, spacing: 3) {
                Text(artist.name)
                    .font(.headline)
                Text(artist.genre)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    NavigationStack { ArtistListView() }
}
