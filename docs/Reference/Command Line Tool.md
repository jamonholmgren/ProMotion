ProMotion comes bundled with an executable called `promotion`. For now, it just creates a scaffold ProMotion project. We may extend it to include generators and other helpful utilities down the road.

#### promotion new `appname`

Creates a new ProMotion app in a new `appname` folder.

```shell
$ gem install ProMotion
Successfully installed ProMotion
1 gem installed

$ promotion new mytestapp
Creating new ProMotion iOS app mytestapp
From github.com:jamonholmgren/promotion-template
 * branch            master     -> FETCH_HEAD
   a3f98a9..676fd71  master     -> origin/master
    Create mytestapp
    Create mytestapp/.gitignore
    Create mytestapp/app/app_delegate.rb
    Create mytestapp/app/layouts/.gitkeep
    Create mytestapp/app/models/.gitkeep
    Create mytestapp/app/screens/help_screen.rb
    Create mytestapp/app/screens/home_screen.rb
    Create mytestapp/app/styles/.gitkeep
    Create mytestapp/app/views/.gitkeep
    Create mytestapp/Gemfile
    Create mytestapp/Rakefile
    Create mytestapp/resources/Default-568h@2x.png
    Create mytestapp/spec/main_spec.rb
    Create mytestapp/spec/screens/home_screen_spec.rb
```
