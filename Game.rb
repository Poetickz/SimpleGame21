require_relative 'Deck'
require 'socket'

class Game
    
    attr_accessor :deck_cards, :players, :plays, :status_player

    def initialize(players)
        @deck_cards = []
        @plays = Hash.new
        @status_player = Hash.new
        4.times { @deck_cards.concat(Deck.new.deck_cards)}
        @players = players
        @players.each { |player,connection| @plays[player] = [] }
        @players.each { |player,connection| @status_player[player] = "Free" }
        give_initialize_cards
        play
    end

    def give_initialize_cards
        @players.each do |player, connection|
            2.times { give_card(player) }
        end
    end

    def give_card(player_name)
        new_card = @deck_cards.pop
        @plays[player_name].push(new_card)
        @players[player_name].send "#{new_card.print_card}", 0
        puts "#{player_name} se le asigno #{new_card.print_card}"
    end

    def hold(player_name)
      @status_player[player_name] = "Hold"
    end

    def count_total_player(player_name)
      total = 0
      @plays[player_name].each { |card| total += card.value_card }
      return total
    end

    def make_turn(player)

      if want_hold?(player)
        return true
      end

      give_card(player)
      
      if count_total_player(player) > 21
        kill_player(player)
      end
    end

    def is_hold?(player_name)
      return true if @status_player[player_name] == "Hold"
      return false
    end

    def kill_player(player_name)
      @status_player[player_name] = "Out"
      puts "El jugador #{player_name} se paso más de 21"
      @player[player_name].send "Te has pasado de 21", 0
    end

    def want_hold?(player_name)
      connection = @players[player_name]
      connection.send "¿Quieres hold o call?", 0
      answer = connection.recv(1024)
      return true if answer == "Hold"
      return false
    end

    def play_round
      @players.each do |player, connection|
        if @status_player[player] == "Free"
          make_turn(player)
        end
      end
    end

    def all_finished?
      answer = true
      @status_player.each { |player, status| answer = false if status == "Free" }
      return answer
    end

    def who_wins?
      winner_point = 0
      losers = []
      winner = []
      @players.each do |player_name, connection|
        if @status_player[player_name] != "Out"
          player_total = count_total_player[player_name]
          if player_total == winner_point
            winner.push(player_name)
          elsif player_total > winner_point
            winner = ["#{player_name}"]
          else 
            losers.push(player_name)
          end
        end
      end

      puts "Gano el jugador:"
      winner.each { |player|  puts "#{player}"}
      notificate_winners(winner)
      notificate_losers(losers)
    end

    def notificate_winners(winners)
      winners.each do |player|
        @players[player].send "Ganaste, felicidades", 0
      end
    end

    def notificate_losers(losers)
        losers.each do |player|
          @players[player].send "Perdiste, mas suerte la proxima", 0
        end
    end

    def play
      loop do
        play_round
        break if all_finished?
      end

      who_wins?
    end

end