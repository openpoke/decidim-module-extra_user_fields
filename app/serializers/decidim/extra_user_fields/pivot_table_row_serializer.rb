# frozen_string_literal: true

module Decidim
  module ExtraUserFields
    # Serializer for pivot table export rows.
    # Each resource is already a ready-made hash, so serialize returns it as-is.
    class PivotTableRowSerializer < Decidim::Exporters::Serializer
      def serialize
        resource
      end
    end
  end
end
