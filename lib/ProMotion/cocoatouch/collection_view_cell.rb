  module ProMotion
    class CollectionViewCell < UICollectionViewCell
      include ProMotion::CollectionViewCellModule

      attr_accessor :reused
      KIdentifier = '__ProMotion_CollectionViewCell'
    end
  end
