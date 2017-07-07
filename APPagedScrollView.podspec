Pod::Spec.new do |s|

  s.name         = "APPagedScrollView"
  s.version      = "1.0"
  s.summary      = "A quick delegate-based paging scroll view class that can handle all the layout for you."
  s.requires_arc = true

  s.description  = <<-DESC
A quick delegate-based paging scroll view class that can handle all the layout for you.

Creating paging scroll views on iOS isn't always the easiest. With APPagedScrollView and it's UITableView-like API with delegates and data sources, you can get off your feet with barely any code.

In addition, there is an APPagedScrollViewController that can set up the scroll view for it, which implments the delegate and data source methods so that you can easily override those and provide the data you want.
                   DESC

  s.homepage     = "https://github.com/aydenp/APPagedScrollView"

  s.license      = "MIT"

  s.author       = "Ayden P"

  s.platform     = :ios, "9.0"

  s.source       = { :git => "https://github.com/aydenp/APPagedScrollView.git", :tag => "#{s.version}" }

  s.source_files  = "APPagedScrollView/*.{swift}"

  s.framework  = "UIKit"

end
