//
//  ImageView.swift
//  Findit
//
//  Created by Diego Mieth on 2026-04-12.
//

import SwiftUI

struct ImageView: View {
    enum ImageViewState {
        case loading
        case idle
        case error
    }
    
    private let url: URL?
    private let size: CGFloat
    
    @State private var image: UIImage? = nil
    @State private var state: ImageViewState = .loading
    @Environment(\.testImageOverride) private var testImageOverride
    
    init(url: URL?, size: CGFloat) {
        self.url = url
        self.size = size
    }
    
    var body: some View {
        if let overrideImage = testImageOverride {
            Image(uiImage: overrideImage)
                .resizable()
                .scaledToFill()
                .frame(width: size, height: size)
                .clipped()
        } else {
            VStack(alignment: .center, spacing: 0) {
                switch self.state {
                case .loading:
                    ZStack {
                        Color.secondary.opacity(0.15)
                        ProgressView()
                    }
                case .idle:
                    Image(uiImage: self.image ?? UIImage())
                        .resizable()
                        .scaledToFit()
                case .error:
                    ZStack {
                        Color.secondary.opacity(0.15)
                        Image(systemName: "photo")
                            .foregroundStyle(.secondary)
                            .font(.title2)
                    }
                }
            }
            .frame(width: size, height: size)
            .task { await self.loadImage() }
        }
    }
    
    private func loadImage() async {
        guard let url else { return self.state = .error }
        
        guard let image = await Services.imageService.fetchImage(for: url)
        else {
            self.state = .error
            return
        }
        
        self.image = image
        
        withAnimation {
            self.state = .idle
        }
    }
}

// MARK: - Environment key for snapshot testing

private struct TestImageOverrideKey: EnvironmentKey {
    static let defaultValue: UIImage? = nil
}

extension EnvironmentValues {
    var testImageOverride: UIImage? {
        get { self[TestImageOverrideKey.self] }
        set { self[TestImageOverrideKey.self] = newValue }
    }
}
