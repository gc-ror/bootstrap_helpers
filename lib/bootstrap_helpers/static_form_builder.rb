# frozen_string_literal: true

module BootstrapHelpers
  #
  # モデル詳細ビルダー
  #
  class StaticFormBuilder
    attr_reader :instance, :template, :options

    delegate :tag, :concat, :capture, to: :template

    def initialize(instance, template, **options)
      @template = template
      @instance = instance
      @options = options
    end

    def model_class
      instance.class
    end

    def label(method)
      model_class.human_attribute_name method
    end

    def field(method, helper: nil, unit: nil, attribute: nil)
      tag.div(class: 'field-group') do
        value = instance.send method
        value = value&.send attribute if attribute.present?
        content = if block_given?
                    capture do
                      yield value, method, instance
                    end.html_safe?
                  elsif helper.present?
                    template.send(helper, value)
                  else
                    value.to_s
                  end

        content_class = ['field-content', ('text-right' if unit.present?)].compact.join(' ')
        content = [content, unit].select(&:present?).join if content.present? && unit.present?

        (tag.label(label(method)) + tag.div(content, class: content_class))
      end
    end
  end
end