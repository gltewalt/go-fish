Red ["Go Fish"]

do load %cards.red  ; From https://rosettacode.org/wiki/Playing_cards#Red

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

;---------------------
;  Helper functions  -                                           
;---------------------

but-last: func [str][   ;-- not guarded yet
    copy/part str (length? str) - 1
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

deal-cards: func [num hand][ 
    loop num [
        append hand rejoin [trim/all form take deck]
    ] 
]

find-in: func [blk str][
    foreach i blk [if find but-last i str [return i]]
]

go-fish: func [num hand][
    either 0 <> length? deck [deal-cards num hand][exit]
]

guess-from: func [hand guessed][  ;-- for simple A.I. 
    "randomly picks from hand minus guessed"
    either empty? guessed [
        random/only hand 
    ][
        random/only difference hand guessed 
    ]
]
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
        clear-show 0 ""
        transfer-cards fhand thand kind 
        show-cards
        check-for-books thand kind 
        computer-turn fhand thand g: but-last guess-from thand cguesses

    ][  
        ; append cguesses g   ;-- not working yet
        ; print ["CGUESSES is " cguesses]
        clear-show 0.4 gf 
        go-fish 1 thand   
    ]
]

player-turn: func [
    fhand "from hand"
    thand "to hand"
    kind  "rank of cards"
][
    clear-show 0 ""
    either find-in fhand kind [
        clear-show 0 ""
        transfer-cards fhand thand kind  
        show-cards
        check-for-books thand kind 
        if find-in thand kind [ ;-- player has to have rank asked for
            player-turn fhand thand ask "Your guess: "
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
    ]
]

show-cards: does [
    ;print [newline "Computer cards:" newline sort chand newline]
    print [newline "Player cards:" newline sort phand newline]
    print ["Computer books:" cbooks]
    print ["Player books:" pbooks]
    print [newline "Cards left in deck:" length? deck]
    prin newline
]

game-round: has [c p][
    print {
          -------------------
          -  COMPUTER TURN  -
          -------------------
          }

    computer-turn phand chand c: but-last guess-from chand cguesses
    check-for-books chand c
    show-cards

    print {
          -------------------
          -   PLAYER TURN   -
          -------------------
          }

    player-turn chand phand p: but-last find-in phand ask "Your guess: "
    check-for-books phand p 
    show-cards
]

demo: does [
    deal-cards 9 chand
    deal-cards 9 phand
    show-cards
    while [0 <> length? deck][
        game-round  
    ]
    print ["GAME OVER" newline "No more cards"]
]

demo
