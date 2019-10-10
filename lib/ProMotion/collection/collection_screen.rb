module ProMotion
  class CollectionScreen < CollectionViewController
    include ProMotion::ScreenModule
    include ProMotion::CollectionBuilder
    include ProMotion::Collection
  end
end

