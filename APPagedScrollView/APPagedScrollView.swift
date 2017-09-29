//
//  APPagedScrollView.swift
//
//  Created by Ayden P on 2017-03-10.
//  Copyright © 2017 Ayden P. All rights reserved.
//

import UIKit

/// The main paged scroll view class, which allows for an automatic layout of the content provided by the data source and delegates.
open class APPagedScrollView: UIScrollView, UIScrollViewDelegate {
    /// A data source for the paging scroll view.
    weak public var dataSource: APPagedScrollViewDataSource?
    /// The delegate to use for APPagedScrollView events.
    weak public var pagingDelegate: APPagedScrollViewDelegate?
    private var stackView: UIStackView!, previousPage: Int?
    /// Where to send normal UIScrollView events.
    var receivingDelegate: UIScrollViewDelegate?
    private var pageToLoad: Int?, hasLoaded = false
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        initializeProperties()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initializeProperties()
    }
    
    private func initializeProperties() {
        // Initial properties
        super.delegate = self
        translatesAutoresizingMaskIntoConstraints = false
        isDirectionalLockEnabled = true
        isPagingEnabled = true
        showsVerticalScrollIndicator = false
        showsHorizontalScrollIndicator = false
        bounces = true
        alwaysBounceHorizontal = true
        alwaysBounceVertical = false
        
        stackView = UIStackView(frame: bounds)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.alignment = .leading
        addSubview(stackView)
        stackView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        stackView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        stackView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        stackView.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor).isActive = true
        stackView.autoresizingMask = [.flexibleHeight, .flexibleWidth]

        // Load initial data
        reloadData()
    }
    
    // MARK: - Public Functions and Accessors
    
    /**
     Align the current page of the scroll view to the closest or most appropriate one.
     
     If you have a view controller that could rotate, implement this method in your UIViewController's viewWillTransition(to:, with:) and pass along the coordinator so that we can adjust the scroll view's page for rotations.
     
     - parameter coordinator: Specify a transition coordinator to animate alongside, making it look seamless for events like device rotations or animated view size changes.
     */
    public func alignScrollView(with coordinator: UIViewControllerTransitionCoordinator? = nil) {
        if let coordinator = coordinator {
            // If this is an alignment with a coordinator, record the page index before the transition
            let previousPageIndex = currentPageIndex
            coordinator.animate(alongsideTransition: { _ in
                // and then we can scroll to that same one with the coordinator's animation
                self.scroll(to: previousPageIndex, animated: false)
            }, completion: nil)
        } else {
            // If we don't have a coordinator, just align the scroll view to its best known index
            self.scroll(to: currentPageIndex, animated: true)
        }
    }
    
    /// Reloads the pages of the scroll view.
    public func reloadData() {
        // Remove all past page views
        for subview in stackView.arrangedSubviews {
            subview.removeFromSuperview()
            stackView.removeArrangedSubview(subview)
        }
        
        // Get our page views as an array
        let contentViews = getPageViewArray()
        
        if contentViews.count > 0 {
            for view in contentViews {
                stackView.addArrangedSubview(view)
                view.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
                view.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
            }
            
            // Set content size
            contentSize = CGSize(width: bounds.width * CGFloat(contentViews.count), height: bounds.height)
            
            if let index = pageToLoad {
                contentOffset = location(of: index)
            }
            pageChanged(to: currentPageIndex)
            hasLoaded = true
        } else {
            // Set content size
            contentSize = CGSize(width: bounds.width, height: bounds.height)
        }
    }
    
    /// The index of the current page.
    public var currentPageIndex: Int {
        get {
            // Get current page by dividing scroll view position by page width
            let pageWidth = bounds.width
            guard pageWidth != 0 else { return 0 }
            return Int(floor((contentOffset.x - pageWidth / 2) / pageWidth) + 1)
        }
        set(index) {
            if hasLoaded {
                scroll(to: index, animated: true)
            } else {
                pageToLoad = index
            }
        }
    }
    
    /// The number of pages within this scroll view.
    public var numberOfPages: Int {
        return dataSource?.numberOfPages(in: self) ?? 0
    }
    
    /// Whether or not to have movedTo: events include elastic scrolling
    public var elasticScrollingEvents = false
    
    /// Access all the loaded page views
    public var loadedPageViews: [UIView] {
        return stackView.arrangedSubviews
    }
    
    /**
     Scrolls to the page with the provided index.
     
     - parameter index: The index of the page to scroll to.
     - parameter animated: Whether or not to animate this change.
     */
    public func scroll(to index: Int, animated: Bool) {
        let rect = CGRect(origin: location(of: index), size: bounds.size)
        scrollRectToVisible(rect, animated: animated)
    }
    
    /// Whether or not the scroll view is currently in a position to go forward
    public var canGoForward: Bool {
        return currentPageIndex + 1 <= numberOfPages - 1
    }
    
    /// Whether or not the scroll view is currently in a position to go back
    public var canGoBack: Bool {
        return currentPageIndex - 1 >= 0
    }
    
    /// Scroll forward one page, if possible.
    public func goForward(animated: Bool = true) {
        if canGoForward {
            scroll(to: currentPageIndex + 1, animated: animated)
        }
    }
    
    /// Scroll back one page, if possible.
    public func goBack(animated: Bool = true) {
        if canGoBack {
            scroll(to: currentPageIndex - 1, animated: animated)
        }
    }
    
    // MARK: - Useful internal functions
    
    private func location(of page: Int) -> CGPoint {
        let pageWidth = Int(bounds.width)
        let offset = pageWidth * page
        return CGPoint(x: offset, y: 0)
    }
    
    private func getPageViewArray() -> [UIView] {
        var pagesArray = [UIView]()
        for index in 0..<numberOfPages {
            pagesArray.append(view(forPageAt: index))
        }
        return pagesArray
    }
    
    // MARK: - Internal Data Source Accessors & Delegate Functions
    
    // Easy method to get view from data source and respond accordingly to lack of one
    private func view(forPageAt index: Int) -> UIView {
        guard let dataSource = dataSource else { fatalError("APPagedScrollView requires that there be a data source which can provide page views") }
        return dataSource.view(forPageAt: index, in: self)
    }
    
    // Internal callback for changed pages
    private func pageChanged(to index: Int) {
        if index != previousPage {
            pagingDelegate?.pagedScrollView(self, movedTo: index, from: previousPage)
        }
        previousPage = index
    }
    
    // MARK: - Scroll View Delegate
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        receivingDelegate?.scrollViewDidScroll?(scrollView)
        let closestPage = self.location(of: Int(floor(contentOffset.x / bounds.width))).x
        let closestPageIndex = Int(closestPage / bounds.size.width)
        let progress = (contentOffset.x - closestPage) / bounds.size.width
        if contentOffset.x.truncatingRemainder(dividingBy: bounds.width) == 0 {
            pagingDelegate?.pagedScrollView(self, movedTo: closestPageIndex, from: nil)
        }
        if (contentOffset.x >= 0 && contentOffset.x <= contentSize.width - bounds.width) || elasticScrollingEvents {
            pagingDelegate?.pagedScrollView(self, movingTo: closestPageIndex + 1, from: closestPageIndex, progress: progress)
        }
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        receivingDelegate?.scrollViewDidEndDecelerating?(scrollView)
        pageChanged(to: Int(contentOffset.x / bounds.width))
    }
    
    public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        receivingDelegate?.scrollViewDidEndScrollingAnimation?(scrollView)
        pageChanged(to: Int(contentOffset.x / bounds.width))
    }
    
    // MARK: - Proxy for Other Scroll View Delegate Methods
    // Zooming methods are intentionally left out as they are not supported with our paged scroll view
    
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        receivingDelegate?.scrollViewWillBeginDragging?(scrollView)
    }
    
    public func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        receivingDelegate?.scrollViewWillEndDragging?(scrollView, withVelocity: velocity, targetContentOffset: targetContentOffset)
    }
    
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        receivingDelegate?.scrollViewDidEndDragging?(scrollView, willDecelerate: decelerate)
    }
    
    public func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool {
        return receivingDelegate?.scrollViewShouldScrollToTop?(scrollView) ?? true
    }
    
    public func scrollViewDidScrollToTop(_ scrollView: UIScrollView) {
        receivingDelegate?.scrollViewDidScrollToTop?(scrollView)
    }
    
    public func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        receivingDelegate?.scrollViewWillBeginDecelerating?(scrollView)
    }
}

public protocol APPagedScrollViewDataSource: class {
    /**
     Asks the data source to return the number of pages in the scroll view.
     
     - parameter pagedScrollView: The scroll view to return the amount of pages for.
     
     - returns: The number of pages in the scroll view.
     */
    func numberOfPages(in pagedScrollView: APPagedScrollView) -> Int
    
    /**
     Asks the data source to return the page view for the provided index in the scroll view.
     
     - parameter index: The index of the page view to return.
     - parameter pagedScrollView: The scroll view to return the amount of pages for.
     
     - returns: The page view for the provided index in the scroll view.
     */
    func view(forPageAt index: Int, in pagedScrollView: APPagedScrollView) -> UIView
}

public protocol APPagedScrollViewDelegate: class {
    /**
     Called when the scroll view has moved to a new page.
     
     - parameter pagedScrollView: The scroll view that has moved.
     - parameter index: The index of the page that the scroll view has moved to.
     */
    func pagedScrollView(_ pagedScrollView: APPagedScrollView, movedTo index: Int, from oldIndex: Int?)
    
    /**
     Called during the transition between two pages inside the scroll view.
     
     - parameter pagedScrollView: The scroll view that has moved.
     - parameter newIndex: The index of the page that the scroll view is moving to.
     - parameter oldIndex: The index of the page that the scroll view is moving from.
     - parameter progress: The progress of the transition as a value from 0.0 to 1.0.
     */
    func pagedScrollView(_ pagedScrollView: APPagedScrollView, movingTo index: Int, from oldIndex: Int, progress: CGFloat)
}


