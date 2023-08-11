//
//  ImageLoaderViewModel.swift
//  EssentialFeediOS
//
//  Created by Sai Charan on 11/08/23.
//

import EssentialFeed

class FeedImageViewModel<Image> {
    private let model: FeedImage
    private let imageLoader: FeedImageDataLoader
    private var task: FeedImageDataLoaderTask?
    private let converter: (Data) -> Image?

    var onImageLoaded: Observer<Image>?
    var onImageLoadingStateChange: Observer<Bool>?
    var onShouldRetryStateChange: Observer<Bool>?

    var hasLocation: Bool { model.location == nil }
    var location: String? { model.location }
    var description: String? { model.description }

    init(model: FeedImage,imageLoader: FeedImageDataLoader, converter: @escaping (Data?) -> Image?) {
        self.model = model
        self.imageLoader = imageLoader
        self.converter = converter
    }

    func loadImage() {
        onImageLoadingStateChange?(true)
        onShouldRetryStateChange?(false)
        task = imageLoader.loadImageData(from: model.imageURL, completion: { [weak self] result in
            self?.handle(result)
        })
    }

    private func handle(_ result: Result<Data, Error>) {
        if let image = (try? result.get()).flatMap(converter) {
            self.onImageLoaded?(image)
        } else {
            onShouldRetryStateChange?(true)
        }
        onImageLoadingStateChange?(false)
    }

    func prefetchImage() {
        task = self.imageLoader.loadImageData(from: model.imageURL) { _ in }
    }

    func cancelTask() {
        task?.cancel()
    }
}
