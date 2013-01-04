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

>
cell #0: working cell for iteration and such
cell #1 stdin (pointer currently points here)
[
    Messages come in like this: ":user PRIVMSG bfbot :message"
    >+[,<[-]++++++++++[>---<-]>--] Loop until a space (32) is read
    Check for P (80)
    , < ++++++++++ [ > -------- <- ] [- set working cell to 1]+ >
    [ if (input != 'P')
        [ , ---------- ] Read to \n (10); also zeroes cell
        <->
    ]<[> if (input == 'P')
        ,
        Check for 'O' (73) PING
        < ++++++++++ [>-------<-]>--- <working=1[-]+> Cell is zero if 'I'
        [
            Check for 'R' (82) PRIVMSG
            NOT WORKING; WHY
            --------- Subtract 9 more; cell is zero if 'R'
            Use a second working cell at address 3: >[-]+<
            [
                Not 'R'
                [ , ---------- ] Read to \n (10); also zeroes cell
            >-<]>[ (move back to input address: <)
                Handle 'R' (PRIVMSG)
                Example PRIVMSG: :user PRIVMSG #channel :message
                Example PRIVMSG: :user PRIVMSG destination :message
                
                Read remaining characters: I,V,M,S,G, ,
                
                Check for channel message (next character == '#' 35)
                , >[-]++++++++++ [<--->-]<----- >[-]+<
                [
                    >> Move to new working memory
                        Handle user private message
                        Read until space (32): <[-]>[-]+[, <++++++++++ [>---<-]>-- ]
                        , Read colon
                        Command to join a channel is "J #channelname"; so check for a J (74)
                        , <[-]++++++++++>[>-------<-]>---- <[-]+>
                        [
                            Not join; read to \n [ , ---------- ]
                        >-<]>[
                            Handle join command
                            ,@
                        ]<
                    <<
                >-<]>[<
                    Handle channel message
                    TEMPORARY: [ , ---------- ]
                ]<
            ]<
        <->]<[>
            Handle 'I' (PING)
            
        ]
    ]
    <[-]+ reset working cell to 1; loop
]
