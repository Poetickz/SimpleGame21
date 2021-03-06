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

    #Relatable to game
    def give_initialize_cards
        @players.each do |player, connection|
          2.times { give_card(player) }
        end
    end

    def play
      loop do
        play_round
        break if all_finished?
      end

      who_wins?
      end_game

    end

    def play_round
      @players.each do |player, connection|
        if @status_player[player] == "Free"
          make_turn(player)
        end
      end
    end

    def make_turn(player)

      if want_hold?(player)
        return true
      end

      give_card(player)
      sleep 1

      if count_total_player(player) > 21
        kill_player(player)
      end
    end

    def who_wins?
      winner_point = 0
      losers = []
      winner = []
      already_bj = false
      @players.each do |player_name, connection|
        if @status_player[player_name] != "Out"
          jugadas = ""
          @plays[player_name].each { |card| jugadas += "#{card.print_card} " }
          player_total = max_count(player_name)
          black_jack = is_blackjack?(player_name)
          puts "#{player_name} tiene: #{jugadas} total: #{player_total}"
          already_bj = true if black_jack

          if already_bj
            winner.push(player_name)
            winner = winner.delete_if {|winner| not is_blackjack?(winner) }
          else
            if ((player_total == winner_point && player_total <= 21))
              winner.push(player_name)
            elsif (player_total > winner_point && player_total <= 21)
              winner_point = player_total
              winner = ["#{player_name}"]  
            else
            end
          end

        end
      end

      puts "Gano el jugador:"
      winner.each { |player|  puts "#{player}"}
      @players.each { |player_name, connection| losers.push(player_name) unless winner.include?(player_name)} 
      notificate_winners(winner)
      notificate_losers(losers)
    end

    def end_game
      @players.each { |player,connection| telling("kill", player) }
    end


    #Relatable comunication
    def telling(message, player_name)
      begin
        @players[player_name].send "#{message}", 0
        sleep 1
      rescue => exception
        @players.delete(player_name)
        @status_player[player_name] = "Out"
        puts "Se desconectó #{player_name}"
      end
    end

    def asking(message, player_name)
      begin
      @players[player_name].send "\n#{message}", 0
      sleep 1
      rescue => exception
        @players.delete(player_name)
        @status_player[player_name] = "Out"
        puts "Se desconectó #{player_name}"
        return "hold"
      end
      msg =  @players[player_name].recv(1024)
      return msg
    end

    def want_hold?(player_name)
      answer = asking("¿Quieres hold o call?", player_name)
      if answer == "hold"
        @status_player[player_name]= "Hold"
        return true
      end
      return false
    end

    def give_card(player_name)
      new_card = @deck_cards.pop
      @plays[player_name].push(new_card)
      telling(new_card.print_card, player_name)
      puts "#{player_name} se le asigno #{new_card.print_card}"
    end

    def notificate_winners(winners)
      winners.each do |player|
        telling("Ganaste, felicidades", player)
      end
    end

    def notificate_losers(losers)
        losers.each do |player|
          telling("Perdiste, mas suerte la proxima", player)
        end
    end

    
    #Relatable Game Process
    def max_count(player_name)
      total = [0]
      @plays[player_name].each do |card|
        
        if card.value_card != "A"
          total = total.map { |e| e += card.value_number }
        else
          aux_total =  total.dup
          aux_total = total.map { |e| e += 11 }
          total = total.map { |e| e += card.value_number }
          total += aux_total
        end
      end
      total = total.delete_if {|e| e > 21}
      return total.max
    end

    def count_total_player(player_name)
      total = 0
      @plays[player_name].each { |card| total += card.value_number }
      return total
    end

    def is_hold?(player_name)
      return true if @status_player[player_name] == "Hold"
      return false
    end

    def kill_player(player_name)
      @status_player[player_name] = "Out"
      puts "El jugador #{player_name} se paso más de 21"
      telling("Te has pasado de 21", player_name)
    end
    
    def is_blackjack?(player_name)
      if @plays[player_name].size == 2
        has_As = false
        @plays[player_name].each { |card| has_As = true if (card.value_card == "A")}
        return false if ! has_As
        @plays[player_name].each do |card|
          if (card.value_card == "Q" || card.value_card == "K"  || card.value_card == "J" )
            return true
          end
        end
        return false
      end

      
    end

    def all_finished?
      answer = true
      @status_player.each { |player, status| answer = false if status == "Free" }
      return answer
    end

end