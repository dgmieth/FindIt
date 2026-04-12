import SwiftUI

/// Reusable async image view with a rounded-rect clip and a placeholder.
struct EntityImageView: View {
    let url: URL?
    let size: CGFloat

    var body: some View {
        AsyncImage(url: url) { phase in
            switch phase {
            case .empty:
                ZStack {
                    Color.secondary.opacity(0.15)
                    ProgressView()
                }
            case .success(let image):
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            case .failure:
                ZStack {
                    Color.secondary.opacity(0.15)
                    Image(systemName: "photo")
                        .foregroundStyle(.secondary)
                        .font(.title2)
                }
            @unknown default:
                Color.secondary.opacity(0.15)
            }
        }
        .frame(width: size, height: size)
        .clipShape(RoundedRectangle(cornerRadius: size * 0.15))
    }
}

#Preview {
    EntityImageView(
        url: URL(string: "https://songleap.s3.amazonaws.com/venues/The+Velvet+Unicorn.png"),
        size: 100
    )
}
