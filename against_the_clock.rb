require "gosu"
# require_relative "lib/menu"
require_relative "lib/text"
Modifier = Struct.new(:name, :value, :dangerous_amount, :fatal_amount, :decrease_per_second, :time_at_last_change, :bar_color, :death_messages)
class Window < Gosu::Window
  def initialize
    $window = self
    super(800, 600, false)
    @dead  = false
    @time  = (7)*60*60*24
    @speed = 1997#rand(900..1000)
    @dt    = (Gosu.milliseconds/1000.0)
    @clock = Game::Text.new(seconds_to_time(@time), x: 0, y: 36, color: Gosu::Color::WHITE, size: 24)
    @cause_of_death = Game::Text.new("", x: 36, y: 300, color: Gosu::Color::WHITE, size: 24)
    @font  = Gosu::Font.new($window, Gosu.default_font_name, 30)
    @clock.x    = @clock.width/4
    @max_value = 100.0
    @spacer    = 120
    @modifiers = []

    @hunger = Modifier.new
    @hunger.name  = "Food"
    @hunger.value = 100.0
    @hunger.dangerous_amount = 25.0
    @hunger.fatal_amount = 0.0
    @hunger.decrease_per_second = 0.001
    @hunger.time_at_last_change = (Gosu.milliseconds/1000.0)*@speed
    @hunger.bar_color = Gosu::Color.rgb(100,0,30)
    @hunger.death_messages = ["Got lost in a desert without food.", "Lost your ration pack."]

    @hydration = Modifier.new
    @hydration.name  = "Hydration"
    @hydration.value = 100.0
    @hydration.dangerous_amount = 60.0
    @hydration.fatal_amount = 0.0
    @hydration.decrease_per_second = 0.005
    @hydration.time_at_last_change = (Gosu.milliseconds/1000.0)*@speed
    @hydration.bar_color = Gosu::Color::BLUE
    @hydration.death_messages = ["Got lost in a desert without water.", "Dried up like a raisin."]

    @happiness = Modifier.new
    @happiness.name  = "Happiness"
    @happiness.value = 100.0
    @happiness.dangerous_amount = 35.0
    @happiness.fatal_amount = 0.0
    @happiness.decrease_per_second = 0.003
    @happiness.time_at_last_change = (Gosu.milliseconds/1000.0)*@speed
    @happiness.bar_color = Gosu::Color.rgb(0,100,0)
    @happiness.death_messages = ["Got lost in a daydream while driving.", "Lost your your will to live."]

    add_modifier(@hunger)
    add_modifier(@hydration)
    add_modifier(@happiness)

    self.caption = "Against the Clock - FPS:#{Gosu.fps}"
  end

  def line(x, y, color = Gosu::Color::BLACK)
    fill_rect(x, y, 2, 25, color, 10)
  end

  def add_modifier(modifier)
    @modifiers << modifier
  end

  def draw
    @clock.draw
    y = 100
    @modifiers.each do |modifier|
      fill_rect(@spacer, y, @max_value*5, 25, Gosu::Color::GRAY)
      fill_rect(@spacer, y, ((modifier.value/@max_value)*100.0)*5, 25, modifier.bar_color) unless modifier.value < 0
      line(((modifier.dangerous_amount/@max_value)*100.0)*5+@spacer, y)
      @font.draw("#{modifier.name}", @spacer+20, y, 1)
      @font.draw("DEATH", 20, y, 1)
      @font.draw("LIFE", 500+@spacer+16, y, 1)

      y+=50
    end

    if @dead
      @cause_of_death.draw
    end
  end

  def update
    update_clock unless @dead
    @dt = (Gosu.milliseconds/1000.0)
    self.caption = "Against the Clock - FPS:#{Gosu.fps} - @speed: #{@speed} - #{((@happiness.value/@max_value)*100.0)*5}"

    unless @dead
      @modifiers.each {|m| check_modifier(m)}
    end

    if @time <= 0 && !@dead
      @dead = true
      @clock.text = "You died, ran out if time."#+seconds_to_time(@time)
    end
  end

  def check_modifier(modifier)
    current_time = (Gosu.milliseconds/1000.0)*@speed
    if current_time-modifier.time_at_last_change >= 1.0
      modifier.value-=modifier.decrease_per_second
      modifier.time_at_last_change = current_time
    end

    if modifier.value <= modifier.dangerous_amount
      @time -= modifier.decrease_per_second
    end

    if modifier.value <= modifier.fatal_amount && !@dead
      @time = 0
      @dead = true
      n = rand(0..modifier.death_messages.count-1)
      @cause_of_death.text = "#{modifier.death_messages[n]}"
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
