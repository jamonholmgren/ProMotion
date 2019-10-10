module ProMotion
  module CollectionViewCellModule
    include ProMotion::Styling

    attr_accessor :data_cell, :collection_screen

    def setup(data_cell, screen)
      self.collection_screen = WeakRef.new(screen)
      self.data_cell         = data_cell
    end

    def prepareForReuse
      super
      self.send(:prepare_for_reuse) if self.respond_to?(:prepare_for_reuse)
    end
  end
end
