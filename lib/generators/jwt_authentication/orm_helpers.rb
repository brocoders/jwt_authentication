module JwtAuthentication
  module Generators
    module OrmHelpers
      def model_contents
        "  acts_as_jwt_authenticatable\n"
      end

      private

      def model_exists?
        File.exists?(File.join(destination_root, model_path))
      end

      # check if devise migration exist
      def migration_exists?(table_name)
        Dir.glob("#{File.join(destination_root, migration_path)}/[0-9]*_*.rb").grep(/\d+_devise_\w+_#{table_name}.rb$/).first
      end

      def migration_path
        @migration_path ||= File.join("db", "migrate")
      end

      def model_path
        @model_path ||= File.join("app", "models", "#{file_path}.rb")
      end
    end
  end
end
