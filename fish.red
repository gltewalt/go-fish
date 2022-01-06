Red ["Go Fish"]

do load %cards.red  ; From https://rosettacode.org/wiki/Playing_cards#Red

; c and p = computer and player
computer: []
player: []
cbooks: 0
pbooks: 0
cguesses: []

gf: {
    ***************
    *   GO FISH   *
    ***************
}

;---------------------
;  Helper functions  -                                           
;---------------------

but-last: func [str][
    unless none = length? str [
    copy/part str (length? str) - 1
    ]
]

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

; For initial cards and go-fish. Overwrites deal from cards.red
deal: func [num hand][ 
    loop num [
        append hand rejoin [trim/all form take deck]
    ] 
]

find-in: func [blk str][
    foreach i blk [if find but-last i str [return i]]
]

go-fish: func [num hand][
    either 0 <> length? deck [deal num hand][exit]
]
;------------- end of helper functions -----------------

get-cards: func [
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

ask-cards: func [
    fhand "from hand"
    thand "to hand"
    kind  "rank of cards"
    /local 
        a 
][
    case [
        fhand = player [   
            a: ask rejoin ["Do you have any " kind " s? "]
            if a = "x" [halt]
            either any [a = "y" a = "yes"][
                clear-show 0 ""
                get-cards fhand thand kind 
                show-cards
                ask-cards fhand thand but-last random/only fhand
                check-for-books thand kind 
            ][
                clear-show 0.4 gf 
                go-fish 1 thand   
            ]
        ]
        fhand = computer [  
            either find-in fhand kind [
                clear-show 0 ""
                get-cards fhand thand kind  
                show-cards
                if find-in thand kind [ ;-- player has to have rank asked for
                    ask-cards fhand thand ask "Your guess? "
                ]
                check-for-books thand kind
            ][
                clear-show 0.4 gf 
                go-fish 1 thand 
            ]
        ]
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
        either hand = player [pbooks: pbooks + 1][cbooks: cbooks + 1]
        remove-each i hand [if find/only c i [i]]   ;-- remove book from hand
    ]
]

show-cards: does [
    print [newline "Computer cards:" newline sort computer newline]
    print [newline "Player cards:" newline sort player newline]
    print ["Computer books:" cbooks]
    print ["Player books:" pbooks]
    print [newline "Cards left in deck:" length? deck]
    prin newline
]

game-round: does [
    print {
          -------------------
          -  COMPUTER TURN  -
          -------------------
          }

    ask-cards player computer but-last random/only computer
    show-cards

    print {
          -------------------
          -   PLAYER TURN   -
          -------------------
          }

    ask-cards computer player p: but-last find-in player ask "Your guess? "
    show-cards
]

demo: does [
    random/seed now 
    deal 9 computer
    deal 9 player
    show-cards
    while [0 <> length? deck][
        game-round  
    ]
    print "GAME OVER"
]

demo
