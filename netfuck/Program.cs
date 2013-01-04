using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Text;
using System.IO;
using System.Net.Sockets;

namespace netfuck
{
    internal class Program
    {
        private static void Main(string[] args)
        {
            bool debug = args.Length == 3;
            if (args.Length < 2 || args.Length > 3)
            {
                Console.WriteLine("Usage: netfuck hostname:address /path/to/file.bf [--debug]");
                return;
            }
            var code = args[1];
            if (File.Exists(code))
                code = File.ReadAllText(code);
            // Establish connection
            var endpoint = ParseEndPoint(args[0]);
            var client = new TcpClient();
            client.Connect(endpoint);
            var stream = client.GetStream();
            // Interpret code
            var memory = new byte[ushort.MaxValue + 1];
            ushort pointer = 0;
            int codeIndex = 0;
            bool inDebugger = false;
            while (codeIndex < code.Length)
            {
                if (inDebugger)
                {
                    Console.ForegroundColor = ConsoleColor.Red;
                    Console.WriteLine("Current instruction: " + code[codeIndex] + " (source index " + codeIndex + ")");
                    Console.WriteLine("Memory pointer: " + pointer);
                    Console.Write("Memory dump: ");
                    for (ushort i = (ushort)(pointer - 4); i < pointer + 5; i++)
                    {
                        if (pointer == i)
                            Console.Write("[" + memory[i] + "]");
                        else
                            Console.Write(memory[i]);
                    }
                    var command = "";
                    while (command != "continue")
                    {
                        Console.Write(">");
                        command = Console.ReadLine();
                        if (command.StartsWith("cell "))
                            Console.WriteLine(memory[int.Parse(command.Substring(5))]);
                        else if (command == "step")
                            break;
                        else if (command == "continue")
                            inDebugger = false;
                    }
                    Console.ResetColor();
                }
                switch (code[codeIndex])
                {
                    case '>':
                        pointer++;
                        break;
                    case '<':
                        pointer--;
                        break;
                    case '+':
                        memory[pointer]++;
                        break;
                    case '-':
                        memory[pointer]--;
                        break;
                    case '.':
                        stream.WriteByte(memory[pointer]);
                        break;
                    case ',':
                        while (client.Available == 0) ;
                        memory[pointer] = (byte)stream.ReadByte();
                        if (debug) Console.Write(Encoding.ASCII.GetString(new[] { memory[pointer] }));
                        break;
                    case '[':
                        if (memory[pointer] == 0)
                        {
                            int depth = 0;
                            while (depth >= 0)
                            {
                                codeIndex++;
                                if (code[codeIndex] == '[') depth++;
                                if (code[codeIndex] == ']') depth--;
                                if (codeIndex >= code.Length)
                                {
                                    Console.ForegroundColor = ConsoleColor.Red;
                                    Console.WriteLine("ERROR: Hanging '['");
                                    Console.ResetColor();
                                    return;
                                }
                            }
                        }
                        break;
                    case ']':
                        if (memory[pointer] != 0)
                        {
                            int depth = 0;
                            while (depth >= 0)
                            {
                                codeIndex--;
                                if (code[codeIndex] == ']') depth++;
                                if (code[codeIndex] == '[') depth--;
                                if (codeIndex < 0)
                                {
                                    Console.ForegroundColor = ConsoleColor.Red;
                                    Console.WriteLine("ERROR: Hanging ']'");
                                    Console.ResetColor();
                                    return;
                                }
                            }
                        }
                        break;
                    case '@':
                        if (debug)
                        {
                            inDebugger = true;
                            Console.ForegroundColor = ConsoleColor.Red;
                            Console.WriteLine("Breakpoint hit, entering debug mode.");
                        }
                        break;
                }
                codeIndex++;
            }
        }

        private static IPEndPoint ParseEndPoint(string arg)
        {
            IPAddress address;
            int port;
            if (arg.Contains(':'))
            {
                // Both IP and port are specified
                var parts = arg.Split(':');
                if (!IPAddress.TryParse(parts[0], out address))
                    address = Resolve(parts[0]);
                return new IPEndPoint(address, int.Parse(parts[1]));
            }
            if (IPAddress.TryParse(arg, out address))
                return new IPEndPoint(address, 6667);
            if (int.TryParse(arg, out port))
                return new IPEndPoint(IPAddress.Loopback, port);
            return new IPEndPoint(Resolve(arg), 6667);
        }

        private static IPAddress Resolve(string arg)
        {
            return Dns.GetHostEntry(arg).AddressList.FirstOrDefault();
        }
    }
}
