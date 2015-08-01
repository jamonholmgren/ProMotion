module ProMotion
  module TableBuilder
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

    def create_table_cell(data_cell)
      new_cell = nil
      table_cell = table_view.dequeueReusableCellWithIdentifier(data_cell[:cell_identifier]) || begin
        new_cell = data_cell[:cell_class].alloc.initWithStyle(data_cell[:cell_style], reuseIdentifier:data_cell[:cell_identifier])
        new_cell.extend(PM::TableViewCellModule) unless new_cell.is_a?(PM::TableViewCellModule)
        new_cell.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin
        new_cell.clipsToBounds = true # fix for changed default in 7.1
        on_cell_created new_cell, data_cell
        new_cell
      end
      table_cell.setup(data_cell, self) if table_cell.respond_to?(:setup)
      on_cell_reused(table_cell, data_cell) if !new_cell
      table_cell
    end

    def on_cell_created(new_cell, data_cell)
      new_cell.send(:on_load) if new_cell.respond_to?(:on_load)
    end

    def on_cell_reused(cell, data)
      cell.send(:on_reuse) if cell.respond_to?(:on_reuse)
    end
  end
end
