# frozen_string_literal: true
module Hyrax
  module DOI
    module WorkFormHelper
      def form_tabs_for(form:)
        if form.model_class.ancestors.include? Hyrax::DOI::DOIBehavior
          # TODO: Add check for feature flipper?
          super.prepend("doi")
        else
          super
        end
      end
    end
  end
end
