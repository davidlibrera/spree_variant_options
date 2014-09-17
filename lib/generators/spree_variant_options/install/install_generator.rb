module SpreeVariantOptions
  module Generators
    class InstallGenerator < Rails::Generators::Base
      def add_javascript
        append_file 'vendor/assets/javascripts/spree/frontend/all.js', "//= require spree/frontend/spree_variant_options\n"
      end
    end
  end
end
