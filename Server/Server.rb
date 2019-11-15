require_relative 'Game'
require 'socket'
class Server
    def initialize(socket_address, socket_port)
       @server_socket = TCPServer.new(socket_address,socket_port)
 
       @connections_details = Hash.new
       @connected_players = Hash.new
 
       @connections_details[:server] = @server_socket
       @connections_details[:clients] = @connected_players
       @players_cont = 0
       @players = Hash.new
       @waiting_players = []
       @waiting = false
       @threads = []

       puts 'Started server.........'
       @threads << Thread.new { run }
       @threads << Thread.new { establish_game }

       @threads.map(&:join)
     end
 
   def run
 
     loop{
       client_connection = @server_socket.accept
       Thread.start(client_connection) do |conn| 
         @players_cont += 1
         conn_name = "Jugador #{@players_cont}"
 
         puts "Conexión establecida con el #{conn_name} => #{conn}"
         @connections_details[:clients][conn_name] = conn
         conn.send "Eres el #{conn_name} => #{conn}", 0
         conn.send "Buscando jugadores...", 0
         @waiting_players.push({conn_name => conn})
       end
       }.join
    end

    def waiting_start()
      @waiting = true
      Thread.new do
        @time = 30
        count_down = Thread.new{
          30.times do |i|
            sleep 1
            @time -= 1


          end}

        sending = Thread.new{
          while(@time>0)
            telling_players(@players, "\nSe ha encontrado #{@players.count}/4, el juego empezara en #{@time} segundos.")
            sleep 1
            if @players.count == 4
              break
            end
          end
        }.join

          count_down.exit
          sending.exit
          otros = @players
          @players = Hash.new
          @waiting = false
          Thread.new{Game.new(otros)}.join
      end
    end

    def telling_players(players, message)
        players.each do |nombre, conn| 
        begin        
          conn.send "#{message}\n", 0
        rescue => exception
          @players.delete(nombre)
          puts "Se desconectó #{nombre}"
        end
      end
    end
 
    def establish_game()
      loop do
        while @players.count < 2
          if @waiting_players.size != 0
            @players = @waiting_players.pop.merge(@players)
          end
        end
        Thread.new {waiting_start} unless @waiting
        while @players.count < 4 || @waiting
          break unless @waiting
          if @waiting_players.size != 0
            @players = @waiting_players.pop.merge(@players)
          end
        end
        sleep 1
      end
    end
 end
 
 
 Server.new( "#{URI.parse("https://limitless-beyond-42308.herokuapp.com/").host}", 8080 )