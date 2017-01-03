require "gosu"
# require_relative "lib/menu"
require_relative "lib/text"
Modifier = Struct.new(:value, :dangerous_amount, :fatal_amount, :decrease_per_second, :time_at_last_change)
class Window < Gosu::Window
  def initialize
    $window = self
    super(800, 600, false)
    @dead  = false
    @time  = rand(3..7)*60*60*24
    @speed = rand(10..25)
    @dt    = (Gosu.milliseconds/1000.0)
    @clock = Game::Text.new(seconds_to_time(@time), x: 0, y: 36, color: Gosu::Color::WHITE, size: 24)
    @font  = Gosu::Font.new($window, Gosu.default_font_name, 30)
    @clock.x    = @clock.width/4
    @max_value = 100.0
    @spacer    = 120

    @hunger = Modifier.new
    @hunger.value = 100.0
    @hunger.dangerous_amount = 25.0
    @hunger.fatal_amount = 0.0
    @hunger.decrease_per_second = 0.01
    @hunger.time_at_last_change = (Gosu.milliseconds/1000.0)*@speed

    @hydration = Modifier.new
    @hydration.value = 70.0
    @hydration.dangerous_amount = 100.0
    @hydration.fatal_amount = 0.0
    @hydration.decrease_per_second = 0.05
    @hydration.time_at_last_change = (Gosu.milliseconds/1000.0)*@speed

    @happiness = Modifier.new
    @happiness.value = 100.0
    @happiness.dangerous_amount = 35.0
    @happiness.fatal_amount = 0.0
    @happiness.decrease_per_second = 0.03
    @happiness.time_at_last_change = (Gosu.milliseconds/1000.0)*@speed

    self.caption = "Against the Clock - FPS:#{Gosu.fps}"
  end

  def line(x, y, color = Gosu::Color::BLACK)
    fill_rect(x, y, 2, 25, color)
  end

  def draw
    @clock.draw

    fill_rect(@spacer, 100, @max_value*5, 25, Gosu::Color::GRAY)
    fill_rect(@spacer, 100, ((@hunger.value/@max_value)*100.0)*5, 25, Gosu::Color.rgb(100,0,30)) unless @hunger.value < 0
    line(((@hunger.dangerous_amount/@max_value)*100.0)*5+@spacer, 100)
    @font.draw("Food", @spacer+20, 100, 1)
    @font.draw("DEATH", 20, 100, 1)
    @font.draw("LIFE", 500+@spacer+36, 100, 1)

    fill_rect(@spacer, 150, @max_value*5, 25, Gosu::Color::GRAY)
    fill_rect(@spacer, 150, ((@hydration.value/@max_value)*100.0)*5, 25, Gosu::Color::BLUE) unless @hydration.value < 0
    line(((@hydration.dangerous_amount/@max_value)*100.0)*5+@spacer, 150)
    @font.draw("Hydration", @spacer+20, 150, 1)
    @font.draw("DEATH", 20, 150, 1)
    @font.draw("LIFE", 500+@spacer+36, 150, 1)

    fill_rect(@spacer, 200, @max_value*5, 25, Gosu::Color::GRAY)
    fill_rect(@spacer, 200, ((@happiness.value/@max_value)*100.0)*5, 25, Gosu::Color.rgb(0,100,0)) unless @happiness.value < 0
    line(((@happiness.dangerous_amount/@max_value)*100.0)*5+@spacer, 200)
    @font.draw("Happiness", @spacer+20, 200, 1)
    @font.draw("DEATH", 20, 200, 1)
    @font.draw("LIFE", 500+@spacer+36, 200, 1)
    if @dead

    end
  end

  def update
    update_clock unless @dead
    @dt = (Gosu.milliseconds/1000.0)
    self.caption = "Against the Clock - FPS:#{Gosu.fps} - @speed: #{@speed} - #{((@happiness.value/@max_value)*100.0)*5}"

    check_modifier(@hunger)

    check_modifier(@hydration)

    check_modifier(@happiness)

    if @time <= 0
      @dead = true
      @clock.text = "You have died."
    end
  end

  def check_modifier(modifier)
    current_time = (Gosu.milliseconds/1000.0)*@speed
    if current_time-modifier.time_at_last_change >= 1.0
      modifier.value-=modifier.decrease_per_second
      modifier.time_at_last_change = current_time
    end

    if modifier.value <= modifier.dangerous_amount
      @time -= modifier.decrease_per_second*@speed
    end
  end

  def update_clock
    @time-=((Gosu.milliseconds/1000.0)-@dt)*@speed
    @clock.text = "You will die in "+seconds_to_time(@time)
  end

  def seconds_to_time(seconds)
    '%d days, %d hours, %d minutes, %d seconds' %
      # the .reverse lets us put the larger units first for readability
      [24,60,60].reverse.inject([seconds]) {|result, unitsize|
        result[0,0] = result.shift.divmod(unitsize)
        result
      }
  end

  def fill_rect(x, y, width, height, color, z = 0, mode = :default)
  return $window.draw_quad(x, y, color,
                           x, height+y, color,
                           width+x, height+y, color,
                           width+x, y, color,
                           z, mode)
  end
end

Window.new.show
