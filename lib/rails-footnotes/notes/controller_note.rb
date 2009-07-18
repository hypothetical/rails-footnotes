require "#{File.dirname(__FILE__)}/abstract_note"

module Footnotes
  module Notes
    class ControllerNote < AbstractNote
      def initialize(controller)
        @controller = controller
      end

      def row
        :edit
      end

      def link
        escape(Footnotes::Filter.prefix(controller_filename, controller_line_number + 1, 3))
      end

      def valid?
        prefix?
      end

      protected
        # Some controller classes come with the Controller:: module and some don't
        # (anyone know why? -- Duane)
        def controller_filename
          File.join(File.expand_path(RAILS_ROOT), 'app', 'controllers', "#{@controller.class.to_s.underscore}.rb").sub('/controllers/controllers/', '/controllers/')
        end

        def controller_text
          @controller_text ||= IO.read(controller_filename)
        end

        def action_index
          (controller_text =~ /def\s+#{@controller.action_name}[\s\(]/)
        end

        def controller_line_number
          lines_from_index(controller_text, action_index) || 0
        end

        def lines_from_index(string, index)
          return nil if string.blank? || index.blank?

          lines = [] #string.respond_to?(:to_a) ? string.to_a : string.lines.to_a
          running_length = 0
          lines.each_with_index do |line, i|
            running_length += line.length
            if running_length > index
              return i
            end
          end
        end
    end
  end
end