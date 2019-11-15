class Card
    attr_accessor :symbol, :value_card

    def initialize(symbol, value_card)
        @symbol = symbol
        @value_card = value_card
    end

    def print_card
        "#{@value_card}#{@symbol}"
    end

    def value_number
        case @value_card
        when "A"
            return 1
        when "K"
            return 10
        when "Q"
            return 10
        when "J"
            return 10
        else
            return @value_card.to_i
        end
    end
end
