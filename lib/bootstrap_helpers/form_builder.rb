# frozen_string_literal: true

require 'action_view'

module BootstrapHelpers
  #
  # フォームビルダー
  #
  class FormBuilder < ActionView::Helpers::FormBuilder
    delegate :tag, :concat, :capture, to: :@template

    def link_to(method_or_value, url, **options)
      # noinspection RubyResolve
      @template.link_to caption(method_or_value), url, **options
    end

    def bs_static_field(method, label: true, helper: nil, unit: nil, attribute: nil, multiple: false)
      render method, label: label, class: options.delete(:class) do
        value = object&.send method
        value = value&.send attribute if attribute.present?

        content = if block_given?
                    capture do
                      yield value, method, object
                    end.html_safe
                  elsif helper.present?
                    template.send(helper, value)
                  else
                    value.to_s
                  end

        content_class = ['field-content', ('text-right' if unit.present?)].compact.join(' ')
        content = [content, unit].select(&:present?).join if content.present? && unit.present?

        tag.div content, class: content_class
      end
    end

    def bs_email_field(method, label: true, static: false, **options)
      return bs_static_field method, label: label, **options if static

      render method, label: label, class: options.delete(:class) do
        email_field(method, class: 'form-control', **options)
      end
    end

    def bs_text_field(method, label: true, static: false, **options)
      return bs_static_field method, label: label, **options if static

      render method, label: label, class: options.delete(:class) do
        text_field(method, class: 'form-control', **options)
      end
    end

    def bs_telephone_field(method, label: true, static: false, **options)
      return bs_static_field method, label: label, **options if static

      render method, label: label, class: options.delete(:class) do
        telephone_field(method, class: 'form-control', **options)
      end
    end

    def bs_hidden_field(method, **options)
      concat hidden_field(method, **options)
      concat render_errors(method)
    end

    def bs_password_field(method, label: true, static: false, **options)
      return bs_static_field method, label: label, **options if static

      render method, label: label, class: options.delete(:class) do
        password_field(method, class: 'form-control', **options)
      end
    end

    def bs_date_field(method, label: true, static: false, **options)
      return bs_static_field method, label: label, **options if static

      render method, label: label, class: options.delete(:class) do
        date_field(method, class: 'form-control', **options)
      end
    end

    def bs_number_field(method, unit: nil, label: true, static: false, **options)
      return bs_static_field method, label: label, **options if static

      render method, grouping: unit.present?, label: label, class: options.delete(:class) do
        concat number_field(method, class: 'form-control text-right', **options)
        # noinspection RubyResolve
        concat(tag.div(class: 'input-group-append') { tag.span(unit, class: 'input-group-text') }) if unit.present?
      end
    end

    def bs_text_area(method, label: true, static: false, **options)
      return bs_static_field method, label: label, **options if static

      render method, label: label, class: options.delete(:class) do
        text_area(method, class: 'form-control', **options)
      end
    end

    def bs_collection_select(method, collection, value_method = :id, text_method = :name,
                             html: {}, label: true, static: false, **options)
      return bs_static_field method, label: label, attribute: text_method, **options if static

      html[:class] = 'form-control'
      render method, label: label, class: options.delete(:class) do
        method = [method, value_method].map(&:to_s).join('_')
        method = method.pluralize if html[:multiple]
        collection_select method,
                          collection, value_method, text_method, options, html
      end
    end

    def bs_collection_check_boxes(method, collection, value_method = :id, text_method = :name,
                                  html: {}, label: true, static: false, **options)
      return bs_static_field method, label: label, attribute: text_method, multiple: true if static

      render method, label: label, class: options.delete(:class) do
        method = [method.to_s.singularize, value_method].map(&:to_s).join('_')
        method = method.pluralize
        # noinspection RubyResolve
        @template.bs_collection_check_boxes @object_name, method,
                                            collection, value_method, text_method, options, html
      end
    end

    def bs_file_field(method, label: true, static: false, **options)
      return bs_static_field method, label: label, **options if static

      render method, label: label, class: options.delete(:class) do
        tag.div class: 'custom-file' do
          concat file_field(method, class: 'custom-file-input', **options)
          concat self.label(method, 'Choose file...', class: 'custom-file-label')
        end
      end
    end

    def bs_text_array(method, label: true, **options)
      values = object&.send method

      grip = tag.i class: 'fas fa-grip-vertical'

      items = capture do
        values&.each do |value|
          item = capture do
            tag.div class: 'custom-string-item' do
              concat grip
              concat text_field(method, multiple: true, value: value, id: nil, class: 'form-control', **options)
            end
          end

          concat item
        end
      end

      empty_item = capture do
        tag.div(class: 'custom-string-item') {
          concat grip
          concat text_field(method, multiple: true, id: nil, value: nil, class: 'form-control', **options)
        }
      end

      all_items = capture do
        tag.div class: 'custom-string-container' do
          concat items
          concat empty_item
        end
      end

      btn = button class: 'btn btn-sm btn-primary rounded-circle' do
        tag.i class: 'fas fa-plus'
      end

      render method, label: label, class: options.delete(:class) do
        tag.div class: 'custom-string' do
          concat all_items
          concat btn
        end
      end
    end

    def bs_check_box(method, checked_value: '1', unchecked_value: '0', container: true, **options)
      html = tag.div class: 'custom-control custom-checkbox' do
        options[:class] = ['custom-control-input', options[:class]].select(&:present?).join(' ')
        concat check_box(method, options, checked_value, unchecked_value)
        concat label(method, class: 'custom-control-label')
      end

      if container
        tag.div(class: 'custom-checkbox-container labeled') { html }
      else
        html
      end
    end

    def bs_submit(method_or_value = nil, **options)
      options[:class] = [options[:class], 'btn'].compact.join(' ')
      submit caption(method_or_value), **options
    end

    private

    def caption(method_or_value)
      if method_or_value.is_a? Symbol
        if object.is_a?(ActiveRecord::Base) || object.is_a?(ActiveModel::Translation)
          object.class.human_attribute_name(method_or_value)
        else
          I18n.t "helpers.label.#{method_or_value}"
        end
      else
        method_or_value
      end
    end

    def errors(method)
      object&.errors&.[](method)
    end

    def errors?(method)
      errors(method).present?
    end

    def render_errors(method)
      ee = errors method
      # noinspection RubyResolve
      tag.ul(class: 'errors-message') { ee.each { |error| concat tag.li(error) } } if ee.present?
    end

    def render(method, grouping: false, label:, **options, &block)
      css_class = [
        options[:class],
        'form-group',
        ('form-group-errors' if errors?(method))
      ].select(&:present?).join(' ')

      tag.div class: css_class do
        concat case label
               when Symbol
                 label(method, object.class.human_attribute_name(label))
               when String
                 label(method, label)
               when TrueClass
                 label(method)
               when FalseClass
                 nil
               else
                 raise TypeError
               end

        if grouping
          concat(tag.div(class: 'input-group') { capture(&block) })
        else
          concat capture(&block)
        end
        concat render_errors(method)
      end
    end
  end
end