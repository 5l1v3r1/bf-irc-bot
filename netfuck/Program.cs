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
            while (codeIndex < code.Length)
            {
                switch (code[codeIndex++])
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
                            codeIndex = code.IndexOf(']', codeIndex);
                            if (codeIndex == -1)
                            {
                                Console.WriteLine("Error: Hanging '['");
                                return;
                            }
                        }
                        break;
                    case ']':
                        if (memory[pointer] != 0)
                        {
                            codeIndex = code.Remove(codeIndex).LastIndexOf('[');
                            if (codeIndex == -1)
                            {
                                Console.WriteLine("Error: Hanging ']'");
                                return;
                            }
                        }
                        break;
                }
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
