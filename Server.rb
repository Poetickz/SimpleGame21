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
      puts "inicio"
      @waiting = true
      count_down = Thread.new do
        @time = 5
        5.times do |i|
          sleep 1
          @time -= 1

        end
        
      end

      sending = Thread.new{
        while(@time>0)
          telling_players(@players, "Buscando a más jugadores, el juego empezara en #{@time} segundos.")
          sleep 1
          if @players.count == 4
            Thread.kill(count_down)
            break
          end
        end
      }.join
        Thread.kill(count_down)
        Thread.kill(sending)
        otros = @players
        @players = Hash.new
        @waiting = false
        Thread.new{Game.new(otros)}
    end

    def telling_players(players, message)
      players.each {|nombre, conn| conn.send "#{message}\n", 0}
    end
 
    def establish_game()
      loop do
        while @players.count < 2
          if @waiting_players.size != 0
            @players = @waiting_players.pop.merge(@players)
          end
        end
        waiting_start unless @waiting
        while @players.count < 4 && @waiting
          if @waiting_players.size != 0
            @players = @waiting_players.pop.merge(@players)
          end
        end
      end
    end
 end
 
 
 Server.new( "localhost", 8080 )