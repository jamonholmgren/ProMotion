module TableClassMethods
  def table_style
    UITableViewStylePlain
  end

  def row_height(height, args={})
    if height == :auto
      if UIDevice.currentDevice.systemVersion.to_f < 8.0
        height = args[:estimated] || 44.0
        mp "Using `row_height :auto` is not supported in iOS 7 apps. Setting to #{height}.", force_color: :yellow
      else
        height = UITableViewAutomaticDimension
      end
    end
    args[:estimated] ||= height unless height == UITableViewAutomaticDimension
    @row_height = { height: height, estimated: args[:estimated] || 44.0 }
  end

  def get_row_height
    @row_height ||= nil
  end

  # Searchable
  def searchable(params={})
    @searchable_params = params
    @searchable = true
  end

  def get_searchable_params
    @searchable_params ||= nil
  end

  def get_searchable
    @searchable ||= false
  end

  # Refreshable
  def refreshable(params = {})
    @refreshable_params = params
    @refreshable = true
  end

  def get_refreshable
    @refreshable ||= false
  end

  def get_refreshable_params
    @refreshable_params ||= nil
  end

  # Indexable
  def indexable(params = {})
    @indexable_params = params
    @indexable = true
  end

  def get_indexable
    @indexable ||= false
  end

  def get_indexable_params
    @indexable_params ||= nil
  end

  # Longpressable
  def longpressable(params = {})
    @longpressable_params = params
    @longpressable = true
  end

  def get_longpressable
    @longpressable ||= false
  end

  def get_longpressable_params
    @longpressable_params ||= nil
  end
end
