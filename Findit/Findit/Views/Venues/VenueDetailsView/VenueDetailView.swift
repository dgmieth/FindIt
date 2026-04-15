import SwiftUI

struct VenueDetailView: View {
    @StateObject private var viewModel: VenueDetailViewModel
    @State private var showFilters: Bool = false
    @State private var searchText: String = ""
    @State private var selectedPerformance: VenuePerformance?
    @State private var pendingVenueNavigation: Venue?
    @State private var venueToNavigate: Venue?
    
    init(venue: Venue) {
        self._viewModel = .init(wrappedValue: .init(venue: venue))
    }
    
    // MARK: - Testing Support
    init(viewModel: VenueDetailViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }

    init(viewModel: VenueDetailViewModel, searchText: String) {
        self._viewModel = StateObject(wrappedValue: viewModel)
        self._searchText = State(initialValue: searchText)
    }
    
    private var filteredVenuePerformances: [VenuePerformance] {
        let base = searchText.isEmpty ? viewModel.performances : viewModel.performances.filter {
            $0.artist.name.localizedCaseInsensitiveContains(searchText) ||
            $0.artist.genre.localizedStandardContains(searchText)
        }
        switch viewModel.sortOrder {
        // AC -> The performances must obviously be shown in order of date and time
        case .date:       return base.sorted { $0.parsedDate ?? .now < $1.parsedDate ?? .now }
        case .artistName: return base.sorted { $0.artist.name < $1.artist.name }
        case .genre:      return base.sorted { $0.artist.genre < $1.artist.genre }
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // ── Header ──
                VStack(spacing: 14) {
                    ImageView(url: self.viewModel.venue.imageURL, size: 160)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .shadow(radius: 6, y: 3)

                    Text(self.viewModel.venue.name)
                        .font(.title2.bold())
                        .multilineTextAlignment(.center)
                }
                .padding(.vertical, 24)

                Divider()

                // ── Performances ──
                LazyVStack(alignment: .leading, spacing: 0) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(self.viewModel.titleForResults)
                            .font(.headline)
                        
                        HStack(alignment: .center, spacing: 2) {
                            Text(self.filteredVenuePerformances.count.toString())
                                .font(.subheadline)
                            
                            Text(R.string.localizable.viewsVenuesDetailsPerformancesResultsCount(self.filteredVenuePerformances.count))
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.horizontal, Constants.horizontalPadding)
                    .padding(.top, 16)
                    .padding(.bottom, 8)

                    if viewModel.isLoading {
                        HStack { Spacer(); ProgressView(); Spacer() }
                            .padding()
                    } else if let message = viewModel.errorMessage {
                        Text(message)
                            .foregroundStyle(.red)
                            .padding()
                    } else if viewModel.performances.isEmpty {
                        ContentUnavailableView(
                            R.string.localizable.viewsVenuesDetailsPerformancesErrorNoData(),
                            systemImage: "calendar.badge.exclamationmark"
                        )
                        .padding()
                    } else {
                        ForEach(self.filteredVenuePerformances) { performance in
                            VenuePerformanceRow(performance: performance) {
                                self.selectedPerformance = performance
                            }
                            Divider().padding(.leading, 82)
                        }
                    }
                }
            }
        }
        .navigationTitle(self.viewModel.venue.name)
        .searchable(
            text: self.$searchText,
            placement: .navigationBarDrawer,
            prompt: Text(R.string.localizable.viewsVenuesDetailsSearchPlaceholder())
        )
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button {
                        viewModel.sortOrder = .date
                    } label: {
                        Label(R.string.localizable.viewsSortersDate(), systemImage: viewModel.sortOrder == .date ? "checkmark" : "")
                    }
                    Button {
                        viewModel.sortOrder = .artistName
                    } label: {
                        Label(R.string.localizable.viewsSortersArtist(), systemImage: viewModel.sortOrder == .artistName ? "checkmark" : "")
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
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    self.showFilters = true
                } label: {
                    Image(systemName: "line.3.horizontal.decrease.circle")
                        .resizable()
                        .frame(width: 20, height: 20)
                }
                .buttonStyle(.plain)
                .foregroundStyle(.primary)
                .contentShape(Rectangle())
                .frame(minWidth: Constants.minButtonWidth, minHeight: Constants.minButtonHeight)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .task { await viewModel.loadPerformances() }
        .navigationDestination(item: self.$venueToNavigate) { venue in
            VenueDetailView(venue: venue)
        }
        .sheet(item: self.$selectedPerformance, onDismiss: {
            if let venue = self.pendingVenueNavigation {
                self.venueToNavigate = venue
                self.pendingVenueNavigation = nil
            }
        }) { performance in
            CoVenuesSheetView(performance: performance, venueName: self.viewModel.venue.name) { venue in
                self.pendingVenueNavigation = venue
                self.selectedPerformance = nil
            }
            .presentationDetents([.medium])
            .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: self.$showFilters) {
            FilterView(
                filterOption: self.viewModel.filterSelection,
                startDate: self.viewModel.startDate,
                endDate: self.viewModel.endDate,
                onApply: self.viewModel.updateViewModel(_:_:_:)
            )
            .presentationDetents([.medium])
            .presentationDragIndicator(.visible)
        }
    }
}

// MARK: - Performance Row

private struct VenuePerformanceRow: View {
    let performance: VenuePerformance
    let onShowCoVenues: () -> Void

    var body: some View {
        HStack(spacing: 14) {
            ImageView(url: performance.artist.imageURL, size: 56)
                .clipShape(RoundedRectangle(cornerRadius: 10))

            VStack(alignment: .leading, spacing: 3) {
                Text(performance.artist.name)
                    .font(.headline)
                Text(performance.artist.genre)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                if let date = performance.parsedDate {
                    Text(date, format: .dateTime.weekday(.wide).month(.abbreviated).day())
                        .font(.subheadline)
                    Text(date, format: .dateTime.hour().minute())
                        .font(.caption)
                        .foregroundStyle(.secondary)
                } else {
                    Text(performance.date)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            Button(action: self.onShowCoVenues) {
                Image(systemName: "mappin.and.ellipse")
                    .font(.system(size: 16))
                    .foregroundStyle(.secondary)
                    .frame(minWidth: Constants.minButtonWidth, minHeight: Constants.minButtonHeight)
            }
            .buttonStyle(.plain)
            .contentShape(Rectangle())
        }
        .padding(.horizontal, Constants.horizontalPadding)
        .padding(.vertical, 10)
    }
}

#Preview {
    NavigationStack {
        VenueDetailView(venue: Venue(id: 7, name: "The Velvet Unicorn", sortId: 7))
    }
}
