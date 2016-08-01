### Contents

* [Usage](#usage)
* [Methods](#methods)
* [Class Methods](#class-methods)
* [Accessors](#accessors)

### Usage

ProMotion::CollectionScreen is a subclass of [UICollectionViewController](https://developer.apple.com/library/ios/documentation/UIKit/Reference/UICollectionViewController_clas/) and has all the goodness of [PM::Screen](https://github.com/clearsightstudio/ProMotion/wiki/API-Reference:-ProMotion::Screen) with some additional magic to make the collections work beautifully.

|Collection Screen|
|---|
|![ProMotion CollectionScreen](https://photos-5.dropbox.com/t/2/AABmOcZJarZgp843U0bwgmY2QhhxK_UTguKGDU8F6juLLA/12/47296598/png/32x32/1/1436911200/0/2/pm-collection-screen.png/CNbgxhYgASACIAMgBCAFIAYgBygBKAIoBw/KH2abIi_F4l_S-LRP9dNphlBFf2wusFpT-uIw7hPO6g?size_mode=5)|

```ruby

class PhotoViewCell < ProMotion::CollectionViewCell
  def on_created
    self.backgroundColor = UIColor.whiteColor

    @imageview = UIImageView.new
    @imageview.frame = [[10, 10], [130, 130]]
    @imageview.contentMode = UIViewContentModeScaleAspectFit
    self.contentView.addSubview(@imageview)
  end

  def setup(cell_data, screen)
    super
    url = NSURL.URLWithString(cell_data[:image])
    @imageview.image = UIImage.imageWithData(NSData.dataWithContentsOfURL(url))
  end
end

class PhotosScreen < ProMotion::CollectionScreen

  collection_layout UICollectionViewFlowLayout,
                    direction:                 :vertical,
                    minimum_line_spacing:      10,
                    minimum_interitem_spacing: 10,
                    item_size:                 [150, 150],
                    section_inset:             [10, 10, 10, 10]

  cell_classes image_cell: PhotoViewCell

  def collection_data
    images = [
      'http://url.com/an_image.jpg',
    ]

    [
      images.map do |image|
        {image: image, cell_identifier: :image_cell}
      end
    ]
  end

end
```

### Methods

#### collection_data

Method that is called to get the collection's cell data and build the table.

It consists of an array of array of cells.

```ruby
def collection_data
  [
    [
      { title: 'Oregon', action: :visit_state, arguments: { state: @oregon }},
      { title: "Washington", action: :visit_state, arguments: { state: @washington }}
    ],
    [
      { title: 'Idaho', action: :visit_state, arguments: { state: @idaho }},
      { title: "Texas", action: :visit_state, arguments: { state: @texas }}
    ]
  ]
end

def visit_state(args={})
  mp args[:state] # => instance of State
end
```

View the [Reference: All available collection_data options](https://github.com/clearsightstudio/ProMotion/wiki/Reference:-All-available-collection_data-options) for an example with all available options.

#### update_collection_data

Causes the collection data to be refreshed, such as when a remote data source has
been downloaded and processed.

```ruby
class MyCollectionScreen < PM::CollectionScreen

  def on_load
    MyItem.pull_from_server do |items|
      @collection_data = [
        items.map do |item|
          {
            title: item.name,
            action: :tapped_item,
            arguments: { item: item }
          }
        end
      ]

      update_collection_data
    end
  end

  def collection_data
    @collection_data ||= []
  end

  def tapped_item(item)
    open ItemDetailScreen.new(item: item)
  end

end
```

#### on_created

Called when a cell is created (not dequeued).  

```ruby
def on_created
  self.backgroundColor = UIColor.whiteColor

  @imageview = UIImageView.new
  @imageview.frame = [[10, 10], [130, 130]]
  @imageview.contentMode = UIViewContentModeScaleAspectFit
  self.contentView.addSubview(@imageview)
end
```

#### on_reuse

Called when a cell is dequeued and re-used.

#### setup(data_cell, screen)

Called when a cell is either created or re-used.

```ruby
def setup(data_cell, screen)
  @label.text = data_cell[:title]
end
```

### Class Methods

#### collection_layout(layout_class, options = {})

Class method to set the UICollectionViewLayout options.

```ruby
class MyCollectionScreen < PM::CollectionScreen

  collection_layout UICollectionViewFlowLayout,
                    direction:                 :horizontal,
                    minimum_line_spacing:      10,
                    minimum_interitem_spacing: 10,
                    item_size:                 [100, 80],
                    section_inset:             [10, 10, 10, 10]

end
```

#### cell_classes(options = {})

Class method to add the cells classes with their identifier (used by `registerClass:forCellWithReuseIdentifier:` and `dequeueReusableCellWithReuseIdentifier:forIndexPath:`).

```ruby
class MyCollectionScreen < PM::CollectionScreen

  cell_classes an_identifier: SomeClassViewCell, another_identifier: AnotherClassViewCell

end
```

---

### Accessors

You get all the normal accessors of `PM::Screen`, but no documented CollectionScreen accessors are available.

---
