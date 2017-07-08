# APPagedScrollView
A quick delegate-based paging scroll view class that can handle all the layout for you.

Creating paging scroll views on iOS isn't always the easiest. With APPagedScrollView and it's UITableView-like API with delegates and data sources, you can get off your feet with barely any code.

In addition, there is an `APPagedScrollViewController` that can set up the scroll view for it, which implments the delegate and data source methods so that you can easily override those and provide the data you want.

## Installation

You can install APPagedScrollView using CocoaPods by adding it to your Podfile:

    pod 'APPagedScrollView'

or by copying over the two Swift files (as needed).

## Implementing it in your app

**We now have documentation for each class!** [Click here to view the documentation](https://aydenp.github.io/APPagedScrollView/)

Depending on your needs, you can either subclass and override the methods on `APPagedScrollViewController` or just use your own class(es) and implement `APPagedScrollViewDelegate` and `APPagedScrollViewDataSource`.

### Using the view controller

In our example, we have subclassed `APPagedScrollViewController`.

```swift
class MyPagingScrollViewController: APPagedScrollViewController {
    var pages = ["Hello", "world!"]

    // MARK: - Paged Scroll View Data Source

    override func numberOfPages(in pagedScrollView: APPagedScrollView) -> Int {
        return pages.count
    }
    
    override func view(forPageAt index: Int, in pagedScrollView: APPagedScrollView) -> UIView {
        let view = UIView()
        let label = UILabel()
        label.text = pages[index]
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        label.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        label.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        return view
    }
    
    // MARK: - Paged Scroll View Delegate
    
    override func pagedScrollView(_ pagedScrollView: APPagedScrollView, movedTo index: Int, from oldIndex: Int?) {
        super.pagedScrollView(pagedScrollView, movedTo: index, from: oldIndex)
        print("Scroll view moved to page \(index)!")
    }
    
}
```

#### Adding a page control

The view controller also provides page control functionality built-in, meaning that it can automatically update your `UIPageControl` with the current index and total page count, as well as allow users to navigate by tapping it. To get this functionality, simply create a UIPageControl, and set it on the view controller:

```swift
// Create a page control
let pageControl = UIPageControl()
pageControl.translatesAutoresizingMaskIntoConstraints = false
// Add and set its location
view.addSubview(pageControl)
pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
pageControl.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20).isActive = true
// Set on the view controller so we can receive updates
self.pageControl = pageControl
```

#### Changing what it attaches to

By default, the scroll view attaches to the top of the view controller's view. This is usually fine, except if you manually set your scroll view's content inset and don't want to worry about fixing it to layout properly. You can override `attachScrollViewToTopLayoutGuide` and return `true` to attach the scroll view directly to your top layout guide, removing the need for automatically set scroll view insets. (iOS 11 slightly changes this behaviour by applying the system insets afterwards by default).

#### Property Proxies

The view controller by default has some variables and functions that carry over functionality of the paged scroll view class.

### Using the view

By using the view, you don't get the automatic layout or page control functionality. You'll have to set it up yourself. Once you've set it up, make sure to set the `pagingDelegate` and `dataSource` properties properly so that it knows where to receive data from.

#### Responding to size changes

If an iOS device changes size (rotation, etc), the scroll view can become misaligned. You can call `alignScrollView()` on it to re-align it. This will cause the scroll view to jump to the aligned location, so you can also provide a `UIViewControllerTransitionCoordinator` to animate alongside. Here's an example that automatically aligns the scroll view position during a rotation:

```swift
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        scrollView.alignScrollView(with: coordinator)
    }
```

### Other notes

#### Reloading the data

To reload the data in the view, simply call `reloadData()` on either the scroll view or its controller.

#### Getting the page count or current page index

If you need to get the current page index or number of pages somewhere else in your code, you can call `currentPageIndex` or `numberOfPages` on the scroll view or its controller.

#### Checking if the scroll view can move in a direction

We provide convenience variables on both the scroll view and its controller, named `canGoBack` and `canGoForward`, which tell you if the scroll view can go back or forward based on its current index and the number of pages. You can use this in your code to disable previous/next buttons on page change, for example.

#### Scrolling to a different page

You can simply go back or forward using the `goBack` or `goForward` functions on the scroll view or its controller (they both also accept an optional boolean argument, `animated`).

You can also just outright set the `currentPageIndex` from the above section to scroll to that page with an animation. If you don't want an animation, use the `scroll(to: index, animated: animated)` function and turn off the animation using the `animated` argument.

#### How can I get other `UIScrollViewDelegate` methods called in my code.

`APPagedScrollView` needs access to the scroll view's delegate in order to receive events properly, but we have a property on it called `receivingDelegate` which we forward all the events to, allowing you to receive them.

#### Getting page move events

Two delegate methods allow you to perform actions based on when the user changes pages, or is transitioning between pages.

- `func pagedScrollView(_ pagedScrollView: APPagedScrollView, movedTo index: Int, from oldIndex: Int?)` is called after the page has been changed to `index`. `oldIndex` contains the page that it moved from, if there was one.

- `func pagedScrollView(_ pagedScrollView: APPagedScrollView, movingTo index: Int, from oldIndex: Int, progress: CGFloat)` is called during the scroll from one page to another. `index` is the page we think it'll end up on, `oldIndex` is the page it's transitioning from, and `progress` is a value from 0 to 1 containing the progress of the transition. You can use this to do interactive scroll events and animations in your app as the page changes.

> Note that `pagedScrollView(_:, movingTo:, index:, progress:)` doesn't pick up on scroll events that are outside of the scroll view's content area by default. To explain more, everyone that's used iOS knows that scroll views allow you to scroll past the content area, with an elastic-like effect to slow you down, which puts you back where you were when you're finished. If you'd like the delegate method to also pick up these events, you can enable `elasticScrollingEvents`, but make sure if you have logic in the delegate that relies on page numbers, it knows to account for these transitions (pages past the bounds will have indices of -1 or just outside of the possible range).

## License

This project is licensed under the [MIT license](/LICENSE). Please make sure you comply with its terms while using the library.
