class TestCollectionScreen < ProMotion::CollectionScreen

  collection_layout UICollectionViewFlowLayout,
                    direction:                 :horizontal,
                    minimum_line_spacing:      10,
                    minimum_interitem_spacing: 10,
                    item_size:                 [100, 80],
                    section_inset:             [10, 10, 10, 10]

  cell_classes custom_cell: CustomCollectionViewCell

  def collection_data
    (1..10).to_a.map do |i|
      (1..10).to_a.map do |o|
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

  def touched(_)
    alert = UIAlertController.alertControllerWithTitle("CollectionScreen",
                                                       message:        "You clicked a row",
                                                       preferredStyle: UIAlertControllerStyleAlert)

    action = UIAlertAction.actionWithTitle("OK", style: UIAlertActionStyleDefault, handler: nil)
    alert.addAction(action)
    self.presentViewController(alert, animated: true, completion: nil)
  end
end