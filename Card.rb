class Card
    attr_accessor :symbol, :value_card

    def initialize(symbol, value_card)
        @symbol = symbol
        @value_card = value_card
    end

    def print_card
        "#{@value_card}#{@symbol}"
    end
end