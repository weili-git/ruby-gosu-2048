# Encoding: UTF-8

require "gosu"

module ZOrder
  BACKGROUND, STARS, PLAYER, UI = *0..3
end
@@dict = Hash.new(0xff_111111)
@@dict = {"0" => 0xff_cdc1b4, "2" => 0xff_eee4da, "4" => 0xff_ede0c8, "8" => 0xff_f2b179, "16" => 0xff_f59563,
        "32" => 0xff_f67c5f, "64" => 0xff_f65e3b, "128" => 0xff_edcf72, "256" => 0xff_edcc61, "512" => 0xff_ecc850,
        "1024" => 0xff_ebc33d, "2048" => 0xff_eec22d}
class Map4x4
  attr_reader :map
  def initialize
    @terminate = false
    @size = 4
    @map = Array.new(4) { Array.new(4, 0) }
    2.times do 
      self.add 
    end
    self.print
  end

  def print
    system("cls")
    @map.each do |a|
      puts a.to_s
    end
    puts "\n"
  end

  # 新增2或4，有1/4概率产生4
  def add
    while true
      p = rand(@size*@size)
      if @map[p / @size][p % @size] == 0
        x = rand(4) > 0 && 2 || 4  # 1/4 false, and or lowest priority
        @map[p / @size][p % @size] = x
        break
      end
    end
  end

  # 地图向左靠拢，其他方向通过旋转实现，返回地图是否更新
  def adjust
    changed = false
    @map.each_with_index do |a, i|
      b = []
      last = 0
      a.each do |v|
        if v!=0
          if v==last
            b.push b.pop << 1
            last = 0
          else
            b.push v
            last = v
          end
        end
      end
      (@size-b.length).times do 
        b.push(0) # 补0
      end
      changed = true unless a.eql? b
      @map[i] = b  #a[:] = b
    end
    return changed
  end

  # 地图逆时针旋转90度
  def rotate
    @map = @map.transpose.reverse
  end

  def check_lose
    for i in 0..(@size-1)
      for j in 0..(@size-1)
        return false if @map[i][j] == 0
        return false if j<=@size-2 && @map[i][j] == @map[i][j+1]
        return false if i<=@size-2 && @map[i][j] == @map[i+1][j]
      end
    end
    system("cls")
    puts "Game over."
    @terminate = true
    return true
  end

  def check_win
    if @map.flatten.max == 2048
      system("cls")
      puts "You win!"
      @terminate = true
      return true
    end 
  end

  def moveUp
    return if @terminate
    self.rotate
    self.add if self.adjust
    3.times do 
      self.rotate 
    end
    self.print
  end

  def moveRight
    return if @terminate
    2.times do 
      self.rotate 
    end
    self.add if self.adjust
    2.times do 
      self.rotate 
    end
    self.print
  end

  def moveDown
    return if @terminate
    3.times do
      self.rotate
    end
    self.add if self.adjust
    self.rotate
    self.print
  end

  def moveLeft
    return if @terminate
    self.add if self.adjust
    self.print
  end
  
end

class MainLoop < Gosu::Window
  def initialize
    super 612, 612
    self.caption = "Gosu 2048"
    @p = 20  # padding
    @w, @h = 128, 128
    @m = Map4x4.new
    @font = Gosu::Font.new(30)
  end

  def needs_cursor?
    true
  end

  def update
  end

  def draw
    Gosu.draw_rect(0, 0, 612, 612, Gosu::Color.argb(0xff_bbada0))
    @m.map.each_with_index do |u, i|
      u.each_with_index do |v, j|
        Gosu.draw_rect(@p+(@w+@p)*j, @p+(@h+@p)*i, @w, @h, Gosu::Color.argb(@@dict[v.to_s]))
        @font.draw_text_rel(v.to_s, @p+(@w+@p)*j+@w/2, @p+(@h+@p)*i+@h/2, 20, 0.5, 0.5, 1.0, 1.0, Gosu::Color::BLACK)
      end
    end
  end

  def button_down(id)
    case id
    when Gosu::KB_LEFT
      @m.moveLeft
      @m.check_lose
      @m.check_win
    when Gosu::KB_RIGHT
      @m.moveRight
      @m.check_lose
      @m.check_win
    when Gosu::KB_UP
      @m.moveUp
      @m.check_lose
      @m.check_win
    when Gosu::KB_DOWN
      @m.moveDown
      @m.check_lose
      @m.check_win
    when Gosu::KB_ESCAPE
      close
    else
      super
    end
  end
end

MainLoop.new.show if __FILE__ == $0
