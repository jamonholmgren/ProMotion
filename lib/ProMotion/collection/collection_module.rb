module ProMotion
  module CollectionModule
    attr_accessor :collection_cell_class, :reuse_identifier

    def screen_setup
      check_collection_data
      set_collection_defaults
      set_up_collection_view
    end

    def check_collection_data
      PM.logger.error "Missing #collection_data method in #{self.class.to_s}." unless self.respond_to?(:collection_data)
    end

    def set_collection_defaults
      self.collection_cell_class ||= PM::CollectionViewCell
      self.reuse_identifier ||= "#{self.class}Cell"
    end

    def set_up_collection_view
      collectionView.registerClass(collection_cell_class, forCellWithReuseIdentifier: reuse_identifier)
      collectionView.delegate ||= self
      collectionView.dataSource ||= self
    end

    def trigger_action(action, arguments, index_path)
      return PM.logger.info "Action not implemented: #{action.to_s}" unless self.respond_to?(action)
      case self.method(action).arity
      when 0 then self.send(action) # Just call the method
      when 2 then self.send(action, arguments, index_path) # Send arguments and index path
      else self.send(action, arguments) # Send arguments
      end
    end

    ####### Data methods #######

    def promotion_collection_data
      @collection_data ||= sanity_check_collection_data(self.collection_data)
    end

    def update_collection_data
      Dispatch::Queue.main.async do
        @collection_data = nil
        collectionView.reloadData
        collectionView.collectionViewLayout.invalidateLayout
      end
    end

    def sanity_check_collection_data(d)
      PM.logger.error("You must provide an array in your collection_data method.") unless d.is_a?(Array)
      d.each { |section| PM.logger.error("You must provide :items in your collection_data sections.") unless section[:items] }
      d
    end

    def cell_data_from_index_path(index_path)
      promotion_collection_data.at(index_path.section)[:items].at(index_path.row)
    end

    ####### Forwarding methods (for initial setup, mainly) #######

    def delegate=(d)
      collectionView.delegate = d
    end

    def data_source=(d)
      collectionView.dataSource = d
    end

    def allow_selection=(t)
      collectionView.allowsSelection = t
    end

    def allow_multiple_selection=(t)
      collectionView.allowsMultipleSelection = t
    end

    #################### Cocoa Touch methods ####################

    def numberOfSectionsInCollectionView(view)
      promotion_collection_data.length
    end

    def collectionView(view, numberOfItemsInSection: section)
      promotion_collection_data.at(section)[:items].length
    end

    def collectionView(view, cellForItemAtIndexPath: index_path)
      view.dequeueReusableCellWithReuseIdentifier(reuse_identifier, forIndexPath: index_path).tap do |cell|
        cell_data = cell_data_from_index_path(index_path)
        if cell.respond_to?(:reused) && cell.reused
          self.on_cell_reused(cell) if self.respond_to?(:on_cell_reused)
        else
          self.on_cell_created(cell) if self.respond_to?(:on_cell_created)
        end
      end
    end

    def collectionView(view, didSelectItemAtIndexPath: index_path)
      cell = view.cellForItemAtIndexPath(index_path)
      data_cell = cell_data_from_index_path(index_path)
      trigger_action(data_cell[:action], data_cell[:arguments], index_path) if data_cell[:action]
    end

  end
end
