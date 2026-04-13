import SwiftUI

struct VenueListView: View {
    @StateObject private var viewModel = VenueListViewModel()
    
    @State private var searchText: String = ""

    // MARK: - Testing Support
    init(viewModel: VenueListViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }

    init() {}
    
    private var filtereVenues: [Venue] {
        if searchText.isEmpty {
            return viewModel.venues
        }
        return viewModel.venues.filter {
            $0.name.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        Group {
            if viewModel.isLoading {
                ProgressView(R.string.localizable.viewsVenuesListsStateLoading())
            } else if let message = viewModel.errorMessage {
                ContentUnavailableView(
                    R.string.localizable.viewsVenuesListsStateError(),
                    systemImage: "exclamationmark.triangle",
                    description: Text(message)
                )
            } else {
                List(self.filtereVenues) { venue in
                    NavigationLink(destination: VenueDetailView(venue: venue)) {
                        VenueRowView(venue: venue)
                    }
                }
                .listStyle(.plain)
            }
        }
        .searchable(
            text: self.$searchText,
            placement: .navigationBarDrawer,
            prompt: Text(R.string.localizable.viewsVenuesListsSearchPlaceholder())
        )
        .navigationTitle(R.string.localizable.viewsVenuesListsNavBarTitle())
        .task { await viewModel.loadVenues() }
    }
}

// MARK: - Row

private struct VenueRowView: View {
    let venue: Venue

    var body: some View {
        HStack(spacing: 14) {
            ImageView(url: venue.imageURL, size: 56)
            
            Text(venue.name)
                .font(.headline)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    NavigationStack { VenueListView() }
}
