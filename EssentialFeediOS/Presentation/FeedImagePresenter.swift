//
//  FeedImagePresenter.swift
//  EssentialFeediOS
//
//  Created by Sai Charan on 12/08/23.
//

import EssentialFeed

struct FeedImageViewModel<Image> {
    var location: String?
    var description: String?
    var image: Image?
    var showRetry: Bool
    var isLoading: Bool
}

protocol FeedImageView<Image>: AnyObject {
    associatedtype Image
    func display(_ viewModel: FeedImageViewModel<Image>)
}

class FeedImagePresenter<View, Image> where View: FeedImageView, Image == View.Image {
    private let model: FeedImage
    private let imageLoader: FeedImageDataLoader
    private var task: FeedImageDataLoaderTask?
    private let imageTransformer: (Data) -> Image?

    weak var view: View?

    init(model: FeedImage, imageLoader: FeedImageDataLoader, imageTransformer: @escaping (Data) -> Image?) {
        self.model = model
        self.imageLoader = imageLoader
        self.imageTransformer = imageTransformer
    }

    func didStartLoadingImage() {
        view?.display(FeedImageViewModel(location: model.location,
                                         description: model.description,
                                         image: nil,
                                         showRetry: false,
                                         isLoading: true))
    }

    func didLoadImage(_ image: Image) {
        view?.display(FeedImageViewModel(location: model.location,
                                         description: model.description,
                                         image: image,
                                         showRetry: false,
                                         isLoading: false))
    }

    func didFailToLoadImage() {
        view?.display(FeedImageViewModel(location: model.location,
                                         description: model.description,
                                         image: nil,
                                         showRetry: true,
                                         isLoading: false))
    }

    func loadImage() {
        didStartLoadingImage()
        task = imageLoader.loadImageData(from: model.imageURL, completion: { [weak self] result in
            self?.handle(result)
        })
    }

    private func handle(_ result: Result<Data, Error>) {
        if let image = (try? result.get()).flatMap(imageTransformer) {
            didLoadImage(image)
        } else {
            didFailToLoadImage()
        }
    }

    func prefetchImage() {
        task = self.imageLoader.loadImageData(from: model.imageURL) { _ in }
    }

    func cancelTask() {
        task?.cancel()
    }
}

extension FeedImagePresenter: FeedImageCellPresenter { }
