class Card
	attr_accessor :face_value, :numeric_value, :alternate_value, :suit
	def initialize(face_value, numeric_value, alternate_value, suit)
		@face_value = face_value
		@numeric_value = numeric_value
		@alternate_value = alternate_value
		@suit = suit
	end
end

class Blackjack
	def initialize
		@deck = []
		@cards = [
			{'face_value' => '2', 'numeric_value' => 2, 'alternate_value' => 2},
			{'face_value' => '3', 'numeric_value' => 3, 'alternate_value' => 3},
			{'face_value' => '4', 'numeric_value' => 4, 'alternate_value' => 4},
			{'face_value' => '5', 'numeric_value' => 5, 'alternate_value' => 5},
			{'face_value' => '6', 'numeric_value' => 6, 'alternate_value' => 6},
			{'face_value' => '7', 'numeric_value' => 7, 'alternate_value' => 7},
			{'face_value' => '8', 'numeric_value' => 8, 'alternate_value' => 8},
			{'face_value' => '9', 'numeric_value' => 9, 'alternate_value' => 9},
			{'face_value' => '10', 'numeric_value' => 10, 'alternate_value' => 10},
			{'face_value' => 'Jack', 'numeric_value' => 10, 'alternate_value' => 10},
			{'face_value' => 'Queen', 'numeric_value' => 10, 'alternate_value' => 10},
			{'face_value' => 'King', 'numeric_value' => 10, 'alternate_value' => 10},
			{'face_value' => 'Ace', 'numeric_value' => 11, 'alternate_value' => 1}
		]
		@suits = ['Spades', 'Hearts', 'Diamonds', 'Clubs']
		@user_hand = []
		@dealer_hand = []	
	end

	def greeting
		puts "Welcome to Blackjack!"
		puts  "\nThe objective of this game is to beat the dealer in one of the following ways:"
		puts  "Get 21 points on the player's first two cards (called a 'blackjack' or 'natural'), without a dealer blackjack;"
        	puts  "Reach a final score higher than the dealer without exceeding 21; or"
        	puts  "Let the dealer draw additional cards until his or her hand exceeds 21."
        	puts "\nWould you like to play? y/n"
        	response = gets.strip
        	if response == "y"
        		puts "Great! Let's begin"
        	elsif response == "n"
        		puts "Okay, maybe another time."
        		exit
        	else
        		greeting
       	 	end
	end

	def build_deck
		@cards.each do |c|
			@suits.each do |s|
				card = Card.new(c['face_value'], c['numeric_value'], c['alternate_value'], s)
				@deck.push(card)
			end
		end
	end

	def shuffle_deck 
		puts "Shuffling Deck..."
		@deck = @deck.shuffle
	end

	def buy_in
		puts "Please enter the number of chips you want to start the game with.\nThe minimum buy-in is 500 chips, the max is 1000 chips."
		@chips = gets.to_i
		if @chips < 500 || @chips > 1000
			buy_in
		else
			puts "Your buy-in for this game of Blackjack is #{@chips} chips."
		end
	end

	def bet
		puts "How much would you like to bet this round? You have #{@chips} remaining."
		@bet = gets.to_i
		if @bet > @chips
			puts "You don't have that many chips remaining, please bet a lower amount."
			bet?
		elsif @bet == 0 || @bet.to_f.nan?
			bet
		else
			puts "You've bet #{@bet} chips for this round"
			@chips = @chips - @bet
			@pot = @bet
			puts "You have #{@chips} chips left. The pot is #{@pot}."
		end
	end

	def deal
		@user_hand = []
		@dealer_hand = []
		puts "Dealing cards..."
		@user_hand.push(@deck.shift)
		@user_hand.push(@deck.shift)
		@dealer_hand.push(@deck.shift)
		@dealer_hand.push(@deck.shift)
		natural_twenty_one?
		puts "The dealer is showing #{@dealer_hand[0].face_value} of #{@dealer_hand[0].suit}"
		puts "You are holding #{@user_hand[0].face_value} of #{@user_hand[0].suit} and #{@user_hand[1].face_value} of #{@user_hand[1].suit}."
	end

	def natural_twenty_one?
		if @dealer_hand[0].numeric_value + @dealer_hand[1].numeric_value == 21 && @user_hand[0].numeric_value + @user_hand[1].numeric_value == 21
			puts "You and the dealer both have a natural 21\nPushing #{@pot} chips back to you..."
			@chips += @pot
			round
		elsif @dealer_hand[0].numeric_value + @dealer_hand[1].numeric_value == 21 && @user_hand[0].numeric_value + @user_hand[1].numeric_value != 21
			puts "The dealer has a natural 21."
			puts "You have #{@user_hand[0].numeric_value + @user_hand[1].numeric_value}.\nYou lose this round. Pushing #{@pot} chips to the dealer..."
			out_of_chips?
			round
		elsif @user_hand[0].numeric_value + @user_hand[1].numeric_value == 21 && @dealer_hand[0].numeric_value + @dealer_hand[1].numeric_value != 21
			puts "You have a natural 21.\nThe dealer has #{@dealer_hand[0].numeric_value + @dealer_hand[1].numeric_value}."
			puts "You win this round. Pushing #{@pot * 2} chips to you..."
			@chips += @pot * 2
			round
		end
	end

	def surrender?
		puts "Would you like to surrender this round (give up half your bet and retire)? y/n"
		response = gets.strip
		if response == "y"
			puts "You surrender this round. Pushing half your bet to the dealer..."
			@chips += @pot / 2.round
			puts "Pushing half the bet to you...\nYou have #{@chips} chips remaining."
			round
		elsif response != "n"
			surrender?
		else
			return
		end
	end

	def double?
		if @chips < @pot
			return
		else
			puts "Would you like to double (double your wager, take one more card and finish)? y/n"
			response = gets.strip
			if response == "y"
				@user_hand.push(@deck.shift)
				puts "OK, doubling your wager and giving you one more card...\nYou've drawn #{@user_hand[2].face_value} of #{@user_hand[2].suit}."
				best_hand
				@chips -= @pot
				@pot = @pot * 2
				puts "The pot is now #{@pot}. You have #{@chips} chips remaining."
				bust?
				dealer_play
			elsif response == "n"
				return
			else
			double?
			end
		end
	end

	def hit_or_stand?
		puts "Do you want to hit (take one card) or stand (end turn)? h/s"
		response = gets.strip
		if response == 'h'
			@user_hand.push(@deck.shift)
			bust?
			best_hand
			hit_or_stand?
		elsif response == 's'
			dealer_play
		else
			hit_or_stand?
		end
	end

	def bust?
	 	if @user_hand.inject(0){|sum,e| sum + e.numeric_value} > 21 && @user_hand.inject(0){|sum,e| sum + e.alternate_value} > 21
	 		puts "You've busted with #{@user_hand.inject(0){|sum,e| sum + e.numeric_value}}.\nPushing #{@pot} chips to the dealer..."
	 		out_of_chips?
			round
		end
	end

	def dealer_bust?
		if @dealer_hand.inject(0){|sum,e| sum + e.numeric_value} > 21 && @dealer_hand.inject(0){|sum,e| sum + e.alternate_value} > 21
			puts "The dealer has busted with #{@dealer_hand.inject(0){|sum,e| sum + e.numeric_value}}.\nPushing #{@pot * 2} chips to you..."
			@chips += @pot * 2
			round
		end
	end

	def dealer_play
		if @dealer_hand.inject(0){|sum,e| sum + e.numeric_value} >= 17
			compare_hands
		else
			until @dealer_hand.inject(0){|sum,e| sum + e.numeric_value} >= 17 || @dealer_hand.inject(0){|sum,e| sum + e.alternate_value} >=  17
				@dealer_hand.push(@deck.shift)
				puts "The dealer draws #{@dealer_hand.last.face_value} of #{@dealer_hand.last.suit}..."
				dealer_bust?
			end
		end
		compare_hands
	end

	def best_hand
		if @user_hand.inject(0){|sum,e| sum + e.numeric_value} > 21
			@best_hand = @user_hand.inject(0){|sum,e| sum + e.alternate_value}
			puts "You have #{@best_hand}"
		elsif @user_hand.inject(0){|sum,e| sum + e.numeric_value} >= @user_hand.inject(0){|sum,e| sum + e.alternate_value}
			@best_hand = @user_hand.inject(0){|sum,e| sum + e.numeric_value}
			puts "You have #{@best_hand}"
		end
	end

	def dealer_best_hand
		if @dealer_hand.inject(0){|sum,e| sum + e.numeric_value} > 21
			@dealer_best_hand = @dealer_hand.inject(0){|sum,e| sum + e.alternate_value}
			puts "The dealer has #{@dealer_best_hand}."
		elsif @dealer_hand.inject(0){|sum,e| sum + e.numeric_value} >= @dealer_hand.inject(0){|sum,e| sum + e.alternate_value}
			@dealer_best_hand = @dealer_hand.inject(0){|sum,e| sum + e.numeric_value}
			puts "The dealer has #{@dealer_best_hand}."
		end
	end

	def compare_hands
		best_hand
		dealer_best_hand
		if @dealer_best_hand > @best_hand
			puts "The dealer's #{@dealer_best_hand} beats your #{@best_hand}\nPushing #{@pot} chips to the dealer..."
	 		out_of_chips?
			round
		elsif @best_hand > @dealer_best_hand
			puts "Your #{@best_hand} beats the dealer's #{@dealer_best_hand}.\nPushing #{@pot * 2} chips to you..."
			@chips += @pot * 2
			round
		elsif @dealer_best_hand == @best_hand
			puts "You and the dealer have tied.\nPushing #{@pot} chips back to you..."
			@chips += @pot
			round
		end
	end

	def out_of_chips?
		if @chips.zero?
			puts "You're out of chips. Thanks for playing!"
			exit
		end
	end

	def round
		until out_of_chips?
			build_deck
			shuffle_deck
			bet
			deal
			surrender?
			double?
			hit_or_stand?
			dealer_play
			compare_hands
			out_of_chips?
		end
	end
end








