import SwiftUI

struct ArtistDetailView: View {
    @StateObject private var viewModel: ArtistDetailViewModel
    @State private var showFilters: Bool = false
    @State private var searchText: String = ""
    
    init(artist: Artist) {
        self._viewModel = .init(wrappedValue: .init(artist: artist))
    }

    // MARK: - Testing Support
    init(viewModel: ArtistDetailViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }

    init(viewModel: ArtistDetailViewModel, searchText: String) {
        self._viewModel = StateObject(wrappedValue: viewModel)
        self._searchText = State(initialValue: searchText)
    }
    
    private var filteredArtistPerformances: [ArtistPerformance] {
        if searchText.isEmpty {
            return viewModel.performances
        }
        return viewModel.performances.filter {
            $0.venue.name.localizedCaseInsensitiveContains(self.searchText)
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // ── Header ──
                VStack(spacing: 14) {
                    ImageView(url: self.viewModel.artist.imageURL, size: 160)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .shadow(radius: 6, y: 3)
                    
                    VStack(spacing: 4) {
                        Text(self.viewModel.artist.name)
                            .font(.title2.bold())
                            .multilineTextAlignment(.center)
                        Text(self.viewModel.artist.genre)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.vertical, 24)
                
                Divider()
                
                // ── Performances ──
                LazyVStack(alignment: .leading, spacing: 0) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(self.viewModel.titleForResults)
                            .font(.headline)
                        
                        HStack(alignment: .center, spacing: 2) {
                            Text(self.filteredArtistPerformances.count.toString())
                                .font(.subheadline)
                            
                            Text(R.string.localizable.viewsArtistsDetailsPerformancesResultsCount(self.filteredArtistPerformances.count))
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.horizontal)
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
                            R.string.localizable.viewsArtistsDetailsPerformancesErrorNoData(),
                            systemImage: "calendar.badge.exclamationmark"
                        )
                        .padding()
                    } else {
                        ForEach(self.filteredArtistPerformances) { performance in
                            ArtistPerformanceRow(performance: performance)
                            Divider().padding(.leading, 82)
                        }
                    }
                }
            }
        }
        .navigationTitle(self.viewModel.artist.name)
        .searchable(
            text: self.$searchText,
            placement: .navigationBarDrawer,
            prompt: Text(R.string.localizable.viewsArtistsDetailsSearchPlaceholder())
        )
        .toolbar {
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
                .frame(minWidth: 44, minHeight: 44)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .task { await viewModel.loadPerformances() }
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

private struct ArtistPerformanceRow: View {
    let performance: ArtistPerformance
    
    var body: some View {
        HStack(spacing: 14) {
            ImageView(url: performance.venue.imageURL, size: 56)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            
            VStack(alignment: .leading, spacing: 3) {
                Text(performance.venue.name)
                    .font(.headline)
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
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
    }
}

#Preview {
    NavigationStack {
        ArtistDetailView(artist: Artist(id: 1, name: "Vomit Spots", genre: "Punk"))
    }
}
