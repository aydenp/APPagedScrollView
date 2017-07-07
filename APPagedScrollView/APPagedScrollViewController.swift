//
//  APPagedScrollViewController.swift
//
//  Created by Ayden P on 2017-03-13.
//  Copyright © 2017 Ayden P. All rights reserved.
//

import UIKit

public class APPagedScrollViewController: UIViewController, APPagedScrollViewDelegate, APPagedScrollViewDataSource {
    var scrollView = APPagedScrollView()
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        scrollView.frame = view.bounds
        scrollView.pagingDelegate = self
        scrollView.dataSource = self
        view.addSubview(scrollView)
        if attachScrollViewToTopLayoutGuide {
            scrollView.translatesAutoresizingMaskIntoConstraints = false
            scrollView.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor).isActive = true
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        } else {
            scrollView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        }
    }
    
    override public func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        alignScrollView(with: coordinator)
    }
    
    // MARK: - Public Functions and Accessors
    
    /**
     Align the current page of the scroll view to the closest or most appropriate one.
     
     If you have a view controller that could rotate, implement this method in your UIViewController's viewWillTransition(to:, with:) and pass along the coordinator so that we can adjust the scroll view's page for rotations.
     
     - parameter coordinator: Specify a transition coordinator to animate alongside, making it look seamless for events like device rotations or animated view size changes.
     */
    public func alignScrollView(with coordinator: UIViewControllerTransitionCoordinator? = nil) {
        scrollView.alignScrollView(with: coordinator)
    }
    
    /// Reloads the pages of the scroll view.
    public func reloadData() {
        scrollView.reloadData()
        pageControl?.currentPage = currentPageIndex
        pageControl?.numberOfPages = numberOfPages
    }
    
    /// The index of the current page.
    public var currentPageIndex: Int {
        get {
            return scrollView.currentPageIndex
        }
        set(index) {
            scrollView.currentPageIndex = index
        }
    }
    
    public var attachScrollViewToTopLayoutGuide: Bool {
        return false
    }
    
    /**
     Scrolls to the page with the provided index.
     
     - parameter index: The index of the page to scroll to.
     - parameter animated: Whether or not to animate this change.
     */
    public func scroll(to index: Int, animated: Bool) {
        scrollView.scroll(to: index, animated: animated)
    }
    
    /// Scroll forward one page, if possible.
    public func goForward(animated: Bool = true) {
        scrollView.goForward(animated: animated)
    }
    
    /// Scroll back one page, if possible.
    public func goBack(animated: Bool = true) {
        scrollView.goBack(animated: animated)
    }
    
    /// The number of pages within this scroll view.
    public var numberOfPages: Int {
        return scrollView.numberOfPages
    }
    
    /**
     Register a page control with the paged scroll view controller so that it automatically changes to match the current page and number of pages correctly.
     
     This will also add an event listener so that taps to the page control automatically control the current page index of the scroll view.
     */
    public var pageControl: UIPageControl? {
        didSet {
            oldValue?.removeTarget(self, action: #selector(APPagedScrollViewController.pageControlTapped(_:)), for: .touchUpInside)
            pageControl?.addTarget(self, action: #selector(APPagedScrollViewController.pageControlTapped(_:)), for: .touchUpInside)
            pageControl?.currentPage = currentPageIndex
            pageControl?.numberOfPages = numberOfPages
        }
    }
    
    /// Whether or not to have movedTo: events include elastic scrolling
    public var elasticScrollingEvents: Bool {
        get { return scrollView.elasticScrollingEvents }
        set(elasticScrollingEvents) { scrollView.elasticScrollingEvents = elasticScrollingEvents }
    }
    
    // MARK: - Page Control Handler
    
    @objc func pageControlTapped(_ pageControl: UIPageControl) {
        scroll(to: pageControl.currentPage, animated: true)
    }
    
    // MARK: - Paged Scroll View Delegate
    
    /**
     Called when the scroll view has moved to a new page.
     
     - parameter pagedScrollView: The scroll view that has moved.
     - parameter index: The index of the page that the scroll view has moved to.
     */
    public func pagedScrollView(_ pagedScrollView: APPagedScrollView, movedTo index: Int, from oldIndex: Int?) {
        pageControl?.currentPage = index
    }
    
    /**
     Called during the transition between two pages inside the scroll view.
     
     - parameter pagedScrollView: The scroll view that has moved.
     - parameter newIndex: The index of the page that the scroll view is moving to.
     - parameter oldIndex: The index of the page that the scroll view is moving from.
     - parameter progress: The progress of the transition as a value from 0.0 to 1.0.
     */
    public func pagedScrollView(_ pagedScrollView: APPagedScrollView, movingTo index: Int, from oldIndex: Int, progress: CGFloat) {}
    
    // MARK: - Paged Scroll View Data Source
    
    /**
     Asks the data source to return the number of pages in the scroll view.
     
     - parameter pagedScrollView: The scroll view to return the amount of pages for.
     
     - returns: The number of pages in the scroll view.
     */
    public func numberOfPages(in pagedScrollView: APPagedScrollView) -> Int {
        fatalError("APPagedScrollViewController requires that you override numberOfPages(in:) with the correct value")
    }
    
    /**
     Asks the data source to return the page view for the provided index in the scroll view.
     
     - parameter index: The index of the page view to return.
     - parameter pagedScrollView: The scroll view to return the amount of pages for.
     
     - returns: The page view for the provided index in the scroll view.
     */
    public func view(forPageAt index: Int, in pagedScrollView: APPagedScrollView) -> UIView {
        fatalError("APPagedScrollViewController requires that you override view(forPageAt:, in:) with the correct value")
    }
}
