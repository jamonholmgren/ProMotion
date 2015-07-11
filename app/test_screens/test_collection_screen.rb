class TestCollectionScreen < ProMotion::CollectionScreen

  collection_layout UICollectionViewFlowLayout,
                    direction:                 :horizontal,
                    minimum_line_spacing:      10,
                    minimum_interitem_spacing: 10,
                    item_size:                 [100, 80],
                    section_inset:             [10, 10, 10, 10]

  cell_view 'custom_cell', CustomCollectionViewCell

  def collection_data
    (1..10).to_a.map do |i|
      (1..10).to_a.map do |o|
        {
            cell_identifier: 'custom_cell',
            title:           "#{i}x#{o}"
        }
      end
    end
  end
end