# Framework Planning


## Promotion-Core

Promotion core should strive to ProMotionify the UIKit level elements of RubyMotion

- Screens
  - PM::Screen | UIViewController
  - PM::SplitScreen | UISplitViewController
  - PM::TableScreen | UITableViewController
    - PM::TableCell | UITableViewCell
  - PM::TabBar | UITabBarController
  - PM::CollectionScreen | UICollectionViewController
    - PM::CollectionCell | UICollectionViewCell
  - PM::ImagePickerScreen | UIImagePickerController 
- Components
  - PM::Alert | UIAlertView
  - PM::Picker | UIPickerView
  - PM::DatePicker | UIDatePicker
  - PM::Image | UIImageView
- View Layout?
  - PM::Switch | UISwitch
  - PM::ToolBar | UIToolBar
  - PM::TabBar | UITabBar
  - PM::Label | UILabel
  - PM::SearchBar | UISearchBar
  - PM::TextInput | UITextInput
  - PM::TextView | UITextView
  
  
Q: Should we include ImagePickerScreen as core, technically its part of UIKit but its usage only occurs in certain apps which makes me think its ripe for extraction into its own gem.


With view layout items we should decide if we want to implement our own perscribed view layout solution or atleast standardize on something like Teacup and add a Promotion sugar where applicable, I dont know how that we need to acutally implement many of the items under view layout since most of their functionality takes place in a delegate, but having sugar for those delegates would make a lot of sense. I like the idea of using Teacup for view layouts but maybe with a our own dsl wrapping it or not. For 2.0 i dont think we need an extended dsl / helpers.

Style sheets are another up in the air topic, personally ive been using Pixate, but their requirement for a license and community quesitons about performance may make it a bad default, maybe put it in our generated gem file but comment it out and have people use Teacup style sheets by default.
I think if we do a DSL giving every layout element a meaninful id/class or make it very explicit in the documentation would allow people to easily understand how styling works and make it compatible with multiple styling libraries.

I define alot of my custom views like this

`self.position_label = subview(UILabel, :position_label, styleClass:"position_label")`

which feels more ruby-esque and can be targeted by multiple stylization frame works, if our dsl just made you specify,
subview(UILabel, :position_label) and automatically applied the Id/Class it could clean that up.



**Gemfile**

This is a proposed gemfile that would be part of the `promotion new` generator

```
source "https://rubygems.org"
gem "rake", "10.1.0"

# ProMotion
gem "ProMotion-core", "2.0""
gem "ProMotion-maps", "2.0"
gem "ProMotion-seachable", "2.0"
gem "ProMotion-refreshable", "2.0"
gem "ProMotion-remote_image", "2.0"
gem "ProMotion-auth", "2.0"



# 3rd Party Plugins
gem 'ProMotion-formotion'


# Syntax Helpers
gem 'sugarcube'

# View Layout
gem "teacup"
gem "motion-pixate"


# ORM/Api
gem 'motion-support'
gem 'motion-resource'



# Objective-C Libraries
gem "cocoapods"
gem "motion-cocoapods"
gem 'formotion'

# Build Environments
# The following gems allow you define specific enviroment variables, this helps support a local/staging release where you may have different endpoints to hit, localhost vs staging.myapi.com
gem 'motion-yaml' # Need just send my own version of this gem to rubygems to support motion_require
gem 'motion-config-vars', github: "j-mcnally/motion-config-vars", branch: "motion_require"

#Testing
gem 'bacon'


```

## ProMotion Plugin Template

**Namespaces**

Plugins should each have a unique namespace, and should never inject themselves into another namespace. It should be up to the developer implementing the plugin to subclass an item from core or another gem and `include ProMotion::Plugin::IncludableModule` this will prevent too much magic from confusing devs and also help to eliminate conflicting behaviors, making plugins incompatible with each other.

**Module Naming**

ProMotion plugins can use the namespace `ProMotion::` but it must be subfixed by their plugin name `ProMotion::Maps` for instance. MapScreen would have the name `ProMotion::Maps::MapScreen` quirky/kitschy names like `ProMotion::Mapsy::MapScreen` or `ProMotion::Cartographer::MapScreen` are encouraged.

**Naming**

The only other convention I would suggest is to stay away from view/view controller and use screen. It seems to be symantically easier to understand, and a foundational goal to eliminate the differences that make parts of Cocoa confusing. A screen is really a view,view controller, and delegate rolled into one but acts mostly like a rails controller.

**Tests**

Posibly use bacon, we need to set forth a standard way to test these external / plugin gems with a real project, I like the approach rails engines use which is to have a very basic project which the gem uses to bootstrap and test itself, we can explore this more.




## ProMotion-Maps

ProMotion-Maps represents a plugin of Promotion which would re-introduce the map screen as a modularized gem. Its goal should be to implement as much of MapKit as we can with ProMotion sugar / syntax. First focusing on MKMapView and MKMapViewDelegate and the annotation things we have now. I would assume this will start by just breaking the map stuff out of the existing ProMotion.

## Promotion-Browser

ProMotion-Browser could be a plugin to wrap the UIWebKit stuff up, we could provide the functionality discussed here: https://github.com/clearsightstudio/ProMotion/issues/197 but also provide a base PM::Browser::WebScreen and PM::Browser::BrowserScreen the latter being a full blown web browser for displaying websites modally, think when you click a facebook or twitter link.


## ProMotion-Searchable

ProMotion-Searchable would likely provide the UISearchBar and UISearchDisplayController. I however do not know if its worth dealing with UISearchDisplayController when its so straightforward to implement it yourself on your main table display. I suppose the difference is one is search and one is filtering. I think for 2.0 implement just UISearchBar as PM::SearchBar and provide the appropriate helpers/module to PM::TableScreen


## ProMotion-Refreshable

ProMotion-Refreshable is a PM:Screen module that wraps UIRefreshControl, UIRefreshControl and its roll in UITableView make it pretty useless so I think leaving this utility alone is the most straightforward except that we make it a seperate gem. Not sure if this works with a standard UIView or collection view but we should make it as agnostic as possible.

## ProMotion-RemoteImage

ProMotion-RemoteImage is a PM::Image module that can be used for asynchronous loading of images by using JMImageCache.
This module could be required instead of JMImageCache directly, for things like table cell remote image / placeholder stuff.


## ProMotion-Notifications

ProMotion-Notifications can help provide a sane framework for developers to register devices for local notifications, this can be included as a module in AppDelegate and wrap.

This will include the helpers

- register_for_push_notifications(*types)
- unregister_for_push_notifications
- on_push_registration(token, error)
- on_push_notification(notification, launched)
- registered_push_notifications

ProMotion::PushNotification would get refactored into this also

Again this could be part of core, but it seems to be such a seperate concern that its ripe for extraction.



## ProMotion-Paginate

ProMotion-Paginate is a PM:Screen module that allows for infinite scrolling in Table and Collection views. Similar to how facebook and twitter load more when you the bottom of the page. This doesnt exist yet, but I am planning to make this a pet project now that we've spec'd it out.
https://github.com/clearsightstudio/ProMotion/issues/363


## ProMotion-Auth

ProMotion-Auth could be a module to wrap things like turnkey, keychain, PM::AuthScreen, and what could hopefully be an OmniAuth/Devise esque way of handling first-class authentication apis along with OAuth libraries and SDK likes Facebook's for authentication. Think Promotion-Auth-Facebook etc down the road.






