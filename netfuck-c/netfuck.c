#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <netdb.h>
#include <sys/types.h>
#include <sys/socket.h>

const int memory_length = 1024;

char* memory;
char* executable;
int pointer, executable_length, executable_index;

int seek_next();
int seek_prev();

int main(int argc, char** argv) { // Usage: netfuck file.bf endpoint:port
    if (argc != 3) {
        printf("Incorrect usage. Try ./netfuck file.bf endpoint:port\n");
        return 1;
    }
    
    FILE* file = fopen(argv[1], "r");
    if (!file) {
        printf("Unable to open file.\n");
        return 1;
    }
    
    fseek(file, 0L, SEEK_END);
    int executable_length = ftell(file) + 1;
    executable = (char*)malloc(executable_length);
    fseek(file, 0L, SEEK_SET);
    int i = 0;
    while ((executable[i++] = fgetc(file)) != EOF);
    fclose(file);
    
    memory = (char*)malloc(memory_length);
    pointer = 0;
    executable_index = 0;
    
    char* host = (char*)malloc(strlen(argv[2]));
    strcpy(host, argv[2]);
    char* port = host;
    while (*port && *port != ':') port++;
    if (!*port) {
        printf("Invalid endpoint specified. Must be in address:port format.\n");
        free(executable);
        free(memory);
        free(host);
        return 1;
    }
    *port++ = 0;
    for (int i = 0; i < strlen(port); i++) {
        if (port[i] < '0' || port[i] > '9') {
            printf("Invalid port specified. Must be an integer between 0 and 65535.\n");
            free(executable);
            free(memory);
            free(host);
            return 1;
        }
    }
    i = atoi(port);
    if (i < 0 || i > 0xFFFF) {
        printf("Invalid port specified. Must be an integer between 0 and 65535.\n");
        free(executable);
        free(memory);
        free(host);
        return 1;
    }
    struct addrinfo *result, *server, hints;
    memset(&hints, 0, sizeof(struct addrinfo));
    hints.ai_family = AF_INET; // TODO: IPv6
    hints.ai_socktype = SOCK_DGRAM;
    if (getaddrinfo(host, port, &hints, &result)) {
        printf("Error looking up %s.\n", host);
        free(executable);
        free(memory);
        free(host);
        return 1;
    }
    
    server = result;
    while (server != NULL) {
        server = server->ai_next;
        if (server->ai_family == AF_INET)
            break;
    }
    if (server == NULL) {
        printf("Unable to resolve %s\n", argv[2]);
        free(executable);
        free(memory);
        free(host);
        freeaddrinfo(result);
        return 1;
    }
    
    // Open socket
    int sockfd = socket(server->ai_family, server->ai_socktype, server->ai_protocol);
    if (sockfd < 0) {
        printf("Failed to create socket.\n");
        free(executable);
        free(memory);
        free(host);
        freeaddrinfo(result);
        return 1;
    }
    if (connect(sockfd, server->ai_addr, server->ai_addrlen) < 0) {
        printf("Failed to connect to %s.\n", argv[2]);
        free(executable);
        free(memory);
        free(host);
        freeaddrinfo(result);
        return 1;
    }
    
    char c;
    while (executable_index < executable_length) {
        switch (executable[executable_index]) {
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
                send(sockfd, (void*)(memory + pointer), sizeof(char), 0);
                printf("%c", memory[pointer]);
                break;
            case ',':
                if (!recv(sockfd, (void*)&c, sizeof(char), 0)) {
                    printf("The remote host closed the connection.\n");
                    return 1;
                }
                memory[pointer] = c;
                printf("%c", c);
                break;
            case '[':
                if (!memory[pointer]) {
                    if (!seek_next()) {
                        printf("Error: Unmatched '['\n");
                        shutdown(sockfd, SHUT_RDWR);
                        free(memory);
                        free(executable);
                        free(host);
                        freeaddrinfo(result);
                        return 1;
                    }
                }
                break;
            case ']':
                if (memory[pointer]) {
                    if (!seek_prev()) {
                        printf("Error: Unmatched ']'\n");
                        shutdown(sockfd, SHUT_RDWR);
                        free(memory);
                        free(executable);
                        free(host);
                        freeaddrinfo(result);
                        return 1;
                    }
                }
                break;
        }
        executable_index++;
    }
    
    shutdown(sockfd, SHUT_RDWR);
    free(memory);
    free(executable);
    free(host);
    freeaddrinfo(result);
}

int seek_next() {
    int depth = 1;
    while (depth) {
        executable_index++;
        if (executable_index > executable_length)
            return 0;
        if (executable[executable_index] == '[') depth++;
        if (executable[executable_index] == ']') depth--;
    }
    executable_index++;
    return 1;
}

int seek_prev() {
    int depth = 1;
    while (depth) {
        executable_index--;
        if (executable_index < 0)
            return 0;
        if (executable[executable_index] == '[') depth--;
        if (executable[executable_index] == ']') depth++;
    }
    executable_index++;
    return 1;
}