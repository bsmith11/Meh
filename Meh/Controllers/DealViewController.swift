//
//  DealViewController.swift
//  Meh
//
//  Created by Bradley Smith on 3/2/16.
//  Copyright © 2016 Brad Smith. All rights reserved.
//

import UIKit
import SafariServices
import pop

typealias AnimationCompletion = (Bool) -> Void

class DealViewController: UIViewController {
    private let viewModel: DealViewModel
    private let collectionView: ControlContainableCollectionView

    private var selectedPhotoHeaderView: PhotosHeaderView?
    private var selectedMediaCell: MediaCell?
    private var didAppear = false
    private var animationsComplete = false

    override func prefersStatusBarHidden() -> Bool {
        return true
    }

    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return .Portrait
    }

    init(viewModel: DealViewModel) {
        self.viewModel = viewModel

        let layout = DealCollectionViewLayout()
        collectionView = ControlContainableCollectionView(frame: .zero, collectionViewLayout: layout)

        super.init(nibName: nil, bundle: nil)

        layout.delegate = self
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = UIView()
        view.backgroundColor = UIColor.whiteColor()

        configureViews()
        configureLayout()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.collectionView.alpha = 0.0
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        if !didAppear {
            didAppear = true

            dispatch_async(dispatch_get_main_queue(), {
                self.displayContentAnimated(true)
            })
        }
    }
}

// MARK: - Private

private extension DealViewController {
    func configureViews() {
        collectionView.backgroundColor = UIColor.clearColor()
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.showsVerticalScrollIndicator = false
        collectionView.alwaysBounceVertical = true
        collectionView.delaysContentTouches = false
        collectionView.registerClass(MediaCell.self)
        collectionView.registerClass(ParagraphCell.self)
        collectionView.registerClass(PhotosHeaderView.self, elementKind: DealCollectionViewLayout.photosHeaderElementKind)
        collectionView.registerClass(TitleHeaderView.self, elementKind: DealCollectionViewLayout.titleHeaderElementKind)
        collectionView.registerClass(BuyHeaderView.self, elementKind: DealCollectionViewLayout.buyHeaderElementKind)
        collectionView.registerClass(FooterView.self, elementKind: DealCollectionViewLayout.footerElementKind)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionView)
    }

    func configureLayout() {
        let constraints: [NSLayoutConstraint] = [
            collectionView.topAnchor.constraintEqualToAnchor(view.topAnchor),
            collectionView.leadingAnchor.constraintEqualToAnchor(view.leadingAnchor),
            view.trailingAnchor.constraintEqualToAnchor(collectionView.trailingAnchor),
            view.bottomAnchor.constraintEqualToAnchor(collectionView.bottomAnchor)
        ]

        NSLayoutConstraint.activateConstraints(constraints)
    }

    func displayContentAnimated(animated: Bool) {
        let animations = {
            self.view.backgroundColor = self.viewModel.deal?.theme.backgroundColor ?? UIColor.whiteColor()
        }

        let completion = { (finished: Bool) in
            var contentOffset = self.collectionView.contentOffset
            let titleHeaderViewModel = TitleHeaderViewModel(deal: self.viewModel.deal)

            contentOffset.y = -TitleHeaderView.heightWithViewModel(titleHeaderViewModel, width: self.collectionView.bounds.width)
            self.collectionView.setContentOffset(contentOffset, animated: false)

            let indexPath = NSIndexPath(forItem: 0, inSection: 0)
            let photosHeaderView = self.collectionView.supplementaryViewForElementKind(DealCollectionViewLayout.photosHeaderElementKind, atIndexPath: indexPath) as? PhotosHeaderView

            dispatch_async(dispatch_get_main_queue(), {
                self.collectionView.alpha = 1.0
                self.bounceContentOffsetWithCompletion({ [weak self] (finished: Bool) in
                    self?.animationsComplete = true
                })

                photosHeaderView?.showPageControlAnimated(true)
            })
        }

        UIView.animateWithDuration(0.75, animations: animations, completion: completion)
    }

    func bounceContentOffsetWithCompletion(completion: AnimationCompletion?) {
        let bounceAnimation = POPSpringAnimation(propertyNamed: kPOPCollectionViewContentOffset)
        bounceAnimation.toValue = NSValue(CGPoint: .zero)
        bounceAnimation.velocity = NSValue(CGPoint: CGPoint(x: 0.0, y: 100.0))
        bounceAnimation.springBounciness = 20.0
        bounceAnimation.springSpeed = 5.0
        bounceAnimation.completionBlock = { (animation: POPAnimation?, finished: Bool) in
            completion?(finished)
        }

        collectionView.pop_addAnimation(bounceAnimation, forKey: "bounce")
    }

    func handleURL(URL: NSURL) {
        let safariViewController = SFSafariViewController(URL: URL)
        presentViewController(safariViewController, animated: true, completion: nil)
    }
}

// MARK: - UICollectionViewDataSource

extension DealViewController: UICollectionViewDataSource {
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return viewModel.numberOfSections()
    }

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.numberOfItemsInSection(section)
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        guard let item = viewModel.itemAtIndexPath(indexPath) else {
            preconditionFailure("Item is nil")
        }

        let linkHandler: LinkHandlerBlock = { [weak self] (URL: NSURL) in
            self?.handleURL(URL)
        }

        switch item {
        case .Features:
            let featuresViewModel = FeaturesViewModel(deal: viewModel.deal)
            let cell: ParagraphCell = collectionView.dequeueCellForIndexPath(indexPath)
            cell.configureWithViewModel(featuresViewModel)
            cell.linkHandler = linkHandler

            return cell
        case .Specs:
            let specsViewModel = SpecsViewModel(deal: viewModel.deal)
            let cell: ParagraphCell = collectionView.dequeueCellForIndexPath(indexPath)
            cell.configureWithViewModel(specsViewModel)

            return cell
        case .Video(let videoURL):
            let videoViewModel = VideoViewModel(videoURL: videoURL, theme: viewModel.deal?.theme)
            let cell: MediaCell = collectionView.dequeueCellForIndexPath(indexPath)
            cell.configureWithViewModel(videoViewModel)

            return cell
        case .Story:
            let storyViewModel = StoryViewModel(deal: viewModel.deal)
            let cell: ParagraphCell = collectionView.dequeueCellForIndexPath(indexPath)
            cell.configureWithViewModel(storyViewModel)
            cell.linkHandler = linkHandler

            return cell
        case .Paragraph(let String):
            let paragraphViewModel = ParagraphViewModel(paragraph: String, theme: viewModel.deal?.theme)
            let cell: ParagraphCell = collectionView.dequeueCellForIndexPath(indexPath)
            cell.configureWithViewModel(paragraphViewModel)
            cell.linkHandler = linkHandler

            return cell
        }
    }

    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        switch kind {
        case DealCollectionViewLayout.photosHeaderElementKind:
            let header: PhotosHeaderView = collectionView.dequeueSupplementaryViewForElementKind(kind, indexPath: indexPath)
            let photosHeaderViewModel = PhotosHeaderViewModel(deal: viewModel.deal)
            header.configureWithViewModel(photosHeaderViewModel)
            header.delegate = self

            return header
        case DealCollectionViewLayout.titleHeaderElementKind:
            let header: TitleHeaderView = collectionView.dequeueSupplementaryViewForElementKind(kind, indexPath: indexPath)
            let titleHeaderViewModel = TitleHeaderViewModel(deal: viewModel.deal)
            header.configureWithViewModel(titleHeaderViewModel)

            return header
        case DealCollectionViewLayout.buyHeaderElementKind:
            let header: BuyHeaderView = collectionView.dequeueSupplementaryViewForElementKind(kind, indexPath: indexPath)
            let buyHeaderViewModel = BuyHeaderViewModel(deal: viewModel.deal)
            header.configureWithViewModel(buyHeaderViewModel)
            header.delegate = self

            return header
        case DealCollectionViewLayout.footerElementKind:
            let footer: FooterView = collectionView.dequeueSupplementaryViewForElementKind(kind, indexPath: indexPath)
            footer.configureWithTheme(viewModel.deal?.theme ?? Theme())

            return footer
        default:
            preconditionFailure("Invalid element kind")
        }
    }
}

// MARK: - UICollectionViewDelegate

extension DealViewController: UICollectionViewDelegate {
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if let item = viewModel.itemAtIndexPath(indexPath) {
            switch item {
            case .Specs:
                let specsViewModel = SpecsViewModel(deal: viewModel.deal)
                let specsViewController = SpecsViewController(viewModel: specsViewModel)

                presentViewController(specsViewController, animated: true, completion: nil)
            case .Video(let videoURL):
                if let cell = collectionView.cellForItemAtIndexPath(indexPath) as? MediaCell {
                    selectedMediaCell = cell

                    let originalRect = view.convertRect(cell.imageViewFrame, fromView: cell.imageViewSuperview)
                    let videoViewModel = VideoViewModel(videoURL: videoURL, theme: viewModel.deal?.theme)
                    let videoViewController = VideoViewController(viewModel: videoViewModel, originalRect: originalRect)
                    videoViewController.delegate = self

                    presentViewController(videoViewController, animated: true, completion: nil)
                }
            default:
                break
            }
        }
    }

    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        collectionView.pop_removeAnimationForKey("bounce")
    }
}

// MARK: - DealCollectionViewLayoutDelegate

extension DealViewController: DealCollectionViewLayoutDelegate {
    func collectionView(collectionView: UICollectionView, heightForItemAtIndexPath indexPath: NSIndexPath, width: CGFloat) -> CGFloat {
        guard let item = viewModel.itemAtIndexPath(indexPath) else {
            preconditionFailure("Item is nil")
        }

        switch item {
        case .Features:
            let featuresViewModel = FeaturesViewModel(deal: viewModel.deal)

            return ParagraphCell.heightWithViewModel(featuresViewModel, width: width)
        case .Specs:
            let specsViewModel = SpecsViewModel(deal: viewModel.deal)

            return ParagraphCell.heightWithViewModel(specsViewModel, width: width)
        case .Video:
            return MediaCell.height()
        case .Story:
            let storyViewModel = StoryViewModel(deal: viewModel.deal)

            return ParagraphCell.heightWithViewModel(storyViewModel, width: width)
        case .Paragraph(let string):
            let paragraphViewModel = ParagraphViewModel(paragraph: string, theme: viewModel.deal?.theme)

            return ParagraphCell.heightWithViewModel(paragraphViewModel, width: width)
        }
    }

    func collectionView(collectionView: UICollectionView, sizeForSupplementaryViewOfKind kind: String, width: CGFloat) -> CGSize {
        switch kind {
        case DealCollectionViewLayout.photosHeaderElementKind:
            let photosHeaderViewModel = PhotosHeaderViewModel(deal: viewModel.deal)
            let height = PhotosHeaderView.heightWithViewModel(photosHeaderViewModel, width: width)

            return CGSize(width: width, height: height)
        case DealCollectionViewLayout.titleHeaderElementKind:
            let titleHeaderViewModel = TitleHeaderViewModel(deal: viewModel.deal)
            let height = TitleHeaderView.heightWithViewModel(titleHeaderViewModel, width: width)

            return CGSize(width: width, height: height)
        case DealCollectionViewLayout.buyHeaderElementKind:
            let buyHeaderViewModel = BuyHeaderViewModel(deal: viewModel.deal)

            return BuyHeaderView.sizeWithViewModel(buyHeaderViewModel)
        default:
            return .zero
        }
    }
}

// MARK: - PhotosHeaderViewDelegate

extension DealViewController: PhotosHeaderViewDelegate {
    func photosHeaderView(headerView: PhotosHeaderView, didSelectPhotoWithURL URL: NSURL, rect: CGRect) {
        selectedPhotoHeaderView = headerView

        let originalRect = view.convertRect(rect, fromView: view.window)
        let imageViewController = ImageViewController(URL: URL, originalRect: originalRect)
        imageViewController.delegate = self

        presentViewController(imageViewController, animated: true, completion: nil)
    }
}

// MARK: - BuyHeaderViewDelegate

extension DealViewController: BuyHeaderViewDelegate {
    func buyHeaderViewDidSelectBuy(headerView: BuyHeaderView) {
        if viewModel.deal?.soldOutDate == nil {
            if let URL = viewModel.deal?.URL {
                let rect = view.convertRect(headerView.frame, fromView: headerView.superview)
                let webViewController = WebViewController(rect: rect, URL: URL)

                presentViewController(webViewController, animated: true, completion: nil)
            }
        }
        else {
            let indexPath = NSIndexPath(forItem: 0, inSection: 0)
            if let titleHeaderView = collectionView.supplementaryViewForElementKind(DealCollectionViewLayout.titleHeaderElementKind, atIndexPath: indexPath) as? TitleHeaderView {
                titleHeaderView.bounceTitle()
            }
        }
    }
}

// MARK: - FocusableViewControllerDelegate

extension DealViewController: FocusableViewControllerDelegate {
    func viewControllerWillStartPresentAnimation(imageViewController: UIViewController) {
        if let photoHeaderView = selectedPhotoHeaderView {
            photoHeaderView.hideSelectedCell()
        }
        else if let mediaCell = selectedMediaCell {
            mediaCell.showSubviews(false, animated: false)
        }
    }

    func viewControllerDidFinishDismissAnimation(imageViewController: UIViewController) {
        if let photoHeaderView = selectedPhotoHeaderView {
            photoHeaderView.showSelectedCell()
            selectedPhotoHeaderView = nil
        }
        else if let mediaCell = selectedMediaCell {
            mediaCell.showSubviews(true, animated: true)
            selectedMediaCell = nil
        }
    }
}
