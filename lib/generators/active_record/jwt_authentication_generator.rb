require 'rails/generators/active_record'
require 'generators/jwt_authentication/orm_helpers'

module ActiveRecord
  module Generators
    class JwtAuthenticationGenerator < ActiveRecord::Generators::Base
      include JwtAuthentication::Generators::OrmHelpers
      class_option :skipmigrations, :aliases => "-m", :desc => 'Do not create migrations'

      source_root File.expand_path("../templates", __FILE__)

      def inject_devise_content
        raise 'Devise migrations was not found' unless (model_exists?)
        content = model_contents

        class_path = if namespaced?
                       class_name.to_s.split("::")
                     else
                       [class_name]
                     end

        inject_into_class(model_path, class_path.last, content)
      end

      def copy_migration
        return if options[:skipmigrations].present?
        raise 'Devise migrations was not found' unless migration_exists?(table_name)
        migration_template "migration.rb", "db/migrate/add_authentication_token_to_#{table_name}.rb"
      end

      def migration_data
<<DATA
    add_column :#{table_name}, :authentication_token, :string
    add_index  :#{table_name}, :authentication_token
DATA
      end
    end
  end
end
