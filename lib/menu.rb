module Game
  Button = Struct.new(:text, :rect, :background_color, :proc)
  Input  = Struct.new(:text, :rect, :focus, :secret, :value, :text_input)

  class Scene
    class Menu < Chingu::GameState
      def setup
        $window.show_cursor = true

        @elements = []
        @background = Gosu::Color.rgba(45,45,76,89)
        @y = 20
        @z = -5

        prepare if defined?(self.prepare)
        @max_button_width = 0
        @least_button_x   = Gosu.screen_width
        @elements.each do |e|
          if e.is_a?(Game::Button)
            if e.text.x < @least_button_x; then @least_button_x = e.text.x; end
            if e.rect[2] > @max_button_width then @max_button_width = e.rect[2]; end
          end
        end
        p @max_button_width, @least_button_x
        @elements.each {|e| if e.is_a?(Game::Button); e.rect[0] = @least_button_x-10;end}
        @elements.each {|e| if e.is_a?(Game::Button); e.rect[2] = @max_button_width;end}
      end

      def draw
        super
        fill(@background, @z)
        @elements.each do |e|
          if e.is_a?(Game::Text)
            e.draw
          elsif e.is_a?(Game::Button)
            e.text.draw
            fill_rect(e.rect, e.background_color)
            if $window.mouse_x.between?(e.rect[0], e.rect[0]+e.rect[2])
              if $window.mouse_y.between?(e.rect[1], e.rect[1]+e.rect[3])
                fill_rect(e.rect, Gosu::Color.rgba(56,45,89,212))
              end
            end
          elsif e.is_a?(Game::Input)
            e.text.draw
            if e.focus
              fill_rect(e.rect, Gosu::Color.rgba(56,45,89,212))
            else
              fill_rect(e.rect, Gosu::Color::GRAY)
            end
            if $window.mouse_x.between?(e.rect[0], e.rect[0]+e.rect[2])
              if $window.mouse_y.between?(e.rect[1], e.rect[1]+e.rect[3])
                fill_rect(e.rect, Gosu::Color.rgba(56,45,89,212))
              end
            end
          end
        end
      end

      def update
        super

        @elements.each do |e|
          # Center text
          e.x = $window.width/2-e.width/2 if e.is_a?(Game::Text)

          if e.is_a?(Game::Input)
            e.rect[2] = e.text.width+20
            e.value = e.text_input.text

            if e.focus == true
              e.text.text = e.text_input.text
              e.value = e.text_input.text
              e.text.x = $window.width/2-e.text.width/2
              e.rect[0] = e.text.x-10

              $window.text_input = e.text_input unless $window.text_input == e.text_input
            end
          end
        end
      end

      def background(color, z = -5)
        raise "Color must be a Gosu::Color" unless color.is_a?(Gosu::Color)
        @background = color
        @z = z if z.is_a?(Integer)
      end

      def title(string)
        text = Game::Text.new(string, y: @y, size: 80)
        text.x = $window.width/2-text.width/2

        @elements.push(text)
        @y+=(text.height/3)+text.height

        return text
      end

      def label(string, options={}, proc = nil)
        options[:y] ||= @y
        options[:size] ||= 26

        text = Game::Text.new(string, options)
        text.x = $window.width/2-text.width/2

        @elements.push(text)
        @y+=(text.height*2)

        return text
      end

      def edit_line(string = "", options = {})
        options[:y]      ||= @y
        options[:size]   ||= 26
        options[:focus]  ||= false
        options[:secret] ||= false

        text  = Game::Text.new(string, options)
        text.x = $window.width/2-text.width/2

        x = text.x-10
        y = text.y-10
        width  = 120
        height = text.height+20

        input = Game::Input.new
        input.text = text
        input.focus= options[:focus]
        input.secret = options[:secret]
        input.text_input = Gosu::TextInput.new
        input.text_input.text = string
        input.rect = [x,y, width,height]

        @elements.push(input)
        @y+=(height/2)+height
        return input
      end

      def button(string, &block)
        text   = Game::Text.new(string, y: @y, size: 26)
        text.x = $window.width/2-text.width/2
        x = text.x-10
        y = text.y-10
        width  = text.width+20
        height = text.height+20

        button = Game::Button.new
        button.text = text
        button.rect = [x,y, width,height]
        button.background_color = Gosu::Color.rgba(0,45,89,212)
        button.proc = block

        @elements.push(button)
        @y+=(height/2)+height

        return button
      end

      def button_up(id)
        case id
        when Gosu::MsLeft
          @elements.each do |e|
            next unless e.is_a?(Game::Button) or e.is_a?(Game::Input)
            if e.is_a?(Game::Button) && $window.mouse_x.between?(e.rect[0], e.rect[0]+e.rect[2])
              if $window.mouse_y.between?(e.rect[1], e.rect[1]+e.rect[3])
                e.proc.call if e.proc.is_a?(Proc)
              end
            end

            if e.is_a?(Game::Input) && $window.mouse_x.between?(e.rect[0], e.rect[0]+e.rect[2])
              if $window.mouse_y.between?(e.rect[1], e.rect[1]+e.rect[3])
                @elements.each {|_e| next unless _e.is_a?(Game::Input);_e.focus = false}
                $window.text_input = e.text_input; e.focus = true
              end
            end
          end
        end
      end
    end
  end
end
