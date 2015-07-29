module CollectionClassMethods

  def collection_layout(klass, options={})
    @layout                         = klass.new
    @layout.scrollDirection         = map_layout_direction(options.fetch(:direction, :vertical))

    @layout.minimumLineSpacing      = options[:minimum_line_spacing] if options.has_key?(:minimum_line_spacing)
    @layout.minimumInteritemSpacing = options[:minimum_interitem_spacing] if options.has_key?(:minimum_interitem_spacing)
    @layout.itemSize                = options[:item_size] if options.has_key?(:item_size)
    @layout.estimatedItemSize       = options[:estimated_item_size] if options.has_key?(:estimated_item_size) and @layout.respond_to?(:estimatedItemSize)
    @layout.sectionInset            = options[:section_inset] if options.has_key?(:section_inset)
    @layout
  end

  def get_collection_layout
    @layout ||= begin
      layout                 = UICollectionViewFlowLayout.new
      layout.scrollDirection = UICollectionViewScrollDirectionHorizontal

      layout
    end
  end

  def map_layout_direction(symbol)
    {
        horizontal: UICollectionViewScrollDirectionHorizontal,
        vertical:   UICollectionViewScrollDirectionVertical
    }[symbol] || symbol || UICollectionViewScrollDirectionVertical
  end

  def cell_classes(options={})
    @cell_classes = options
  end

  def get_cell_classes
    @cell_classes || nil
  end
end
