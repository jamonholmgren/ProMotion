module ProMotion
  module TableBuilder
    def trigger_action(action, arguments, index_path)
      return PM.logger.info "Action not implemented: #{action.to_s}" unless self.respond_to?(action)
      case self.method(action).arity
      when 0 then self.send(action) # Just call the method
      when 2 then self.send(action, arguments, index_path) # Send arguments and index path
      else self.send(action, arguments) # Send arguments
      end
    end

    def create_table_cell(data_cell)
      new_cell = nil
      table_cell = table_view.dequeueReusableCellWithIdentifier(data_cell[:cell_identifier]) || begin
        new_cell = data_cell[:cell_class].alloc.initWithStyle(data_cell[:cell_style], reuseIdentifier:data_cell[:cell_identifier])
        new_cell.extend(PM::TableViewCellModule) unless new_cell.is_a?(PM::TableViewCellModule)
        new_cell.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin
        new_cell.clipsToBounds = true # fix for changed default in 7.1
        new_cell.send(:on_load) if new_cell.respond_to?(:on_load)
        new_cell
      end
      table_cell.setup(data_cell, self) if table_cell.respond_to?(:setup)
      table_cell.send(:on_reuse) if !new_cell && table_cell.respond_to?(:on_reuse)
      table_cell
    end
  end
end
