Brainfuck IRC bot
* Comments use ; in place of periods or commas as punctuation
* Meant to operate on 8 bit unsigned memory
* Uses a minimum of 35 bytes of memory; more may be needed depending on the length of channel names it works in
* Expects stdin to block until data is available
* If you use netfuck; it'd be useful to know that debug mode outputs every character read from the remote to the console

Send NICK and USER
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
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

cell #0: working cell for iteration and such
cell #1 stdin (pointer currently points here)
[
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
                        [-]<++++++++++[>++++++++<-]>++.
                        [-]<++++++++++[>+++++++<-]>+++.
                        [-]<++++++++++[>+++++++++<-]>----.
                        [-]<++++++++++[>++++++++<-]>---.
                        [-]<++++++++++[>++++++++<-]>+++.
                        [-]<++++++++++[>+++++++<-]>+.
                        [-]<++++++++++[>+++<-]>++.
                        [-]<++++++++++[>+++<-]>+++++.
                        
                        Send the channel name from our buffer
                        [-]>[.>]<[<]
                        
                        Send a space; then a colon (58)
                        [-]<[-]++++++++++[>+++<-]>++.
                        [-]<++++++++++[>++++++<-]>--.
                        
                        Finally; send the user's message
                        [-]+[ ,. ---------- ]
                    <[-]]
                [-]]
            [-]
        [-]]>[-]+
    <[-]>[-]]<[
        Handle PING
        ,,, Read out "ING" (optimization: we steal the space from this message later on; so we needn't write it)
        Write PONG 80 79 78 71 32
        [-]++++++++++[
            >++++++++
            >++++++++
            >++++++++
            >+++++++
            <<<<<-
        ]>.>-.>--.>+.<<<<<
        [-]+[ ,. ---------- ] Write out the PING response
    ]>+
]