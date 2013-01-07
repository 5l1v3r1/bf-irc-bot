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
        "NICK "  >++++++++>+++++++>+++++++>+++++++>+++
        "bfbot"  >++++++++++>++++++++++>++++++++++>+++++++++++>+++++++++++
        "\r\n"   >+>+
        "USER "  >++++++++>++++++++>+++++++>++++++++>+++
        "bfbot " >++++++++++>++++++++++>++++++++++>+++++++++++>+++++++++++>+++
        "a a :"  >+++++++++>+++>+++++++++>+++>+++++
        "bfbot"  >++++++++++>++++++++++>++++++++++>+++++++++++>+++++++++++
        "\r\n"   >+>+
        <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<-
    ]
    "NICK "  >--.>+++.>---.>+++++.>++.
    "bfbot"  >--.>++.>--.>+.>++++++.
    "\r\n"   >+++.>.
    "USER "  >+++++.>+++.>-.>++.>++.
    "bfbot " >--.>++.>--.>+.>++++++.>++.
    "a a :"  >+++++++.>++.> +++++++.>++.>++++++++.
    "bfbot " >--.>++.>--.>+.>++++++.
    "\r\n"   >+++.>.
    <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

>
cell #0: working cell for iteration and such
cell #1 stdin (pointer currently points here)
[
    Messages come in like this: ":user PRIVMSG bfbot :message"
    , Read out one character; see if it's a 'P' (80)
    <[-] ++++++++++ [>--------<-] [-]+>
    [ Handle NOT a ping
        [-]+[,<[-]++++++++++[>---<-]>--] Loop until a space (32) is read
        
        Check for P (80)
        , <[-] ++++++++++ [ > -------- <- ] [- set working cell to 1]+ >
        [ if (input != 'P')
            [ , ---------- ] Read to \n (10); also zeroes cell
            <->
        ]<[> if (input == 'P')
            Check for 'R' (82) PRIVMSG
            , <[-]++++++++++[>--------<-]>-- cell is zero if 'R' <[-]+>
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
                        [>+++++++ >++++++++ >+++++++ >++++++++ >+++ <<<<<-]
                        >++++.>-.>+++.>--.>++.
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
                    +[ , ---------- ]
                <[-]>]<[>
                    Channel message
                    Read channel name into buffer (a zero on each side)
                    [-]>[-]+<
                    +[>,+
                        Copy value into next two cells for comparison
                        >[-]>[-]<<
                        [>+>+<<-]>[<+>-]>
                        Pointer is at third cell; middle cell is zero; first cell and third cell are read value
                        Subtract space (32) using middle cell as working cell <++++++++++[>---<-]>---<+> (note: we subtract 33 because the whole buffer is incremented)
                        [<->[-]]
                        <[
                            Handle space
                            <[-]>
                        [-]]<
                    ]
                    <-[<-]
                    , Read and discard
                    
                    , Check for control character '$' 36
                    <[-]++++++++++[>---<-]>------<+>
                    [ [-]+[ , ---------- ] <->]
                    <[>
                        Send 'PRIVMSG #' 80 82 73 86 77 83 71 32 35 without screwing up the channel name buffer
                        [-]<[-]++++++++++[>++++++++<-]>.
                        [-]<[-]++++++++++[>++++++++<-]>++.
                        [-]<[-]++++++++++[>+++++++<-]>+++.
                        [-]<[-]++++++++++[>+++++++++<-]>----.
                        [-]<[-]++++++++++[>++++++++<-]>---.
                        [-]<[-]++++++++++[>++++++++<-]>+++.
                        [-]<[-]++++++++++[>+++++++<-]>+.
                        [-]<[-]++++++++++[>+++<-]>++.
                        [-]<[-]++++++++++[>+++<-]>+++++.
                        
                        Send the channel name from our buffer
                        [-]>[.>]<[<]
                        
                        Send a space; then a colon (58)
                        [-]<[-]++++++++++[>+++<-]>++.
                        [-]<[-]++++++++++[>++++++<-]>--.
                        
                        Finally; send the user's message
                        [-]+[ ,. ---------- ]
                    <[-]]
                [-]]
            [-]
        [-]]>[-]+
    <[-]>[-]]<[
        Handle PING
        ,,, Read out "ING "
        Write PONG 80 79 78 71 32
        [-]++++++++++[
            >++++++++
            >++++++++
            >++++++++
            >+++++++
            >+++
            <<<<<-
        ]>.>-.>--.>+.>++.<<<<<
        [-]+[ ,. ---------- ] Write out the PING response
    [-]]>+
]