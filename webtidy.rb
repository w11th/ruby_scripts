require 'camping'
require 'tidy'

Camping.goes :WebTidy

module WebTidy
  module Controllers
    class Index < R '/'
      def get
        if @input[:html]
          @html_output = Tidy.open('indent' => 'auto') do |tidy|
            tidy.clean(@input[:html])
          end
        end
        render :homepage
      end
    end
  end

  module Views
    TIME_FORMAT = '%H:%M:%S'

    def homepage
      p 'Input Text:'
      form do
        textarea @input[:html], cols: 45, rows: 5, name: html
        br clear: left
        input type: submit, value: Send
      end

      textarea @html_output, cols: 45, rows: 5, name: html if @html_output
    end

    def layout
      html do
        head do
          title 'WebTidy'
        end
        body do
          h1 'Welcome to webtidy'
          div.content do
            self << yield
          end
        end
      end
    end
  end
end
