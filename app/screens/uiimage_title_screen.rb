class UIImageTitleScreen < FunctionalScreen
  title_image UIImage.imageNamed('test.png')

  def on_live_reload
    puts "Hey!"
  end
end
