import SwiftUI

struct ArtistListView: View {
    @StateObject private var viewModel = ArtistListViewModel()

    @State private var searchText: String = ""

    // MARK: - Testing Support
    init(viewModel: ArtistListViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }

    init(viewModel: ArtistListViewModel, searchText: String) {
        self._viewModel = StateObject(wrappedValue: viewModel)
        self._searchText = State(initialValue: searchText)
    }

    init() {}
    
    private var filteredArtists: [Artist] {
        let base = searchText.isEmpty ? viewModel.artists : viewModel.artists.filter {
            $0.name.localizedCaseInsensitiveContains(searchText) ||
            $0.genre.localizedCaseInsensitiveContains(searchText)
        }
        switch viewModel.sortOrder {
        // AC -> Artists must be displayed in alphabetical order by name
        case .name:  return base.sorted { $0.name < $1.name }
        case .genre: return base.sorted { $0.genre < $1.genre }
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
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button {
                        viewModel.sortOrder = .name
                    } label: {
                        Label(R.string.localizable.viewsSortersArtist(), systemImage: viewModel.sortOrder == .name ? "checkmark" : "")
                    }
                    Button {
                        viewModel.sortOrder = .genre
                    } label: {
                        Label(R.string.localizable.viewsSortersGenre(), systemImage: viewModel.sortOrder == .genre ? "checkmark" : "")
                    }
                } label: {
                    Image(systemName: "arrow.up.arrow.down")
                        .resizable()
                        .frame(width: 20, height: 20)
                }
                .buttonStyle(.plain)
                .foregroundStyle(.primary)
                .frame(minWidth: Constants.minButtonWidth, minHeight: Constants.minButtonHeight)
            }
        }
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
