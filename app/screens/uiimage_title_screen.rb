class UIImageTitleScreen < FunctionalScreen
  title_image UIImage.imageNamed('test.png')

  def on_load

  end

  def on_live_reload
    puts "Yo"
  end

end
