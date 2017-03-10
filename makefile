all: yacc lex
	gcc lex.yy.c y.tab.c linkedlist.c util.c -o project

# -d flag is for creating "y.tab.h" file. this file is used by lex
yacc: project.y
	yacc -d project.y

lex: project.l
	lex project.l

#this is for the debug build. doesn't remove intermediate files. creates y.output and the running program is verbose
debug: yaccdebug lex
	gcc lex.yy.c y.tab.c linkedlist.c util.c -o project

#this is for debug build. yacc takes --debug and --verbose flags 
yaccdebug: project.y
	yacc -d --debug --verbose project.y 

#remove extra files
remove:
	rm y.tab.c
	rm y.tab.h
	rm lex.yy.c

removedebug:
	rm y.output
	rm y.tab.c
	rm y.tab.h
	rm lex.yy.c
