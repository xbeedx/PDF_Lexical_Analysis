CC=gcc

CFLAGS=-Wall -g

TARGET=isPDF

SOURCES=isPDF.c
OBJECTS=$(SOURCES:.c=.o)

all: $(TARGET)

$(TARGET): $(OBJECTS)
	$(CC) $(CFLAGS) -o $(TARGET) $(OBJECTS)

%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

clean:
	rm -f $(TARGET) $(OBJECTS)

run: $(TARGET)
	./$(TARGET)

test: $(TARGET)
	./$(TARGET) TD3.pdf 
	@echo "Cleaning up..."
	@$(MAKE) clean