# APPagedScrollView
A quick delegate-based paging scroll view class that can handle all the layout for you.

Creating paging scroll views on iOS isn't always the easiest. With APPagedScrollView and it's UITableView-like API with delegates and data sources, you can get off your feet with barely any code.

In addition, there is an `APPagedScrollViewController` that can set up the scroll view for it, which implments the delegate and data source methods so that you can easily override those and provide the data you want.

## Getting started

### Installation

You can install APPagedScrollView using CocoaPods by adding it to your Podfile:

    pod 'APPagedScrollView'

or by copying over the two Swift files (as needed).

### Implementing it in your app

Depending on your needs, you can either subclass and override the methods on `APPagedScrollViewController` or just use your own class(es) and implement `APPagedScrollViewDelegate` and `APPagedScrollViewDataSource`.

In our example, we have subclassed `APPagedScrollViewController`.
