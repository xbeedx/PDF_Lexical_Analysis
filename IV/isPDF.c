#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define COLOR_RESET "\033[0m"
#define COLOR_RED "\033[31m"
#define COLOR_GREEN "\033[32m"
#define COLOR_YELLOW "\033[33m"
#define COLOR_BLUE "\033[34m"
#define COLOR_CYAN "\033[36m"

int compare_ulong(const void *, const void *);
void execute_make_command(const char *, const char *);
FILE *open_result_file(const char *);
void parse_file(FILE *, unsigned long **, size_t *);
void execute_second_parser(const char *, unsigned long *, size_t, char[][256], char[][256]);
void show_loading_bar(size_t, size_t);
void list_font_descriptors(const char *, unsigned long *, char[][256], char[][256], size_t);
size_t count_pages(unsigned long *, char[][256], char[][256], size_t);

int main(int argc, char *argv[]) {
    if (argc != 2) {
        fprintf(stderr, COLOR_RED "Usage: %s <filename>\n" COLOR_RESET, argv[0]);
        return 1;
    }

    unsigned long *addresses = NULL;
    size_t addressesCount = 0;

    printf(COLOR_GREEN "Step 1: Executing initial make command...\n" COLOR_RESET);
    execute_make_command("make -C ../II/ >/dev/null 2>&1", "Initial make command");

    char command[256];
    snprintf(command, sizeof(command), "cd ../II && ./src/parser2.bin ../IV/%s > result.txt", argv[1]);
    execute_make_command(command, "Running parser2");

    printf(COLOR_GREEN "Step 2: Opening result file...\n" COLOR_RESET);
    FILE *file = open_result_file("../II/result.txt");
    if (!file) return 1;

    printf(COLOR_GREEN "Step 3: Parsing result file...\n" COLOR_RESET);
    parse_file(file, &addresses, &addressesCount);
    fclose(file);

    char objectTypes[addressesCount][256];
    memset(objectTypes, 0, sizeof(objectTypes));

    char Types[addressesCount][256];
    memset(Types, 0, sizeof(Types));

    printf(COLOR_GREEN "Step 4: Sorting addresses...\n" COLOR_RESET);
    qsort(addresses, addressesCount, sizeof(unsigned long), compare_ulong);
    printf(COLOR_GREEN "Sorting complete.\n" COLOR_RESET);

    printf(COLOR_GREEN "Step 5: Executing second parser for each address pair...\n" COLOR_RESET);
    execute_second_parser(argv[1], addresses, addressesCount, objectTypes, Types);

    execute_make_command("make clean -C ../II/ >/dev/null 2>&1", "Cleaning up");

    list_font_descriptors(argv[1], addresses, objectTypes, Types, addressesCount);

    size_t pageCount = count_pages(addresses, objectTypes, Types, addressesCount);

    printf(COLOR_BLUE "Number of Pages: %zu\n" COLOR_RESET, pageCount);
    
    free(addresses);

    return 0;
}

int yyerror(const char *s) {
    fprintf(stderr, COLOR_RED "ERROR: %s\n" COLOR_RESET, s);
    return 0;
}

int compare_ulong(const void *a, const void *b) {
    unsigned long ul_a = *(const unsigned long *)a;
    unsigned long ul_b = *(const unsigned long *)b;
    return (ul_a > ul_b) - (ul_a < ul_b);
}

void execute_make_command(const char *command, const char *message) {
    printf(COLOR_CYAN "%s...\n" COLOR_RESET, message);
    int result = system(command);
    if (result != 0) {
        fprintf(stderr, COLOR_RED "Error executing command: %s\n" COLOR_RESET, command);
        exit(1);
    }
}

FILE *open_result_file(const char *filename) {
    FILE *file = fopen(filename, "r");
    if (!file) {
        fprintf(stderr, COLOR_RED);
        perror(filename);
        fprintf(stderr, COLOR_RESET);
    }
    return file;
}

void parse_file(FILE *file, unsigned long **addresses, size_t *addressesCount) {
    char line[256];
    size_t lineCount = 0;
    
    while (fgets(line, sizeof(line), file)) {
        lineCount++;
    }

    rewind(file);
    size_t currentLine = 0;
    
    while (fgets(line, sizeof(line), file)) {
        unsigned long address;
        int objectId, generationNumber;
        if (sscanf(line, "Address: %lu, Object ID: %d, Generation Number: %d", &address, &objectId, &generationNumber) == 3) {
            *addresses = realloc(*addresses, (*addressesCount + 1) * sizeof(unsigned long));
            if (!*addresses) {
                perror(COLOR_RED "Memory allocation failed" COLOR_RESET);
                fclose(file);
                exit(1);
            }
            (*addresses)[(*addressesCount)++] = address;
        }
        show_loading_bar(++currentLine, lineCount);
    }
}

void execute_second_parser(const char *filename, unsigned long *addresses, size_t addressesCount, char objectTypes[][256], char Types[][256]) {
    execute_make_command("make -C ../III/III-II/ >/dev/null 2>&1", "Make command for second parser");
    char command[256];
    int errorEncountered = 0;

    for (size_t i = 0; i < addressesCount - 1; i++) {
        snprintf(command, sizeof(command),
                 "cd ../III/III-II/ && ./src/parser4.bin ../../IV/%s %lu %lu",
                 filename, addresses[i], addresses[i + 1]);

        FILE *pipe = popen(command, "r");
        if (!pipe) {
            fprintf(stderr, COLOR_RED "*Error* while running parser4 for addresses %lu and %lu\n" COLOR_RESET, addresses[i], addresses[i + 1]);
            errorEncountered = 1;
            break;
        }

        char line[256];
        if (fgets(line, sizeof(line), pipe)) {
            char objectType[256];
            if (sscanf(line, "Valid %*s object of type %s %*[^\n]", objectType) == 1) {
                snprintf(objectTypes[i], sizeof(objectTypes[i]), "%s", objectType);
                if (strcmp(objectType, "DICT") == 0) {
                    while (fgets(line, sizeof(line), pipe)) {
                        char type[256], value[256];
                        if (sscanf(line, "/Type => Valid PDF object of type %s : %[^\n]", type, value) == 2) {
                            snprintf(Types[i], sizeof(Types[i]), "%s", value);
                            break;
                        }
                    }
                }
            } else {
                errorEncountered = 1;
            }
        } else {
            errorEncountered = 1;
        }

        pclose(pipe);
        show_loading_bar(i + 1, addressesCount - 1);
    }

    if (!errorEncountered) {
        printf("\n");
        printf(COLOR_GREEN "=== Object Types ===\n" COLOR_RESET);
        for (size_t i = 0; i < addressesCount - 1; i++) {
            printf(COLOR_CYAN "Address: %lu, " COLOR_RESET, addresses[i]);
            printf(COLOR_YELLOW "Object Type: %s" COLOR_RESET, objectTypes[i]);
            if (Types[i][0] != '\0') {
                printf(", " COLOR_BLUE "/Type: %s" COLOR_RESET, Types[i]);
            }
            printf("\n");
        }
        printf(COLOR_GREEN "All objects are well defined.\n\n" COLOR_RESET);
    } else {
        fprintf(stderr, COLOR_RED "=== ERROR ===\n" COLOR_RESET);
        fprintf(stderr, COLOR_RED "Some objects were not well defined.\n\n" COLOR_RESET);
    }

    execute_make_command("make clean -C ../III/III-II/ >/dev/null 2>&1", "Cleaning up after second parser");
}

void show_loading_bar(size_t current, size_t total) {
    int barWidth = 50;
    float progress = (float)current / total;
    int pos = barWidth * progress;

    printf(COLOR_YELLOW "[");
    for (int i = 0; i < barWidth; ++i) {
        if (i < pos) printf("=");
        else if (i == pos) printf(">");
        else printf(" ");
    }
    printf("] %d%%\r" COLOR_RESET, (int)(progress * 100.0));
    fflush(stdout);
    if (current == total) {
        printf("\n");
    }
}

void list_font_descriptors(const char *filename, unsigned long *addresses, char objectTypes[][256], char Types[][256], size_t addressesCount) {
    printf(COLOR_GREEN "=== Font Descriptors ===\n" COLOR_RESET);

    FILE *file;
    for (size_t i = 0; i < addressesCount - 1; i++) {
        if (strcmp(objectTypes[i], "DICT") == 0 && strstr(Types[i], "/FontDescriptor")) {
            file = fopen(filename, "r");
            if (!file) {
                fprintf(stderr, COLOR_RED "Error opening file: %s\n" COLOR_RESET, filename);
                return;
            }

            unsigned long a = addresses[i];
            unsigned long b = addresses[i + 1];

            fseek(file, a, SEEK_SET);

            size_t size = b - a;
            char *buffer = (char *)malloc(size + 1); 
            if (!buffer) {
                fclose(file);
                fprintf(stderr, COLOR_RED "Memory allocation failed\n" COLOR_RESET);
                return;
            }

            fread(buffer, 1, size, file);
            buffer[size] = '\0'; 

            printf(COLOR_CYAN "Address: %lu\n" COLOR_RESET, addresses[i]);
            printf(COLOR_YELLOW "Object Type: %s\n" COLOR_RESET, objectTypes[i]);
            printf(COLOR_BLUE "/Type: %s\n" COLOR_RESET, Types[i]);
            
            printf(COLOR_GREEN "Content:\n" COLOR_RESET);
            printf("%.*s%s%.*s\n", (int)a, buffer, COLOR_RED, (int)(size - a), buffer + a);
            
            free(buffer);
            fclose(file);
        }
    }
}

size_t count_pages(unsigned long *addresses, char objectTypes[][256], char Types[][256], size_t addressesCount) {
    printf(COLOR_GREEN "=== Pages ===\n" COLOR_RESET);
    size_t pageCount = 0;

    for (size_t i = 0; i < addressesCount - 1; i++) {
        if (strcmp(objectTypes[i], "DICT") == 0 && strcmp(Types[i], "/Page") == 0) {
            pageCount++;
        }
    }

    return pageCount;
}
