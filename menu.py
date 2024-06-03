import os
import curses

options = {
    "1": {"name": "Build (all)", "description": "Builds the parser and lexer."},
    "2": {"name": "Debug build", "description": "Builds the parser and lexer with debug symbols."},
    "3": {"name": "Run tests", "description": "Runs tests using generated binaries."},
    "4": {"name": "Run tests without logs", "description": "Runs tests without logs."},
    "5": {"name": "Generate documentation", "description": "Generates documentation from LaTeX files."},
    "6": {"name": "Clean", "description": "Cleans generated binaries and temporary files."},
    "7": {"name": "Clean tests", "description": "Cleans generated test files."},
    "8": {"name": "Clean logs", "description": "Cleans generated log files."},
    "9": {"name": "Clean all", "description": "Cleans all generated files and logs."},
}

def clear_terminal():
    os.system("clear")

def display_menu(stdscr, selected_row):
    stdscr.clear()
    max_y, max_x = stdscr.getmaxyx()
    
    # ASCII Art Header
    ascii_art = [
    " _  _  ____  __ _  _  _ ",
    "( \\/ )(  __)(  ( \\/ )( \\",
    "/ \\/ \\ ) _) /    /) \\/ (",
    "\\_)(_/(____)\\_)__)\\____/"
]
    
    for i, line in enumerate(ascii_art):
        stdscr.addstr(i, (max_x - len(line)) // 2, line, curses.color_pair(3))

    stdscr.addstr(len(ascii_art), 0, "~~~~~~~~~~~~~~~~~~~~~~~~~", curses.color_pair(1))
    
    for idx, (key, value) in enumerate(options.items(), start=1):
        x = len(ascii_art) + 2 * idx
        y = 4
        if x < max_y and y < max_x:
            if idx == selected_row:
                stdscr.attron(curses.color_pair(2))
                stdscr.addstr(x, y, f"{key}. {value['name']}: {value['description']}")
                stdscr.attroff(curses.color_pair(2))
            else:
                stdscr.addstr(x, y, f"{key}. {value['name']}: {value['description']}", curses.color_pair(3))
    stdscr.addstr(max_y - 1, 0, "Press 'q' to exit.", curses.color_pair(1))
    stdscr.refresh()

def main(stdscr):
    curses.curs_set(0)
    curses.init_pair(1, curses.COLOR_MAGENTA, curses.COLOR_BLUE)  # Header color
    curses.init_pair(2, curses.COLOR_YELLOW, curses.COLOR_BLACK)  # Selected item color
    curses.init_pair(3, curses.COLOR_CYAN, curses.COLOR_BLACK)  # Other items color
    curses.init_pair(4, curses.COLOR_GREEN, curses.COLOR_BLACK)  # ASCII Art color
    current_row = 1
    display_menu(stdscr, current_row)
    while True:
        key = stdscr.getch()
        if key == curses.KEY_UP:
            if current_row == 1:
                current_row = len(options)
            else:
                current_row -= 1
        elif key == curses.KEY_DOWN:
            if current_row == len(options):
                current_row = 1
            else:
                current_row += 1
        elif key == curses.KEY_ENTER or key in [10, 13]:
            stdscr.addstr(curses.LINES - 1, 0, "Press any key to continue...", curses.color_pair(1))
            stdscr.refresh()
            clear_terminal()
            return current_row
        elif key == ord('q'):
            break
        stdscr.clear()
        display_menu(stdscr, current_row)

def execute_option(choice):
    clear_terminal()
    if choice == "1":
        os.system("make all")
    elif choice == "2":
        os.system("make debug")
    elif choice == "3":
        os.system("make test")
    elif choice == "4":
        os.system("make testsNoLog")
    elif choice == "5":
        os.system("make doc")
    elif choice == "6":
        os.system("make clean")
    elif choice == "7":
        os.system("make cleanTests")
    elif choice == "8":
        os.system("make cleanLogs")
    elif choice == "9":
        os.system("make cleanAll")
    elif choice == "0" or choice == "q":
        print("Exiting...")
        exit()

if __name__ == "__main__":
    result = curses.wrapper(main)
    execute_option(str(result))
