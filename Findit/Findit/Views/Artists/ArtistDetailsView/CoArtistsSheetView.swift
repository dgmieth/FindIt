import SwiftUI

// MARK: - ViewModel

@MainActor
final class CoArtistsSheetViewModel: ObservableObject {
    @Published var performances: [VenuePerformance] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    let venue: PerformanceVenue
    private let date: Date
    private let excludingArtistId: Int

    init(performance: ArtistPerformance) {
        self.venue = performance.venue
        self.date = performance.parsedDate ?? Date()
        self.excludingArtistId = performance.artistId
    }

    // MARK: - Testing Support
    init(venue: PerformanceVenue, performances: [VenuePerformance], isLoading: Bool = false, errorMessage: String? = nil) {
        self.venue = venue
        self.performances = performances
        self.isLoading = isLoading
        self.errorMessage = errorMessage
        self.date = Date()
        self.excludingArtistId = -1
    }

    func load() async {
        self.isLoading = true
        self.errorMessage = nil
        do {
            let all = try await Services.venueService.fetchVenuePerformances(
                venueId: self.venue.id,
                from: self.date,
                to: self.date
            )
            self.performances = all
                .filter { $0.artist.id != self.excludingArtistId }
                .sorted { $0.parsedDate ?? .now < $1.parsedDate ?? .now }
        } catch {
            self.errorMessage = error.localizedDescription
        }
        self.isLoading = false
    }
}

// MARK: - View

struct CoArtistsSheetView: View {
    @StateObject private var viewModel: CoArtistsSheetViewModel
    let onSelect: (Artist) -> Void

    init(performance: ArtistPerformance, onSelect: @escaping (Artist) -> Void) {
        self._viewModel = StateObject(wrappedValue: CoArtistsSheetViewModel(performance: performance))
        self.onSelect = onSelect
    }

    // MARK: - Testing Support
    init(viewModel: CoArtistsSheetViewModel, onSelect: @escaping (Artist) -> Void = { _ in }) {
        self._viewModel = StateObject(wrappedValue: viewModel)
        self.onSelect = onSelect
    }

    var body: some View {
        NavigationStack {
            Group {
                if self.viewModel.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let message = self.viewModel.errorMessage {
                    ContentUnavailableView(message, systemImage: "exclamationmark.triangle")
                } else if self.viewModel.performances.isEmpty {
                    ContentUnavailableView(
                        R.string.localizable.viewsCoArtistsStateEmpty(),
                        systemImage: "person.slash",
                        description: Text(R.string.localizable.viewsCoArtistsStateEmptyExplanation())
                    )
                } else {
                    List(self.viewModel.performances) { performance in
                        let artist = Artist(
                            id: performance.artist.id,
                            name: performance.artist.name,
                            genre: performance.artist.genre
                        )
                        Button { self.onSelect(artist) } label: {
                            CoArtistRow(performance: performance)
                        }
                        .buttonStyle(.plain)
                    }
                    .listStyle(.plain)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    VStack(spacing: 1) {
                        Text(self.viewModel.venue.name)
                            .font(.headline)
                        Text(R.string.localizable.viewsCoArtistsSubtitle())
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .task { await self.viewModel.load() }
    }
}

// MARK: - Row

private struct CoArtistRow: View {
    let performance: VenuePerformance

    var body: some View {
        HStack(spacing: 14) {
            ImageView(url: performance.artist.imageURL, size: 48)
                .clipShape(RoundedRectangle(cornerRadius: 10))

            VStack(alignment: .leading, spacing: 3) {
                Text(performance.artist.name)
                    .font(.headline)
                Text(performance.artist.genre)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                if let date = performance.parsedDate {
                    Text(date, format: .dateTime.hour().minute())
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 4)
        .contentShape(Rectangle())
    }
}
