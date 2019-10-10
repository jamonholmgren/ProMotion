module ProMotion
  module TableBuilder
    def trigger_action(action, arguments, index_path)
      action = (action.is_a?(Proc) ? action : method(action))
      case arity = action.arity
      when 0 then action.call # Just call the proc or the method
      when 2 then action.call(arguments, index_path) # Send arguments and index path
      else
        mp("Action should not have optional parameters: #{action.to_s} in #{self.inspect}", force_color: :yellow) if arity < 0
        action.call(arguments) # Send arguments
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
