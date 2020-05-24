# frozen_string_literal: true

module BootstrapHelpers
  #
  # フォームタグヘルパー
  #
  module FormTagHelper
    def active_if(*args, **conditions)
      return unless params_match?(*args, conditions)

      class_name = conditions.delete(:class_name) || ' active'
      block_given? ? yield : class_name
    end

    def params_eval(scope = nil, **conditions)
      scope ||= params
      conditions.all? do |key, value|
        case key
        when :member
          (value ? true : false) ^ scope[:id].blank?
        when :collection
          (value ? true : false) ^ scope[:id].present?
        when :must
          value
        else
          target = key == :controller ? params[key].split('/').last : params[key]
          case value
          when Hash
            params_match?(scope[key], value)
          when Array
            value.any? do |item|
              target == item.to_s
            end
          else
            target == value.to_s
          end
        end
      end
    end

    def params_match?(*args, &block)
      match = args.any? { |arg| params_eval(**arg) }

      if block_given?
        capture(&block) if match
      else
        match
      end
    end

    #
    # formをbootstrap形式で出力します。
    #
    # @param options
    # @return [String]
    #
    def bs_form_with(**options, &block)
      form_with builder: BootstrapHelpers::FormBuilder, local: true, **options, &block
    end

    def bs_field_with(builder: StaticFormBuilder, model:, **options)
      capture do
        yield builder.new(model, self, **options)
      end
    end

    def yes_no(value, yes: 'はい', no: 'いいえ')
      return if value.nil?

      value ? yes : no
    end

    #
    # will_paginateをbootstrap形式で出力します。
    #
    # @param collection
    # @param options
    #
    # @return [String]
    #
    # noinspection RubyResolve
    def bs_will_paginate(collection, **options)
      will_paginate collection, renderer: WillPaginate::ActionView::Bootstrap4LinkRenderer, **options
    end

    def bs_collection_check_boxes(object, method, collection,
                                  value_method, text_method, options = {}, html_options = {}, &block)
      Tags::CollectionCheckBoxes.new(object, method, self, collection,
                                     value_method, text_method, options, html_options).render(&block)
    end

    def bs_link_to(name = nil, path = nil, active: nil, force_link: false, **options, &block)
      name, path = block_given? ? [block, name] : [name, path]

      if !block_given? && name.is_a?(Symbol)
        name = translate_name(path, name) || translate_name(options, name) || I18n.t("helpers.label.#{name}")
      end

      options[:class] = [options[:class], 'active'].join(' ') if active.present? && params_eval(**active)

      # noinspection RubyResolve
      path = url_for(path) if path.is_a? Hash

      if !force_link && request.path == path
        # noinspection RubyResolve
        tag.span class: options[:class] do
          block_given? ? capture(&block) : name
        end
      else
        block_given? ? link_to(path, options, &block) : link_to(name, path, options)
      end
    end

    def translate_name(options, name)
      return unless options.is_a? Hash

      if options.key? :model_class
        options.delete(:model_class).human_attribute_name name
      elsif options.key? :model
        options.delete(:model).class.human_attribute_name name
      elsif options.key? :controller_class
        I18n.t("controllers.#{options.delete(:controller_class).controller_name}.#{name}")
      elsif options.key? :controller
        I18n.t("controllers.#{options.delete(:controller)}.#{name}")
      end
    end
  end
end
