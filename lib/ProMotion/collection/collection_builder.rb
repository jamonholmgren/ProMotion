module ProMotion
  module CollectionBuilder
    def trigger_action(action, arguments, index_path)
      if action.is_a?(Proc)
        case arity = action.arity
        when 0 then action.call # Just call the proc
        when 1 then action.call(arguments) # Send arguments
        when 2 then action.call(arguments, index_path) # Send arguments and index path
        else
          mp("#{arity} parameters are not supported", force_color: :yellow)
        end
      else
        return mp("Action not implemented: #{action.to_s}", force_color: :green) unless self.respond_to?(action)

        case arity = self.method(action).arity
        when 0 then self.send(action) # Just call the method
        when 2 then self.send(action, arguments, index_path) # Send arguments and index path
        else
          mp("Action should not have optional parameters: #{action.to_s}", force_color: :yellow) if arity < 0
          self.send(action, arguments) # Send arguments
        end
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
