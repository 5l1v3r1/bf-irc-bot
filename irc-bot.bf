Brainfuck IRC bot
* Comments use ; in place of periods or commas as punctuation
* Meant to operate on 8 bit unsigned memory
* Expects a good amount of memory; I use 0x10000 bytes; smaller is probably fine
* Expects stdin to block until data is available
* If you use netfuck; it'd be useful to know that debug mode outputs every character read from the remote to the console

Send NICK and USER

"NICK bfbot\r\nUSER bfbot a a :bfbot\r\n" (78 73 67 75 32 98 102 98 111 116 13 10 85 83 69 82 32 98 102 98 111 116 32 97 32 58 98 102 98 111 116)
    ++++++++++
    [
        N  > +++++++
        I  > +++++++
        C  > ++++++
        K  > +++++++
           > +++
        b  > +++++++++
        f  > ++++++++++
        b  > +++++++++
        o  > +++++++++++
        t  > +++++++++++
        \r > +
        \n > +
        U  > ++++++++
        S  > ++++++++
        E  > ++++++
        R  > ++++++++
           > +++
        b  > +++++++++
        f  > ++++++++++
        b  > +++++++++
        o  > +++++++++++
        t  > +++++++++++
           > +++
        a  > +++++++++
           > +++
        a  > +++++++++
           > +++
        :  > +++++
        b  > +++++++++
        f  > ++++++++++
        b  > +++++++++
        o  > +++++++++++
        t  > +++++++++++
        \r > +
        \n > +
        <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<-
    ]
    "NICK bfbot\r\nUSER bfbot a a :bfbot\r\n" (78 73 67 75 32 98 102 98 111 116 13 10 85 83 69 82 32 98 102 98 111 116 32 97 32 58 98 102 98 111 116)
    N  > ++++++++ .
    I  > +++ .
    C  > +++++++ .
    K  > +++++ .
       > ++ .
    b  > ++++++++ .
    f  > ++ .
    b  > ++++++++ .
    o  > + .
    t  > ++++++ .
    \r > +++ .
    \n > .
    U  > +++++ .
    S  > +++ .
    E  > +++++++++ .
    R  > ++ .
       > ++ .
    b  > ++++++++ .
    f  > ++ .
    b  > ++++++++ .
    o  > + .
    t  > ++++++ .
       > ++ .
    a  > +++++++ .
       > ++ .
    a  > +++++++ .
       > ++ .
    :  > ++++++++ .
    b  > ++++++++ .
    f  > ++ .
    b  > ++++++++ .
    o  > + .
    t  > ++++++ .
    \r > +++ .
    \n > .
    <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< end of "NICK bfbot\r\nUSER bfbot a :bfbot\r\n"

>
cell #0: working cell for iteration and such
cell #1 stdin (pointer currently points here)
[
    Messages come in like this: ":user PRIVMSG bfbot :message"
    [-]+[,<[-]++++++++++[>---<-]>--] Loop until a space (32) is read
    
    Check for P (80)
    , < ++++++++++ [ > -------- <- ] [- set working cell to 1]+ >
    [ if (input != 'P')
        [ , ---------- ] Read to \n (10); also zeroes cell
        <->
    ]<[> if (input == 'P')
        , Check for 'I' (73) PING
        < [-]++++++++++ [>-------<-]>--- <working=1+> Cell is zero if 'I'
        [
            Check for 'R' (82) PRIVMSG
            --------- Subtract 9 more; cell is zero if 'R' <[-]+>
            [
                Not 'R'
                [ , ---------- ] Read to \n (10); also zeroes cell
            <->]<[>
                Handle PRIVMSG
                Read remaining characters: I,V,M,S,G, ,
                
                Check for channel/user message ('#' = 35)
                , <[-]++++++++++ [>---<-]>----- <[-]+>
                [
                    Handle user message
                    Read to space: <[-]> [,<++++++++++[>---<-]>--],
                    
                    Check for 'J' 74
                    ,<++++++++++[>-------<-]>---- <[-]+>
                    [
                        [-] (not J; ignore)
                    <->]<[>,
                        Write JOIN command 74 79 73 78 32 (user text) 13 10
                        <[-]++++++++++
                        >[-]>[-]>[-]>[-]>[-]<<<<<
                        [>+++++++ >+++++++ >+++++++ >+++++++ >+++ <<<<<-]
                        >++++.
                        >+++++++++.
                        >+++.
                        >++++++++.
                        >++.
                        <<<<<[-]>
                        
                        Write user text:
                        <[-]+[>
                            ,------------- Subtract \r<[-]>
                            [<+>+++++++++++++.[-]] Output if not \r
                            <
                        ]>
                        Write \r\n
                        [-]++++++++++.+++.
                    <[-]]>
                                        
                    +[ , ---------- ] TODO
                <[-]>]<[>
                    Channel message
                    %channel%
                    [ , ---------- ] TODO
                <[-]]>
            <[-]]>
        <[-]>]<[>
            Handle 'I' (PING)
            [ , ---------- ] TODO
        ]
    ]>[-]+
    %***%
]
