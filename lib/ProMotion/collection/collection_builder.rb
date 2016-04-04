module ProMotion
  module CollectionBuilder
    def trigger_action(action, arguments, index_path)
      action = (action.is_a?(Proc) ? action : method(action))
      case arity = action.arity
      when 0 then action.call # Just call the proc or the method
      when 2 then action.call(arguments, index_path) # Send arguments and index path
      else
        mp("Action should not have optional parameters: #{action.to_s}", force_color: :yellow) if arity < 0
        action.call(arguments) # Send arguments
      end
    end

    def create_collection_cell(data_cell, index_path)
      cell = collection_view.dequeueReusableCellWithReuseIdentifier(data_cell[:cell_identifier].to_s, forIndexPath: index_path)
      cell.extend(PM::CollectionViewCellModule) unless cell.is_a?(PM::CollectionViewCellModule)
      cell.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin
      cell.clipsToBounds    = true
      if cell.respond_to?(:reused)
        if cell.reused
          on_cell_reused(cell)
        else
          on_cell_created(cell)
          cell.reused = true
        end
      end
      cell.setup(data_cell, self) if cell.respond_to?(:setup)
      cell
    end

    def on_cell_created(cell)
      cell.send(:on_created) if cell.respond_to?(:on_created)
    end

    def on_cell_reused(cell)
      cell.send(:on_reuse) if cell.respond_to?(:on_reuse)
    end
  end
end
