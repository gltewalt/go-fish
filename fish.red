Red ["Go Fish"]

; c and p = computer and player
chand: []
cguesses: []
phand: []
cbooks: 0
pbooks: 0
gf: {
    ***************
    *   GO FISH   *
    ***************
}
pip: ["a" "2" "3" "4" "5" "6" "7" "8" "9" "10" "j" "q" "k"]
pile: []

;---------------------
;  Helper functions  -                                           
;---------------------

clear-screen: does [
    "clears the console"
    call/console either system/platform = 'Linux ["clear"]["cls"]
]

clear-show: func [duration str][
    clear-screen
    print str 
    wait duration 
    clear-screen
]

deal-cards: func [num hand][ 
    loop num [
        append hand rejoin [trim/all form take deck]
    ] 
]

find-in: func [blk str][
    foreach i blk [if find i str [return i]]
]

go-fish: func [num hand][
    either not empty? deck [
        deal-cards num hand
    ][
        append hand rejoin [trim/all form take pile]
    ]
]

guess-from: func [hand guessed][
    {
        Randomly picks from hand minus guessed.
        
        Simulates a person asking for different cards on
        their next turn if their previous guess resulted
        in a Go Fish.
    }
    either empty? guessed [
        random/only hand 
    ][
        random/only difference hand guessed
    ]
]

make-deck: function [] [
    "adapted from https://rosettacode.org/wiki/Playing_cards#Red"
	new-deck: make block! 52
	foreach p pip [loop 4 [append/only new-deck p]] ;--
	return new-deck
]

shuffle: function [deck [block!]] [deck: random deck]

;------------- end of helper functions -----------------

transfer-cards: func [
    "Transfers cards from one hand to another"
    fhand "from hand"
    thand "to hand"
    kind "rank of cards"
    /local 
        c "collected"
][
    c: collect [forall fhand [keep find fhand/1 kind]]
    remove-each i c [none = i]  ;-- remove none values from collected
    forall c [append thand c/1] ;-- append remaining values to "to hand"
    remove-each i fhand [if find/only c i [i]] ;-- remove those values from "from hand"
]

computer-turn: func [
    fhand "from hand"
    thand "to hand"
    kind  "rank of cards"
    /local 
        a 
        g
][
    a: ask rejoin ["Do you have any " kind " s? "]
    if a = "x" [halt]
    either any [a = "y" a = "yes"][
        check-for-books thand kind
        transfer-cards fhand thand kind
        clear-show 0 ""
        show-cards
        computer-turn fhand thand g: guess-from thand cguesses
        append cguesses g  

    ][  
        clear-show 0.4 gf 
        go-fish 1 thand   
    ]
]

player-turn: func [
    fhand "from hand"
    thand "to hand"
    kind  "rank of cards"
    /local
        p 
][
    either find-in fhand kind [
        check-for-books thand kind
        transfer-cards fhand thand kind 
        clear-show 0 ""
        show-cards
        if find-in thand kind [ ;-- player has to have rank asked for
            player-turn fhand thand p: ask "Your guess: "
            check-for-books thand p 
        ]
    ][
        clear-show 0.4 gf 
        go-fish 1 thand 
    ]
]

check-for-books: func [
    hand "from or to hand"
    kind "rank of cards"
    /local 
        c "collected"
    ][
    c: collect [
        forall hand [keep find hand/1 kind]
    ]
    remove-each i c [none = i] 
    if 4 = length? c [
        either hand = phand [pbooks: pbooks + 1][cbooks: cbooks + 1]
        remove-each i hand [if find/only c i [i]]   ;-- remove book from hand
        forall c [append pile c/1]
    ]
]

show-cards: does [
    print [newline "Player cards:" newline sort phand newline]
    print ["Computer books:" cbooks]
    print ["Player books:" pbooks newline]
]

game-round: has [c p][
    print {
          -------------------
          -  COMPUTER TURN  -
          -------------------
          }

    computer-turn phand chand c: guess-from chand cguesses
    check-for-books chand c
    if empty? chand [go-fish 1 chand]
    show-cards

    print {
          -------------------
          -   PLAYER TURN   -
          -------------------
          }
    player-turn chand phand p: find-in phand ask "Your guess: "
    check-for-books phand p 
    if empty? phand [go-fish 1 phand]
    show-cards
]

demo: does [
    deck: shuffle make-deck
    deal-cards 9 chand
    deal-cards 9 phand
    show-cards
    while [cbooks + pbooks <> 13][
        game-round  
    ]
    clear-show 0 ""
    print "GAME OVER" 
    print [newline "Computer books:" cbooks newline "Player books:" cbooks]
]

demo
