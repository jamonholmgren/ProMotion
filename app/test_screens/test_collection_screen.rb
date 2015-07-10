class TestCollectionScreen < ProMotion::CollectionScreen
  
  collection_layout UICollectionViewFlowLayout,
                    :direction                 => :horizontal,
                    :minimum_line_spacing      => 10,
                    :minimum_interitem_spacing => 10,
                    :estimated_item_size       => [40, 40]

  def on_load
    set_attributes self.view, { backgroundView: nil, backgroundColor: UIColor.whiteColor }
    set_nav_bar_button :right, title: UIImage.imageNamed("list.png"), action: :return_to_some_other_screen, type: UIBarButtonItemStylePlain
  end

  def collection_data
    (1..6).to_a.map do |i|
      (1..10).to_a.map do |o|
        {
          title: "#{i}x#{o}"
        }
      end
    end
  end
end