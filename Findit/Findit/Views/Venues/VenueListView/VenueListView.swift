import SwiftUI

struct VenueListView: View {
    @StateObject private var viewModel = VenueListViewModel()
    @State private var searchText: String = ""

    // MARK: - Testing Support
    init(viewModel: VenueListViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }

    init(viewModel: VenueListViewModel, searchText: String) {
        self._viewModel = StateObject(wrappedValue: viewModel)
        self._searchText = State(initialValue: searchText)
    }

    init() {}
    
    private var filteredVenues: [Venue] {
        let base = searchText.isEmpty ? viewModel.venues : viewModel.venues.filter {
            $0.name.localizedCaseInsensitiveContains(searchText)
        }
        switch viewModel.sortOrder {
        // AC ->  Venues will be displayed in order of their sortId
        case .sortId: return base.sorted { $0.sortId < $1.sortId }
        case .name:   return base.sorted { $0.name < $1.name }
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
                List(self.filteredVenues) { venue in
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
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button {
                        viewModel.sortOrder = .sortId
                    } label: {
                        Label(R.string.localizable.viewsSortersDefault(), systemImage: viewModel.sortOrder == .sortId ? "checkmark" : "")
                    }
                    Button {
                        viewModel.sortOrder = .name
                    } label: {
                        Label(R.string.localizable.viewsSortersVenue(), systemImage: viewModel.sortOrder == .name ? "checkmark" : "")
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
