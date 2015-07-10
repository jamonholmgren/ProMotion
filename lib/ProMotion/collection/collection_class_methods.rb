module CollectionClassMethods

  def collection_layout(klass, options={})
    @layout                         = klass.new
    @layout.scrollDirection         = map_layout_direction(options.fetch(:direction, :horizontal))

    @layout.minimumLineSpacing      = options[:minimum_line_spacing] if options.has_key?(:minimum_line_spacing)
    @layout.minimumInteritemSpacing = options[:minimum_interitem_spacing] if options.has_key?(:minimum_interitem_spacing)
    @layout.itemSize                = options[:item_size] if options.has_key?(:item_size)
    @layout.estimatedItemSize       = options[:estimated_item_size] if options.has_key?(:estimated_item_size)
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
    }[symbol] || symbol || UICollectionViewScrollDirectionHorizontal
  end

  def cell_view(identifier, klass)
    @cell_classes ||= {}
    @cell_classes[identifier] = klass
  end

  def get_cell_views
    @cell_classes || nil
  end
end
