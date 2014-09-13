module ProMotion
  module Table
    module Utils
      def index_path_to_section_index(params)
        if params[:index_path]
          params[:section] = params[:index_path].section
          params[:index] = params[:index_path].row
        end
        params
      end
    end
  end
end
