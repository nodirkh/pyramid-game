;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; PyramidWorld - the solitaire game playing domain
;;;
;;; See http://en.wikipedia.org/wiki/Pyramid_solitaire for more detail about the game
;;; This version of Pyramid is based on the rules in Microsoft Solitaire Collection:
;;; - You can match any uncovered card including the top cards on the deck and
;;;   waste pile. You can even match the deck and waste pile cards together.
;;; - A player can remove the King card directly without matching any other card.
;;; - A player can cycle through the deck 3 times only. If a player cannot finish
;;;   the game before the end of the third cycle through the deck, the player loses the game.
;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



(define (domain pyramid)

  (:requirements :strips :adl :derived-predicates :typing)
  (:types
    rank
    card
    location - object,
    deck
    waste
    pyramid - location
  )
  (:predicates
    (sum-equal-13 ?top - rank ?bottom - rank)
    (at ?c - card ?loc - location)
    (mapping ?c - card ?number - rank)
    (closed-by ?top - card ?bottom - card)
    (open ?c - card)
    (king ?c - card)
    (sum-mapping ?top - card ?bottom - card)
    ; (empty_deck)
    (first_recycle)
    ; (second_recycle)
    (last_recycle)
    (done)
    ; (solution)
  )

  ;; check if the card is uncovered
  (:derived (open ?c - card)
    (not (exists (?top - card) (closed-by ?top ?c)))
  )

  ;; card rank sum immitation
  ;; maps ranks of two cards to the sum of the ranks
  (:derived (sum-mapping ?top - card ?bottom - card)
    (exists (?top_card_value - rank) 
      (exists (?bottom_card_value - rank)
        (and (mapping ?top ?top_card_value) (mapping ?bottom ?bottom_card_value) 
        (sum-equal-13 ?top_card_value ?bottom_card_value))
      )
    )
  )

  ;; remove king operation
  ;; gets a king at arbitrary location and removes it
  (:action remove-king
      :parameters (?c - card ?loc - location)
      :precondition (and 
        (king ?c) ;; must be a king
        (open ?c) ;; must be uncovered
        (at ?c ?loc) ;; any location works
      )
      :effect (and
        (when (exists (?bottom_card - card) (closed-by ?c ?bottom_card)) (not (closed-by ?c ?bottom_card))) ;; uncover a card
        (when (exists (?bottom_card - card) (closed-by ?c ?bottom_card)) (not (closed-by ?c ?bottom_card))) ;; uncover a card
        (not (at ?c ?loc)) ;; remove from location
      )
  )
  

  (:action match
    :parameters (?top - card ?bottom - card)
    :precondition (and
      (not (king ?top)) ;; don't match kings
      (not (king ?bottom))
      (sum-mapping ?top ?bottom) ;; must have a sum of 13
      (open ?top) ;; both cards must be uncovered
      (open ?bottom)
      (or (and (at ?top pyramid) (at ?bottom pyramid)) ;; location permutations
          (and (at ?top pyramid) (at ?bottom waste))
          (and (at ?top pyramid) (at ?bottom deck))
          (and (at ?top deck) (at ?bottom pyramid))
          (and (at ?top waste) (at ?bottom pyramid))
          (and (at ?top deck) (at ?bottom waste))
          (and (at ?top waste) (at ?bottom deck))
      )
    )
      :effect (and
        ; (when (exists (?bottom_card - card) (closed-by ?top ?bottom_card)) (not (closed-by ?top ?bottom_card)))
        ; (when (exists (?bottom_card - card) (closed-by ?bottom ?bottom_card)) (not (closed-by ?bottom ?bottom_card)))
        
        ;; since a single card can block 2 cards simultaneously, use forall

        (forall (?blocked_card_underneath - card) (when (closed-by ?top ?blocked_card_underneath) ;; uncover cards
                                                  (and (not (closed-by ?top ?blocked_card_underneath)))))
        (forall (?blocked_card_underneath - card) (when (closed-by ?bottom ?blocked_card_underneath) ;; uncover cards
                                                  (and (not (closed-by ?bottom ?blocked_card_underneath)))))
        
        ; (when (and (at ?top pyramid) (at ?bottom waste)) (not (and (at ?top pyramid) (at ?bottom waste))))
        ; (when (and (at ?top pyramid) (at ?bottom deck)) (not (and (at ?top pyramid) (at ?bottom deck))))
        ; (when (and (at ?top deck) (at ?bottom pyramid)) (not (and (at ?top pyramid) (at ?bottom deck))))
        ; (when (and (at ?top waste) (at ?bottom pyramid)) (not (and (at ?top pyramid) (at ?bottom deck))))
        ; (when (and (at ?top deck) (at ?bottom waste)) (not (and (at ?top pyramid) (at ?bottom deck))))
        ; (when (and (at ?top waste) (at ?bottom deck)) (not (and (at ?top pyramid) (at ?bottom deck))))
        
        (when (at ?top pyramid) (not (at ?top pyramid))) ;; location permutation negation
        (when (at ?top deck) (not (at ?top deck)))
        (when (at ?top waste) (not (at ?top waste)))
        (when (at ?bottom pyramid) (not (at ?bottom pyramid)))
        (when (at ?bottom deck) (not (at ?bottom deck)))
        (when (at ?bottom waste) (not (at ?bottom waste)))
        
        ; (when (not (exists (?c - card) (at ?c pyramid))) (solution))
      )
    )

  (:action draw
    :parameters (?c - card)
    :precondition (and 
      ; (not (empty_deck))
      (at ?c deck) ;; card must be drawn from the deck
      (open ?c) ;; card must be uncovered
    )
    :effect (and 
    (when (exists (?bottom_card - card) (closed-by ?c ?bottom_card)) (not (closed-by ?c ?bottom_card)))
    (not (at ?c deck)) ;; remove from deck
    ; (when (and (exists (?bottom_card - card) (at ?bottom_card waste)) (not (closed-by ?c ?bottom_card))) (closed-by ?c ?bottom_card))
    (forall (?card_under - card) (when (and (at ?card_under waste) (not (closed-by ?c ?card_under))) (closed-by ?c ?card_under)))
    (at ?c waste) ;; put from deck to waste
    ; (when (not (exists (?next - card) (at ?next deck))) (empty_deck)))
    )
  )
  
  (:action shuffle
      :parameters ()
      :precondition (and 
        (not (done)) ;; cycling must not be done
        ; (empty_deck)
        (not (exists (?c - card) (at ?c deck))) ;; no cards should be in the deck
        (exists (?c - card) (at ?c waste)) ;; cards must be in the waste
      )
      :effect (and 
      (forall (?top - card ?bottom - card) 
              (when (and (at ?top waste) (closed-by ?top ?bottom)) ;; switch top->bottom to bottom->top
              (and 
              (not (closed-by ?top ?bottom))
              (closed-by ?bottom ?top)
              (not (at ?top waste)) ;; remove from waste
              (not (at ?bottom waste))
              (and (at ?top deck) (at ?bottom deck)))) ;; put in deck
      )
      ; (when (and (last_recycle) (not (done)) (done)))
      (when (not (first_recycle)) (and (first_recycle))) ;; first iteration
      (when (and (first_recycle) (not (last_recycle))) (and (last_recycle))) ;; second iteration
      (when (and (first_recycle) (last_recycle) (not (done))) (and (done))) ;; done
    )
  )
)