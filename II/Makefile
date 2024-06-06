BIN= parser2
LEX= lexer2
FOLD= src

all: $(FOLD)/$(BIN).y $(FOLD)/$(LEX).l
	bison -d -g -v -t  $(FOLD)/$(BIN).y -o $(FOLD)/$(BIN).tab.c
	dot -Tpng $(FOLD)/$(BIN).gv -o $(FOLD)/$(BIN).png
	flex -o $(FOLD)/lex.yy.c $(FOLD)/$(LEX).l
	$(CC) -c $(FOLD)/lex.yy.c -o $(FOLD)/lex.yy.o
	$(CC) -c $(FOLD)/$(BIN).tab.c -o $(FOLD)/$(BIN).tab.o
	$(CC) -o $(FOLD)/$(BIN).bin $(FOLD)/lex.yy.o $(FOLD)/$(BIN).tab.o -lm


debug: $(FOLD)/$(BIN).y $(FOLD)/$(LEX).l
	bison -d -g -v -t  $(FOLD)/$(BIN).y -o $(FOLD)/$(BIN).tab.c
	dot -Tpng $(FOLD)/$(BIN).gv -o $(FOLD)/$(BIN).png
	flex -dTv -o $(FOLD)/lex.yy.c $(FOLD)/$(LEX).l
	$(CC) -c $(FOLD)/lex.yy.c -o $(FOLD)/lex.yy.o
	$(CC) -c $(FOLD)/$(BIN).tab.c -o $(FOLD)/$(BIN).tab.o
	$(CC) -o $(FOLD)/$(BIN).bin $(FOLD)/lex.yy.o $(FOLD)/$(BIN).tab.o -lm

clean:
	rm -fv $(FOLD)/$(BIN).bin $(FOLD)/$(BIN).tab.h $(FOLD)/$(BIN).tab.c $(FOLD)/lex.yy.c $(FOLD)/lex.yy.o $(FOLD)/$(BIN).tab.o $(FOLD)/$(BIN).vcg lex.backup $(FOLD)/$(BIN).dot $(FOLD)/$(BIN).gv $(FOLD)/$(BIN).png $(FOLD)/$(BIN).output *~