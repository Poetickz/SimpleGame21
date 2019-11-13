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
        when @value_card == "A"
            return 1
        when @value_card == "K" || @value_card == "Q" || @value_card == "J"
            return 10
        else
            return @value_card.to_i
        end
    end
end
