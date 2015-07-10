module ProMotion
  module Collection
    include ProMotion::Styling
    include ProMotion::Table::Utils
    include ProMotion::CollectionBuilder

    attr_reader :promotion_collection_data

    def collection_view
      self.collectionView
    end

    #def collection_layout
    #  self.collectionViewLayout
    #end

    def screen_setup
      check_collection_data
      set_up_register_class
      #set_up_header_footer_views
      #set_up_searchable
      #set_up_refreshable
      #set_up_longpressable
      #set_up_row_height
    end

    def set_up_register_class
      collection_view.registerClass(PM::CollectionViewCell, forCellWithReuseIdentifier: PM::CollectionViewCell::KIdentifier)
      if self.class.get_cell_views
        self.class.get_cell_views.each do |identifier, klass|
          collection_view.registerClass(klass, forCellWithReuseIdentifier: identifier)
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

    def collectionView(collection_view, viewForSupplementaryElementOfKind: kind, atIndexPath: index_path)
      # todo
    end

    ## UICollectionViewDelegate ##
    #- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
    def collectionView(view, didSelectItemAtIndexPath: index_path)
      params    = index_path_to_section_index(index_path: index_path)
      data_cell = cell_at(index: params[:index], section: params[:section])

      trigger_action(data_cell[:action], data_cell[:arguments], index_path) if data_cell[:action]
    end

    #- (BOOL)collectionView:(UICollectionView *)collectionView shouldDeselectItemAtIndexPath:(NSIndexPath *)indexPath
    #- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
    #- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath
    #- (void)collectionView:(UICollectionView *)collectionView didHighlightItemAtIndexPath:(NSIndexPath *)indexPath
    #- (void)collectionView:(UICollectionView *)collectionView didUnhighlightItemAtIndexPath:(NSIndexPath *)indexPath
    #- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
    #- (void)collectionView:(UICollectionView *)collectionView willDisplaySupplementaryView:(UICollectionReusableView *)view forElementKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath
    #- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
    #- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingSupplementaryView:(UICollectionReusableView *)view forElementOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath
    #- (UICollectionViewTransitionLayout *)collectionView:(UICollectionView *)collectionView transitionLayoutForOldLayout:(UICollectionViewLayout *)fromLayout newLayout:(UICollectionViewLayout *)toLayout
    #- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath
    #- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender
    #- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender

    ## UICollectionViewDelegateFlowLayout ##
    def collectionView(_, layout: view_layout, sizeForItemAtIndexPath: index_path)
      if self.respond_to?(:size_at_index_path)
        self.size_at_index_path(index_path_to_section_index(index_path: index_path))
      elsif view_layout.itemSize
        view_layout.itemSize
      elsif view_layout.estimatedItemSize
        view_layout.estimatedItemSize
      end
    end

    #- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
    #- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
    #- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
    #- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
    #- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section


    protected

    def self.included(base)
      base.extend(CollectionClassMethods)
    end

  end
end
