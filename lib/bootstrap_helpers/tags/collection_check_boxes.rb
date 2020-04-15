# frozen_string_literal: true

module BootstrapHelpers
  module Tags
    #
    # コレクションチェックボックス
    #
    class CollectionCheckBoxes < ActionView::Helpers::Tags::CollectionCheckBoxes
      class CheckBoxBuilder < ActionView::Helpers::Tags::CollectionHelpers::Builder # :nodoc:
        def check_box(extra_html_options = {})
          html_options = extra_html_options.merge(@input_html_options)
          html_options[:multiple] = true
          html_options[:skip_default_ids] = false
          html_options[:class] = 'custom-control-input'
          @template_object.check_box(@object_name, @method_name, html_options, @value, nil)
        end

        def label(label_html_options = {}, &block)
          html_options = @input_html_options.slice(:index, :namespace).merge(label_html_options)
          html_options[:for] ||= @input_html_options[:id] if @input_html_options[:id]
          html_options[:class] = 'custom-control-label'

          @template_object.label(@object_name, @sanitized_attribute_name, @text, html_options, &block)
        end
      end

      def render(&block)
        render_collection_for(CheckBoxBuilder, &block)
      end

      private

      #
      # @param [CheckBoxBuilder] builder
      #
      def render_component(builder)
        "<div class=\"custom-control custom-checkbox mr-sm-2\">#{builder.check_box + builder.label}</div>"
      end
    end
  end
end
