module ProMotion
  module Table
    module Utils
      def index_path_to_section_index(params)
        if params.is_a?(Hash) && params[:index_path]
          params[:section] = params[:index_path].section
          params[:index] = params[:index_path].row
        end
        params
      end

      # Determines if all members of an array are a certain class
      def array_all_members_of?(arr, klass)
        arr.select{ |e| e.is_a?(klass) }.length == arr.length
      end
    end
  end
end
