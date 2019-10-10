module ProMotion
  module Collection
    include ProMotion::Styling
    include ProMotion::Table::Utils
    include ProMotion::CollectionBuilder

    attr_reader :promotion_collection_data

    def collection_view
      self.collectionView
    end

    def screen_setup
      check_collection_data
    end

    # Override viewDidLoad here to register cell classes here.
    # Calling it from `screen_setup` cause `on_load` to be called twice
    def viewDidLoad
      super
      set_up_register_class
    end

    def set_up_register_class
      collection_view.registerClass(PM::CollectionViewCell, forCellWithReuseIdentifier: PM::CollectionViewCell::KIdentifier)
      if self.class.get_cell_classes
        self.class.get_cell_classes.each do |identifier, klass|
          collection_view.registerClass(klass, forCellWithReuseIdentifier: identifier.to_s)
        end
      end
    end

    def check_collection_data
      mp("Missing #collection_data method in CollectionScreen #{self.class.to_s}.", force_color: :red) unless self.respond_to?(:collection_data)
    end

    def promotion_collection_data
      @promotion_collection_data ||= CollectionData.new(collection_data, collection_view)
    end

    # Returns the data cell
    def cell_at(args = {})
      self.promotion_collection_data.cell(args)
    end

    def update_collection_view_data(data, args = {})
      self.promotion_collection_data.data = data
      if args[:index_paths]
        collection_view.reloadItemsAtIndexPaths(Array(args[:index_paths]))
      elsif args[:sections]
        collection_view.reloadSections(args[:sections])
      else
        collection_view.reloadData
      end
    end

    def reload_data
      update_collection_view_data(collection_data)
    end
    alias_method :update_collection_data, :reload_data


    ########## Cocoa touch methods #################

    ## UICollectionViewDataSource ##
    def collectionView(_, numberOfItemsInSection: section)
      self.promotion_collection_data.section_length(section)
    end

    def numberOfSectionsInCollectionView(_)
      self.promotion_collection_data.sections.length
    end

    def collectionView(_, cellForItemAtIndexPath: index_path)
      params    = index_path_to_section_index(index_path: index_path)
      data_cell = cell_at(index: params[:index], section: params[:section])
      create_collection_cell(data_cell, index_path)
    end

    ## UICollectionViewDelegate ##
    def collectionView(view, didSelectItemAtIndexPath: index_path)
      params    = index_path_to_section_index(index_path: index_path)
      data_cell = cell_at(index: params[:index], section: params[:section])

      trigger_action(data_cell[:action], data_cell[:arguments], params) if data_cell[:action]
    end

    ## UICollectionViewDelegateFlowLayout ##
    def collectionView(_, layout: view_layout, sizeForItemAtIndexPath: index_path)
      if self.respond_to?(:size_at_index_path)
        self.size_at_index_path(index_path_to_section_index(index_path: index_path))
      elsif view_layout.itemSize
        view_layout.itemSize
      elsif view_layout.respond_to?(:estimatedItemSize) and view_layout.estimatedItemSize
        view_layout.estimatedItemSize
      else
        mp "Implement the size_at_index_path method in your PM::CollectionScreen or add item_size or estimated_item_size in the layout options to configure the size of your cells.", force_color: :yellow
      end
    end

    protected

    def self.included(base)
      base.extend(CollectionClassMethods)
    end

  end
end
