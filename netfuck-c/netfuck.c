#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <sys/types.h>
#include <sys/socket.h>

const int memory_length = 1024;

char* memory;
char* executable;
int pointer, executable_length, executable_index;

int seek_next();
int seek_prev();

int main(int argc, char** argv) { // netfuck file.bf endpoint:port
    if (argc != 3) {
        printf("Incorrect usage.\n");
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
                printf("%c", memory[pointer]);
                break;
            case ',':
                // ...
                break;
            case '[':
                if (!memory[pointer]) {
                    if (!seek_next()) {
                        printf("Error: Unmatched '['\n");
                        return 1;
                    }
                }
                break;
            case ']':
                if (memory[pointer]) {
                    if (!seek_prev()) {
                        printf("Error: Unmatched ']'\n");
                        return 1;
                    }
                }
                break;
        }
        executable_index++;
    }
    
    free(memory);
    free(executable);
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