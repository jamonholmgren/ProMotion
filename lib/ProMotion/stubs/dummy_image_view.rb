class DummyImageView < UIImageView
private

  def dummy
    imageForURL(nil, completionBlock:nil)
  end
end