#
#
#
#
#
#
#
#
#
#
#
#

require 'rspec'

class Player
  def initialize(name)
    @name=name
  end
end

class Game

  FIELD_SIZE=3

  def initialize(player1, player2, listener)
    @player1=player1
    @player2=player2
    @playing_field=Hash.new
    @turn=nil
    @status = :continue
    @listener = listener
  end

  def move(player, x, y)
    return false if @turn==player
    return false unless in_playing_field?(x, y)
    return false if @playing_field.include?([x, y])
    return false if @status != :continue
    @playing_field[[x, y]]=player
    @turn=player
    check_for_end
    true
  end

  def check_for_victory
    check_for_row || check_for_column || check_for_diagonal
  end

  def check_for_diagonal
    victory = true
    type = @playing_field[[1, 1]]
    (1..FIELD_SIZE).each do |x|
      if type.nil? || type != @playing_field[[x, x]]
        victory = false
        break
      end
    end

    victory = true
    type = @playing_field[[1, FIELD_SIZE]]
    (1..FIELD_SIZE).each do |x|
      if type.nil? || type != @playing_field[[x, FIELD_SIZE+1-x]]
        victory = false
        break
      end
    end

    if victory
      type==@player1 ? @listener.set_status(:victory1) : @listener.set_status(:victory2)
    end
    victory
  end

  def check_for_column
    victory = true
    type = nil
    (1..FIELD_SIZE).each do |x|
      victory = true
      type = @playing_field[[1, x]]
      if type.nil?
        victory = false
        next
      end
      (2..FIELD_SIZE).each do |y|
        if type != @playing_field[[y, x]]
          victory = false
          break
        end
      end
      break if victory == true
    end
    if victory
      type==@player1 ? @listener.set_status(:victory1) : @listener.set_status(:victory2)
    end
    victory
  end

  def check_for_row
    victory = true
    type = nil
    (1..FIELD_SIZE).each do |x|
      victory = true
      type = @playing_field[[x, 1]]
      if type.nil?
        victory = false
        next
      end
      (2..FIELD_SIZE).each do |y|
        if type != @playing_field[[x, y]]
          victory = false
          break
        end
      end
      break if victory == true
    end
    if victory
      type==@player1 ? @listener.set_status(:victory1) : @listener.set_status(:victory2)
    end
    victory
  end

  def check_for_end()
    if check_for_victory
    elsif @playing_field.size==FIELD_SIZE**2
      @status = :over
      @listener.set_status(:draw)
    end
  end

  def in_playing_field?(x, y)
    0 < x && x <= FIELD_SIZE && 0 < y && y <= FIELD_SIZE
  end


end

class GameListener

  def initialize
    @status=:empty
  end

  def set_status(status)
    @status=status
  end

  def is_over?
    @status==:draw || @status==:victory1 || @status==:victory2
  end

  def is_draw?
    @status==:draw
  end

end


RSpec.describe Game do
  let(:player1) { Player.new("peto") }
  let(:player2) { Player.new("jozo") }
  let(:listener) { GameListener.new }
  let(:game) { Game.new(player1, player2, listener) }
  # player1=Player.new("peto")
  # player2=Player.new("jozo")
  # game=Game.new(player1,player2)

  it "correct moves" do
    expect(game.move(player1, 1, 1)).to eq true
    expect(game.move(player2, 1, 2)).to eq true
    expect(game.move(player1, 2, 1)).to eq true
  end

  it 'incorrect moves' do
    expect(game.move(player1, 1, 1)).to eq true
    expect(game.move(player1, 1, 2)).to eq false
    expect(game.move(player2, 5, 5)).to eq false
    expect(game.move(player2, 1, 1)).to eq false
    expect(game.move(player2, 0, 2)).to eq false
  end

  describe "Game Over" do

    it "checks full playing field" do
      game.move(player1, 1, 1)
      expect(listener.is_over?).to eq false
      game.move(player2, 1, 2)
      game.move(player1, 1, 3)
      game.move(player2, 2, 1)
      game.move(player1, 2, 3)
      game.move(player2, 2, 2)
      game.move(player1, 3, 1)
      game.move(player2, 3, 3)
      game.move(player1, 3, 2)
      expect(listener.is_over?).to eq true
      expect(listener.is_draw?).to eq true
    end

    it "checks for row victory" do
      game.move(player1, 1, 1)
      game.move(player2, 2, 1)
      game.move(player1, 1, 2)
      game.move(player2, 2, 2)
      game.move(player1, 1, 3)
      expect(listener.is_over?).to eq true
      expect(listener.is_draw?).to eq false
    end

    it "checks for column victory" do
      game.move(player1, 1, 1)
      game.move(player2, 2, 2)
      game.move(player1, 2, 1)
      game.move(player2, 3, 2)
      game.move(player1, 3, 1)
      expect(listener.is_over?).to eq true
      expect(listener.is_draw?).to eq false
    end

    it "checks for diagonal victory" do
      game.move(player1, 1, 1)
      expect(listener.is_over?).to eq false
      game.move(player2, 1, 2)
      game.move(player1, 1, 3)
      game.move(player2, 2, 1)
      game.move(player1, 2, 2)
      game.move(player2, 2, 3)
      game.move(player1, 3, 1)
      game.move(player2, 3, 2)
      game.move(player1, 3, 3)
      expect(listener.is_over?).to eq true
      expect(listener.is_draw?).to eq false
    end

  end

end

puts "player1 name: "
name = gets
player1=Player.new(name)
puts "player2 name: "
name = gets
player2=Player.new(name)
listener=GameListener.new
game=Game.new(player1,player2,listener)

until listener.is_over? do


end



