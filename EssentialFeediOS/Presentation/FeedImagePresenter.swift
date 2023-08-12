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

protocol FeedImageView<Image> {
    associatedtype Image
    func display(_ viewModel: FeedImageViewModel<Image>)
}

class FeedImagePresenter<View, Image> where View: FeedImageView, Image == View.Image {
    private let view: View
    private let imageTransformer: (Data) -> Image?

    init(view: View, imageTransformer: @escaping (Data) -> Image?) {
        self.view = view
        self.imageTransformer = imageTransformer
    }

    func didStartLoadingImage(for model: FeedImage) {
        view.display(FeedImageViewModel(location: model.location,
                                        description: model.description,
                                        image: nil,
                                        showRetry: false,
                                        isLoading: true))
    }

    private struct InvalidImageDataError: Error {}

    func didFinishLoadingImage(with data: Data, for model: FeedImage) {
        guard let image = imageTransformer(data) else {
            return didFinishLoadingImage(with: InvalidImageDataError(), for: model)
        }

        view.display(FeedImageViewModel(location: model.location,
                                        description: model.description,
                                        image: image,
                                        showRetry: false,
                                        isLoading: false))
    }

    func didFinishLoadingImage(with error: Error, for model: FeedImage) {
        view.display(FeedImageViewModel(location: model.location,
                                        description: model.description,
                                        image: nil,
                                        showRetry: true,
                                        isLoading: false))
    }
}
