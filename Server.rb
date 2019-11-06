require_relative 'Game'
require 'socket'
class Server
    def initialize(socket_address, socket_port)
       @server_socket = TCPServer.open(socket_port, socket_address)
 
       @connections_details = Hash.new
       @connected_players = Hash.new
 
       @connections_details[:server] = @server_socket
       @connections_details[:clients] = @connected_players
       @players_cont = 0
       @players = Hash.new
 
       puts 'Started server.........'
       Thread.new { run }
       establish_game
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
         @players[conn_name] = conn
       end
       }.join
    end
 
    def establish_game()
       while @players_cont < 2
           puts "Esperando jugadores"
           sleep (1)
       end
       Game.new(@players)
    end
 end
 
 
 Server.new( 8080, "localhost" )