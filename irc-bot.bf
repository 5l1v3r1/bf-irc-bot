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
    b  > +++++++++ .
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

+[,]
