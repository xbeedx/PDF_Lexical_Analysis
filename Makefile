BIN= parser1
LEX= lexer1
FOLD= src
TESTS= Tests
TEST_FILES= test-files
T_TEST= True
F_TEST= False
TEST_T_RESULT= result-True.txt
TEST_F_Result= result-False.txt
PYTHON_TEST= tests.py
GENERATE_TESTS= generate-pdfs.py
DOC_DIR= doc
LOG_DIR= logs

.PHONY: doc

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

test: all
	python3 $(TESTS)/$(GENERATE_TESTS)
	echo "" >  $(TESTS)/$(TEST_T_RESULT)
	echo "" >  $(TESTS)/$(TEST_F_Result)
	for file in $(TESTS)/$(TEST_FILES)/$(T_TEST)/*; do \
		echo "-TEST-" >>  $(TESTS)/$(TEST_T_RESULT);\
		echo $$file >>  $(TESTS)/$(TEST_T_RESULT);\
		./$(FOLD)/$(BIN).bin $$file >> $(TESTS)/$(TEST_T_RESULT); \
	done
	for file in $(TESTS)/$(TEST_FILES)/$(F_TEST)/*; do \
		echo "-TEST-" >>  $(TESTS)/$(TEST_F_Result);\
		echo $$file >>  $(TESTS)/$(TEST_F_Result);\
		./$(FOLD)/$(BIN).bin $$file >> $(TESTS)/$(TEST_F_Result) 2>&1; \
	done
	make clean
	python3 $(TESTS)/$(PYTHON_TEST)
	make cleanTests

testsNoLog: all
	@python3 $(TESTS)/$(GENERATE_TESTS) > $(LOG_DIR)/generate_tests_log.txt 2>&1
	@echo "" >  $(TESTS)/$(TEST_T_RESULT)
	@echo "" >  $(TESTS)/$(TEST_F_Result)
	@mkdir -p $(LOG_DIR)
	@for file in $(TESTS)/$(TEST_FILES)/$(T_TEST)/*; do \
		echo "-TEST-" >>  $(TESTS)/$(TEST_T_RESULT);\
		echo $$file >>  $(TESTS)/$(TEST_T_RESULT);\
		./$(FOLD)/$(BIN).bin $$file >> $(TESTS)/$(TEST_T_RESULT); \
	done
	@for file in $(TESTS)/$(TEST_FILES)/$(F_TEST)/*; do \
		echo "-TEST-" >>  $(TESTS)/$(TEST_F_Result);\
		echo $$file >>  $(TESTS)/$(TEST_F_Result);\
		./$(FOLD)/$(BIN).bin $$file >> $(TESTS)/$(TEST_F_Result) 2>&1; \
	done
	@make clean > $(LOG_DIR)/make_clean_log.txt 2>&1
	@python3 $(TESTS)/$(PYTHON_TEST)
	@make cleanTests > $(LOG_DIR)/clean_tests_log.txt 2>&1

cleanTests:
	rm -fv $(TESTS)/$(TEST_FILES)/*/test*.pdf

doc:
	cd $(DOC_DIR) && pdflatex doc.tex
	make cleanTex

cleanTex:
	rm -fv $(DOC_DIR)/*.aux $(DOC_DIR)/*.log $(DOC_DIR)/*.fls $(DOC_DIR)/*.out $(DOC_DIR)/*.fdb_latexmk

cleanLogs:
	rm -fv $(LOG_DIR)/*.txt

clean:
	rm -fv $(FOLD)/$(BIN).bin $(FOLD)/$(BIN).tab.h $(FOLD)/$(BIN).tab.c $(FOLD)/lex.yy.c $(FOLD)/lex.yy.o $(FOLD)/$(BIN).tab.o $(FOLD)/$(BIN).vcg lex.backup $(FOLD)/$(BIN).dot $(FOLD)/$(BIN).gv $(FOLD)/$(BIN).png $(FOLD)/$(BIN).output *~

cleanAll: clean cleanTests cleanTex cleanLogs