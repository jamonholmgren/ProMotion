class TestCollection2Screen < ProMotion::CollectionScreen

  collection_layout UICollectionViewFlowLayout,
                    section_inset: [10, 10, 10, 10]

  cell_classes custom_cell: CustomCollectionViewCell

  def random_data
    (1..20).to_a.map do |i|
      (1..20).to_a.map do |o|
        {
            cell_identifier:  :custom_cell,
            title:            "#{i}x#{o}",
            action:           'touched:',
            background_color: UIColor.colorWithRed(rand(255) / 255.0,
                                                   green: rand(255) / 255.0,
                                                   blue:  rand(255) / 255.0,
                                                   alpha: 1.0)
        }
      end
    end
  end

  def collection_data
    random_data
  end

  def size_at_index_path(index_path)
    [[100, rand(300)].max, [80, rand(150)].max]
  end

  def touched(_, index_path)
    update_collection_view_data(random_data)
  end
end