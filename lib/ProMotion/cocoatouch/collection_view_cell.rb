module ProMotion
  class CollectionViewCell < UICollectionViewCell
    attr_reader :reused

    def prepareForReuse
      @reused = true
    end
  end
end
