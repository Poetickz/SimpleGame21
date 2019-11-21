require_relative 'Card'

class Deck

    attr_accessor :deck_cards


    def initialize
        @deck_cards = []
        setting_up_deck
    end

    def setting_up_deck
        @deck_cards.concat(build_set("♦"))
        @deck_cards.concat(build_set("♠"))
        @deck_cards.concat(build_set("♥"))
        @deck_cards.concat(build_set("♣"))
        @deck_cards.shuffle!
    end

    def build_set(symbol)
        cards = []
        value_cards = ["A","2","3","4","5","6","7","8","9","10","J","Q","K"]
        value_cards.each { |value| cards.push(Card.new(symbol,value)) }
        return cards
    end

end