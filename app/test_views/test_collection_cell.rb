class TestCollectionCell < UICollectionViewCell
  attr_reader :reused

  def prepareForReuse
    @reused = true
  end

end
