# pyramid-game

The program uses first-order (predicate) logic to solve the famous Pyramid Solitaire card game. Predicates are given as follows:

### Predicates:
(:predicates
    (sum-equal-13 ?top - rank ?bottom - rank) - used to immitate the sum of two ranks
    (at ?c - card ?loc - location) - used to locate the object. Available locations: pyramid, deck, waste
    (mapping ?c - card ?number - rank) - a mapping of a card to its rank. Works as simple as map<string, int>
    (closed-by ?top - card ?bottom - card) - used to indicate which card is closed by the card on top of it
    (open ?c - card) - used to indicate uncovered cards. Derived (if not closed, then open).
    (king ?c - card) - used to indicate king cards. For simplicity, kings are marked directly in the problem file
    (sum-mapping ?top - card ?bottom - card) - used for sum immitation mapping. Derived (if sum-equals-13, then sum mapped correctly).
    (closed ?c - card) - used to check all the matched cards
    (first_recycle) - used to indicate the first cycle click
    (last_recycle) - used to indicate the second (last) cycle click
    (done) - used to indicate that no cycles are available
)

### Actions:

remove-king:
    removes a king at location loc
    king must be open
    king must be at arbitrary location

match:
    matches cards top and bottom
    cards must be open
    cards must not be kings
    cards can be at two different as well as two similar locations

draw:
    draws a card from deck
    card must be in deck
    card must be open

shuffle:
    cycles waste back to deck
    no cards must be left in the deck
    some cards must be present in the waste

### Initial state:

cards from deck are marked (at deck);
each card is marked as closed by the predecessor (closed-by);

(sum-equals-13) is set for each pair of number imitators;

cards from the pyramid are marked (at pyramid);
each card is marked under the two cards in front of it (closed-by);

ranks are mapped to cards available in the current problem (mapping);

king cards are marked (king);

### Goal state:

card at the top of the pyramid is (closed);

## To run:
Use fast-downward package. Download [here](https://www.fast-downward.org/QuickStart).
