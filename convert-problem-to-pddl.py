#!/usr/bin/env python3

import re
import sys

# Output the PDDL problem file from the problem specification file
# Input:
#   problem_name - the name of the problem
#   pyramid - the cards in the pyramid. It is a double list with a structure:
#             [ [card00], [card10, card11], [card20, card21, card22], ...  ]
#             where card00 is the card the top of the pyramid; card10 and card11 are the cards
#             on the second rows of the pyramid; etc.  A card is a string with two characters.
#             A card "__" means that the position is empty.
#   deck - the list of cards on the deck (deck[0] is the top card, deck[-1] is the bottom card)


cards = [] # global variable to save the cards in the pyramid
last_card = "" # global variable to save the top of the pyramid

all_ranks = ['n0', 'n1', 'n2', 'n3', 'n4', 'n5', 'n6', 'n7', 'n8', 'n9', 'n10', 'n11', 'n12', 'n13'] # number imitator
all_kings = ["SK", "HK", "CK", "DK"] # king checked
all_locations = ["pyramid", "deck"] # starting locations, can't start at pile

### mapping of elements
card_num = {
  'A' : "n1",
  '2' : "n2",
  '3' : "n3",
  '4' : "n4",
  '5' : "n5",
  '6' : "n6",
  '7' : "n7",
  '8' : "n8",
  '9' : "n9",
  'X' : "n10",
  'J' : "n11",
  'Q' : "n12",
  'K' : "n13"
}

def print_pddl(problem_name, pyramid, deck):
    print("(define (problem " + problem_name + ")")
    
    print(' (:domain pyramid)') # put domain first
    
    ### use mappings to instantiate object
    print(f" (:objects {' '.join(cards)} - card\n {' '.join(all_ranks)} - rank\n {' '.join(all_locations)} - location)") 
    
    ## START INIT
    print(' (:init \n', end="")
    ### mark all cards in the deck (at CARD deck)

    for i in range(len(deck)): # iterate over the deck
        if i == len(deck) - 1: # last card
            if deck[i] in all_kings:
                print(f'  (king {deck[i+1]})') # mark king card
            print(f'  (at {deck[i]} deck)') # mark card at deck
            print(f'  (mapping {deck[i]} {card_num[deck[i][1]]})') # map card's value
        else:
            if deck[i] in all_kings:
                print(f'  (king {deck[i+1]})') # mark king card
            print(f'  (at {deck[i]} deck)') # mark card at deck
            print(f'  (mapping {deck[i]} {card_num[deck[i][1]]})') # map card's value
            print(f'  (closed-by {deck[i]} {deck[i+1]})') # card is topped by another card
    
    ### mark all cards in the pyramid (at CARD pyramid)
    for i in range(len(pyramid) - 1):
        for j in range(len(pyramid[i])):
            if pyramid[i][j] != '__':
                print(f'  (at {pyramid[i][j]} pyramid)') # mark a CARD at pyramid
                print(f'  (mapping {pyramid[i][j]} {card_num[pyramid[i][j][1]]})') # get card's value
            if pyramid[i+1][j] != '__':
                print(f'  (closed-by {pyramid[i+1][j]} {pyramid[i][j]})') # card is blocked on the left
            if pyramid[i+1][j+1] != '__':
                print(f'  (closed-by {pyramid[i+1][j+1]} {pyramid[i][j]})') # card is blocked on the right
            if pyramid[i][j] in all_kings:
                print(f'  (king {pyramid[i][j]})') # mark king card
    
    for i in range(len(pyramid) - 1, len(pyramid)): # pyramid's last element
        for j in range(len(pyramid[i])):
            if pyramid[i][j] != '__':
                print(f'  (at {pyramid[i][j]} pyramid)') # mark a CARD at pyramid
                print(f'  (mapping {pyramid[i][j]} {card_num[pyramid[i][j][1]]})') # get card's value
                if pyramid[i][j] in all_kings:
                    print(f'  (king {pyramid[i][j]})') # mark the king card

    for i in range(len(all_ranks) // 2):
        print(f'  (sum-equal-13 {all_ranks[i]} {all_ranks[len(all_ranks)-i-1]})') # print number immitations
        print(f'  (sum-equal-13 {all_ranks[len(all_ranks)-i-1]} {all_ranks[i]})')

    print(')')
    ## END INIT

    ## START GOAL

    print(' (:goal (not (exists (?c - card) (at ?c pyramid))))')

    ## END GOAL

    print(")")

def is_any_duplicate_cards(all_cards):
    for i, card1 in enumerate(all_cards):
        if card1 != "__":
            for card2 in all_cards[i+1:]:
                if card2 != "__":
                    if card1 == card2:
                        return card1
    return ""

def print_usage():
    print("Usage:")
    print()
    print("      ", sys.argv[0], "problem_spec.txt")
    print()

def main():
    if len(sys.argv) != 2:
        print_usage()
        exit(1)

    infile_name = sys.argv[1]
    problem_name = re.sub(r"\.[^\.]+", "", re.sub(r".*\/", "", infile_name))

    pyramid = []
    deck = []
   
    with open(infile_name) as infile:
        for line in infile:
            s = line.strip().upper()
            if s == '': break
            pyramid.append(re.split(" +", s))
        for line in infile:
            s = line.strip().upper()
            if s == '': continue
            deck.extend(re.split(" +", s))

    all_cards = [ x for ls in pyramid for x in ls ] + deck
    global cards
    cards = [x for x in all_cards if x != "__"] # save the in-game cards
    global last_card
    last_card = [x for x in all_cards if x != "__"][0] # save the top card
    r = is_any_duplicate_cards(all_cards)
    if r:
        print("Error: " + r + " is duplicated.")
        return
    print_pddl(problem_name, pyramid, deck)

if __name__ == "__main__":
    main()

