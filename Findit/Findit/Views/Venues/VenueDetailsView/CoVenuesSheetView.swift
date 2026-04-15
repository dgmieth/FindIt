import SwiftUI

// MARK: - ViewModel

@MainActor
final class CoVenuesSheetViewModel: ObservableObject {
    @Published var performances: [ArtistPerformance] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    let artist: PerformanceArtist
    let venueName: String
    let from: Date
    let to: Date
    private let excludingVenueId: Int

    init(performance: VenuePerformance, venueName: String) {
        self.artist = performance.artist
        self.venueName = venueName
        let eventDate = performance.parsedDate ?? Date()
        let today = Date()
        let from = max(today, Calendar.current.date(byAdding: .day, value: -3, to: eventDate) ?? eventDate)
        self.from = from
        self.to = Calendar.current.date(byAdding: .day, value: 6, to: from) ?? from
        self.excludingVenueId = performance.venueId
    }

    // MARK: - Testing Support
    init(artist: PerformanceArtist, venueName: String = "Madison Square Garden", performances: [ArtistPerformance], isLoading: Bool = false, errorMessage: String? = nil, date: Date) {
        self.artist = artist
        self.venueName = venueName
        self.performances = performances
        self.isLoading = isLoading
        self.errorMessage = errorMessage
        self.from = date
        self.to = date
        self.excludingVenueId = -1
    }

    func load() async {
        self.isLoading = true
        self.errorMessage = nil

        do {
            let all = try await Services.artistService.fetchArtistPerformances(
                artistId: self.artist.id,
                from: self.from,
                to: self.to
            )
            self.performances = all
                .filter { $0.venue.id != self.excludingVenueId }
                .sorted { $0.parsedDate ?? .now < $1.parsedDate ?? .now }
        } catch {
            self.errorMessage = error.localizedDescription
        }
        self.isLoading = false
    }
}

// MARK: - View

struct CoVenuesSheetView: View {
    @StateObject private var viewModel: CoVenuesSheetViewModel
    let onSelect: (Venue) -> Void

    init(performance: VenuePerformance, venueName: String, onSelect: @escaping (Venue) -> Void) {
        self._viewModel = StateObject(wrappedValue: CoVenuesSheetViewModel(performance: performance, venueName: venueName))
        self.onSelect = onSelect
    }

    // MARK: - Testing Support
    init(viewModel: CoVenuesSheetViewModel, onSelect: @escaping (Venue) -> Void = { _ in }) {
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
                        R.string.localizable.viewsCoVenuesStateEmpty(),
                        systemImage: "mappin.slash",
                        description: Text(R.string.localizable.viewsCoVenuesStateEmptyExplanation())
                    )
                } else {
                    List(self.viewModel.performances) { performance in
                        let venue = Venue(
                            id: performance.venue.id,
                            name: performance.venue.name,
                            sortId: performance.venue.sortId
                        )
                        Button { self.onSelect(venue) } label: {
                            CoVenueRow(performance: performance)
                        }
                        .buttonStyle(.plain)
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle(self.viewModel.venueName)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    VStack(spacing: 1) {
                        Text(self.viewModel.venueName)
                            .font(.headline)
                        Text(R.string.localizable.viewsCoVenuesSubtitle(
                            self.viewModel.from.formatted(.dateTime.day().month(.abbreviated)),
                            self.viewModel.to.formatted(.dateTime.day().month(.abbreviated))
                        ))
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

private struct CoVenueRow: View {
    let performance: ArtistPerformance

    var body: some View {
        HStack(spacing: 14) {
            ImageView(url: performance.venue.imageURL, size: 48)
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
        .frame(maxWidth: .infinity)
        .padding(.vertical, 4)
        .contentShape(Rectangle())
    }
}
