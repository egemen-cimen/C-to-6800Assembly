%{

	#define BUFFERLEN 32	// size for one symbol name string: var1, var22, etc.
				// note: there is a possible bug: max variable name is 8 characters

	#include <stdio.h>	// printf()
	#include <stdlib.h>	// exit()
	#include "linkedlist.h" // custom linkedlist
	#include "util.h"	// temp variable name generator, address generator

	void yyerror(char *);
	int yylex(void);
	extern FILE *yyin;
	extern int linenum;
	FILE* outputFile;	// for outputing variable values to a  file
	int yydebug=1;	/*this actives the debug mode of yacc*/
	int verbose=0;	// indicetes if this program is verbose

	int labelNumber;	// this is for passing label number around
	char stateConditionOfIf[BUFFERLEN];	// this is for passing around if's condition
/*expression is defined as string to pass its varible name around*/


%}
%union
{
// is used to get the type of lexemes
int number;
char* string;
}
%token <number> INTEGER 
%token <string> IDENTIFIER 
%token MINUSOP PLUSOP OPENPAR CLOSEPAR MULTOP ASSIGNOP SEMICOLON 
%token OPENCURL CLOSECURL EQUAL NOTEQUAL LESSEQUAL GREATEQUAL
%token INT IF ELSE RETURN LESSTHAN GREATERTHAN DOT COMMA
%type <string> expression assign assignment
%type <string> equality
%type <number> if_begin
%left ASSIGNOP
%left EQUAL NOTEQUAL LESSEQUAL GREATEQUAL LESSTHAN GREATERTHAN
%left PLUSOP MINUSOP
%left MULTOP 
%%

program		: statement
		| statement program
		;

statement	: assignment SEMICOLON
		{
			struct symbol* dollarOne  = lookForSymbol( $1 );	// string in IDENTIFIER

			if ( dollarOne == NULL )
			{
				// give an error and exit because variable isn't defined yet
				fprintf(stderr, "The variable %s is not defined yet! +++++ %d\n", $1, linenum);
				exit(1);
			}
			if ( 2 )
			{
2;

			}
			//TODO


		}
		| INT assignment SEMICOLON
		{
			struct symbol* dollarTwo  = lookForSymbol( $2 );		// string in IDENTIFIER
			char nameBuffer[BUFFERLEN];

			if ( dollarTwo != NULL && dollarTwo->definedWithoutKnowing == 0 )	// means "i knew it was not definded
												// but i declared anyway. and good thing 
												// that i did because it was needed
												// anyway" to the program
												// this solves problem that if a variable
												// was defined or not
			{
				// give an error and exit because variable is already defined
				fprintf(stderr, "The variable %s has already been defined! +++++ %d\n", $2, linenum);
				exit(1);
			}

			if ( dollarTwo != NULL )
			{
				


			}


			//TODO



		}
		
		| INT IDENTIFIER SEMICOLON	// int b1;
		{
			struct symbol* dollarTwo  = lookForSymbol( $2 );
			char nameBuffer[BUFFERLEN];
			char addressBuffer[BUFFERLEN];

			if ( dollarTwo == NULL )
			{
				strncpy( addressBuffer, generateMainAddress(), sizeof(addressBuffer) );				   
				strncpy( nameBuffer, $2, sizeof(nameBuffer) );
				addToSymbolTable( nameBuffer, addressBuffer );

				

			}
			else if ( dollarTwo->definedWithoutKnowing == 0 )
			{
				// give an error and exit because variable is already defined
				fprintf(stderr, "The variable %s has already been defined!! +++++ %d\n", $2, linenum);
				exit(1);
			}

		}

		| if_statement
		| function_decl
		| return
		;

assignment	: assign
		{
			$$ = $1;
		}

		| assign COMMA assignment
		{

			$$ = $1;
		}
		;

assign		: IDENTIFIER
		{
			$$ = $1;
		}

		| IDENTIFIER ASSIGNOP expression 
		{
			// act like its a variable decleration. if it isn't give the error at "statement"
			// addToSymbolTable( $look ofr symbol here for $1, generateMainAddress() );

			struct symbol* dollarOne  = lookForSymbol( $1 );	// string in IDENTIFIER
			struct symbol* dollarThree   = lookForSymbol( $3 );	// look for $3 to access its 6800 address
			struct symbol* temp;
			int value;
			char nameBuffer[BUFFERLEN];
			char addressBuffer[BUFFERLEN];
			int pseudoIsUsed = 0;	// a flag to keep what is used
			if(dollarOne == NULL)	// if symbol is not in the symbol table
			{	
				strncpy( addressBuffer, generateMainAddress(), sizeof(addressBuffer) );
				strncpy( nameBuffer, $1, sizeof(nameBuffer) );
				addToSymbolTable( nameBuffer, addressBuffer );
				dollarOne = lookForSymbol($1);
				dollarOne->definedWithoutKnowing = 1;


			}
			value = atoi($3);
			if( value != 0 )	//$3 is a numerical value
			{ 
				//printf("Numerical value: %d\n", value);
				if (verbose)
				{
				printf("\tLDAA #%d\n", value);	// this is the numeric value that 
				printf("\tSTAA $%s\n\n", dollarOne->varValue);	// store to address
				}

				fprintf(outputFile, "\tLDAA #%d\n", value);		// this is the numeric value that 
				fprintf(outputFile, "\tSTAA $%s\n\n", dollarOne->varValue);		// store to address

				// write to file
			}
	
			if (dollarThree == NULL)	// if this is not the real variable name find for the pseudo name
			{
				dollarThree = lookForPseudoName( $3 );
				pseudoIsUsed = 1;
			}
			if (dollarThree != NULL)	// $3 is in the symbol table
			{
				//print/write address of $3
				// I THINK I create the unnecessary assignmnet here. ex: c <- tmp0004
//				printf("Address of var %s: %s\n",dollarThree->varName, dollarThree->varValue);

				if (verbose)
				{
				printf("\tLDAA $%s\n", dollarThree->varValue);
				printf("\tSTAA $%s\n\n", dollarOne->varValue);
				}

				fprintf(outputFile, "\tLDAA $%s\n", dollarThree->varValue);
				fprintf(outputFile, "\tSTAA $%s\n\n", dollarOne->varValue);
				// write to output



			}

			//printf("T: %s",$1);
			$$ = $1;
		}
		;

if_statement	: if_begin assignment SEMICOLON
		{
                        if(verbose)
                        {
                        printf("if%d\tNOP\n\n", $1);
                        printf("belse%d\tNOP\n\n", $1);
                        }
                        fprintf(outputFile, "if%d\tNOP\n\n", $1);
                        fprintf(outputFile, "belse%d\tNOP\n\n", $1);

		}

		| if_begin assignment SEMICOLON else_statement
		{
                        if(verbose)
                        {
                        printf("if%d\tNOP\n\n", $1);

                        }
                        fprintf(outputFile, "if%d\tNOP\n\n", $1);

		}


		| if_begin OPENCURL program CLOSECURL
		{
                        if(verbose)
                        {
                        printf("if%d\tNOP\n\n", $1);
                        printf("belse%d\tNOP\n\n", $1);
                        }
                        fprintf(outputFile, "if%d\tNOP\n\n", $1);
                        fprintf(outputFile, "belse%d\tNOP\n\n", $1);


		}

		| if_begin OPENCURL program CLOSECURL else_statement
		{
                        if(verbose)
                        {
                        printf("if%d\tNOP\n\n", $1);
                        }
                        fprintf(outputFile, "if%d\tNOP\n\n", $1);

		}
		;

if_begin	: IF OPENPAR expression CLOSEPAR
		{
			labelNumber = generateLabelNumber();
			strncpy ( stateConditionOfIf, $3, sizeof(stateConditionOfIf) );


			if( !strcmp( $3, "eequal" ) ) // if they are equal; jump if they are not equal
        	        {
				if(verbose)
				{
				printf("\tBNE belse%d\n\n", labelNumber);
				}
				fprintf(outputFile, "\tBNE belse%d\n\n", labelNumber);
	

              		}

                        if( !strcmp( $3, "enotequal" ) )	// jump if they are equal
			{
                                if(verbose)
                                {
                                printf("\tBEQ belse%d\n\n", labelNumber);
                                }
                                fprintf(outputFile, "\tBEQ belse%d\n\n", labelNumber);


			}

                        if( !strcmp( $3, "egreaterthan" ) )
			{
                                if(verbose)
                                {
                                printf("\tBLE belse%d\n\n", labelNumber);
                                }
                                fprintf(outputFile, "\tBLE belse%d\n\n", labelNumber);



			}	

                        if( !strcmp( $3, "elessthan" ) )
			{
                                if(verbose)
                                {
                                printf("\tBGE belse%d\n\n", labelNumber);
                                }
                                fprintf(outputFile, "\tBGE belse%d\n\n", labelNumber);


			}

                        if( !strcmp( $3, "elessequal" ) )
			{
                                if(verbose)
                                {
                                printf("\tBGT belse%d\n\n", labelNumber);
                                }
                                fprintf(outputFile, "\tBGT belse%d\n\n", labelNumber);

			}

                        if( !strcmp( $3, "egreatequal" ) )	// if(>=) so jump if <
			{
                                if(verbose)
                                {
                                printf("\tBLT belse%d\n\n", labelNumber);
                                }
                                fprintf(outputFile, "\tBLT belse%d\n\n", labelNumber);


			}


			$$ = labelNumber;

		}
		;



else_statement	: else_begin assignment SEMICOLON
		{
/*                        if(verbose)
	                {
                        printf("\tBRA else%d\n\n", labelNumber);
                        }
                        fprintf(outputFile, "\tBRA else%d\n\n", labelNumber);
*/
	
//			printf("else%d\tNOP\n\n", labelNumber);

		}

		| else_begin if_statement
		| else_begin OPENCURL program CLOSECURL
		;

else_begin	: ELSE
		{


			if (verbose)	// do a branch always here. so that the program wont execure both if and else 
					// statements one after another
			{
				printf("\tBRA if%d\n\n", labelNumber);	
			}
			fprintf(outputFile, "\tBRA if%d\n\n", labelNumber);




			if( !strcmp( stateConditionOfIf, "eequal" ) ) // if they are equal; jump if they are not equal
        	        {
				if(verbose)
				{
				printf("belse%d\tBEQ if%d\n\n",labelNumber, labelNumber);
				}
				fprintf(outputFile, "belse%d\tBEQ if%d\n\n",labelNumber, labelNumber);
	

              		}

                        if( !strcmp( stateConditionOfIf, "enotequal" ) )	// jump if they are equal
			{
                                if(verbose)
                                {
                                printf("belse%d\tBNE if%d\n\n",labelNumber, labelNumber);
                                }
                                fprintf(outputFile, "belse%d\tBNE if%d\n\n", labelNumber, labelNumber);


			}

                        if( !strcmp( stateConditionOfIf, "egreaterthan" ) )
			{
                                if(verbose)
                                {
                                printf("belse%d\tBGT if%d\n\n",labelNumber, labelNumber);
                                }
                                fprintf(outputFile, "belse%d\tBGT if%d\n\n",labelNumber, labelNumber);



			}	

                        if( !strcmp( stateConditionOfIf, "elessthan" ) )
			{
                                if(verbose)
                                {
                                printf("belse%d\tBLT if%d\n\n",labelNumber, labelNumber);
                                }
                                fprintf(outputFile, "belse%d\tBLT if%d\n\n",labelNumber, labelNumber);


			}

                        if( !strcmp( stateConditionOfIf, "elessequal" ) )
			{
                                if(verbose)
                                {
                                printf("\tBLE if%d\n\n", labelNumber);
                                }
                                fprintf(outputFile, "\tBLE if%d\n\n", labelNumber);

			}

                        if( !strcmp( stateConditionOfIf, "egreatequal" ) )	// if(>=) so jump if <
			{
                                if(verbose)
                                {
                                printf("\tBGE if%d\n\n", labelNumber);
                                }
                                fprintf(outputFile, "\tBGE if%d\n\n", labelNumber);


			}



		}
		;

expression	: INTEGER
		{
			// here you get expression as an integer. so convert it to string.
			char buffer[BUFFERLEN];
			sprintf(buffer, "%d", $1);
			$$ = strdup(buffer);
		}
	  
		| IDENTIFIER
		{
			$$ = $1;
		}

		| expression PLUSOP expression
		{
			char tempPseudo[BUFFERLEN];	// make a new temp variable.
							// generate a new name for that.
							// generate a new address for that.
			char tempPseudoAddress[BUFFERLEN];
			strncpy ( tempPseudoAddress, generateTempAddress(), sizeof(tempPseudoAddress) );
			strncpy( tempPseudo, generateVariableName(), sizeof(tempPseudo) );
			addToSymbolTableOnlyPseudo( tempPseudo, tempPseudoAddress );
			struct symbol* tempPseudoNode = lookForPseudoName( tempPseudo );

			struct symbol* dollarOne   = lookForSymbol( $1 );
			struct symbol* dollarThree = lookForSymbol( $3 );
			// if they are not variable names look for them in pseudoname. may introduce errors (bugs) to the program
			if (dollarOne == NULL)
				dollarOne   = lookForPseudoName( $1 );
			if (dollarThree == NULL)
				dollarThree = lookForPseudoName( $3 );

			if (dollarOne != NULL && dollarThree != NULL)// both first and second are in symbol table and are not numeric values
			{

				if(verbose)
				{
				printf("\tLDAA $%s\n", dollarOne->varValue);		// load $1's address
				printf("\tADDA $%s\n", dollarThree->varValue);	// add $3's address
				printf("\tSTAA $%s\n\n", tempPseudoAddress);		// store to tempPseudo's address
				}

				fprintf(outputFile, "\tLDAA $%s\n", dollarOne->varValue);		  // load $1's address
				fprintf(outputFile, "\tADDA $%s\n", dollarThree->varValue);		// add $3's address
				fprintf(outputFile, "\tSTAA $%s\n\n", tempPseudoAddress);		  // store to tempPseudo's address



				// write to file

			}	

			if (dollarOne != NULL && atoi($3) != 0 )	// first exists and second is a numeric value
			{

				if (verbose)
				{
				printf("\tLDAA $%s\n", dollarOne->varValue);
				printf("\tADDA #%s\n", $3);
				printf("\tSTAA $%s\n\n", tempPseudoAddress);
				}

				fprintf(outputFile, "\tLDAA $%s\n", dollarOne->varValue);
				fprintf(outputFile, "\tADDA #%s\n", $3);
				fprintf(outputFile, "\tSTAA $%s\n\n", tempPseudoAddress);

			
			}



			if ( atoi($1) != 0 && dollarThree != NULL )	// second exists and first is a numeric value
			{
				if (verbose)
				{
				printf("\tLDAA #%s\n", $1);
				printf("\tADDA $%s\n", dollarThree->varValue);
				printf("\tSTAA $%s\n\n", tempPseudoAddress);
				}
			
				fprintf(outputFile, "\tLDAA #%s\n", $1);
				fprintf(outputFile, "\tADDA $%s\n", dollarThree->varValue);
			  	fprintf(outputFile, "\tSTAA $%s\n\n", tempPseudoAddress);

			}


			if ( atoi($1) && atoi($3) != 0 )	// both are numeric values
			{

				if(verbose)
				{
				printf("\tLDAA #%s\n", $1);
				printf("\tADDA #%s\n", $3);
				printf("\tSTAA $%s\n\n", tempPseudoAddress);
				}

				fprintf(outputFile, "\tLDAA #%s\n", $1);
				fprintf(outputFile, "\tADDA #%s\n", $3);
				fprintf(outputFile, "\tSTAA $%s\n\n", tempPseudoAddress);


			}

			$$ = strdup(tempPseudo);
			// this will assign pseudo name to $$


		}

		| expression MINUSOP expression
		{
			char tempPseudo[BUFFERLEN];	// make a new temp variable.
							// generate a new name for that.
							// generate a new address for that.
			char tempPseudoAddress[BUFFERLEN];
			strncpy ( tempPseudoAddress, generateTempAddress(), sizeof(tempPseudoAddress) );
			strncpy( tempPseudo, generateVariableName(), sizeof(tempPseudo) );
			addToSymbolTableOnlyPseudo( tempPseudo, tempPseudoAddress );
			struct symbol* tempPseudoNode = lookForPseudoName( tempPseudo );

				struct symbol* dollarOne   = lookForSymbol( $1 );
				struct symbol* dollarThree = lookForSymbol( $3 );
				// if they are not variable names look for them in pseudoname. may introduce errors (bugs) to the program
				if (dollarOne == NULL)
					dollarOne   = lookForPseudoName( $1 );
				if (dollarThree == NULL)
					dollarThree = lookForPseudoName( $3 );

			if (dollarOne != NULL && dollarThree != NULL)	// both first and second are in symbol table and are not numeric values
			{

				if(verbose)
				{
				printf("\tLDAA $%s\n", dollarOne->varValue);		// load $1's address
				printf("\tSUBA $%s\n", dollarThree->varValue);	// add $3's address
				printf("\tSTAA $%s\n\n", tempPseudoAddress);		// store to tempPseudo's address
				}

				fprintf(outputFile, "\tLDAA $%s\n", dollarOne->varValue);		  // load $1's address
				fprintf(outputFile, "\tSUBA $%s\n", dollarThree->varValue);		// add $3's address
				fprintf(outputFile, "\tSTAA $%s\n\n", tempPseudoAddress);		  // store to tempPseudo's address



				// write to file

			}	

			if (dollarOne != NULL && atoi($3) != 0 )	// first exists and second is a numeric value
			{

				if (verbose)
				{
				printf("\tLDAA $%s\n", dollarOne->varValue);
				printf("\tSUBA #%s\n", $3);
				printf("\tSTAA $%s\n\n", tempPseudoAddress);
				}

				fprintf(outputFile, "\tLDAA $%s\n", dollarOne->varValue);
				fprintf(outputFile, "\tSUBA #%s\n", $3);
				fprintf(outputFile, "\tSTAA $%s\n\n", tempPseudoAddress);

			
			}


			if ( atoi($1) != 0 && dollarThree != NULL )	// second exists and first is a numeric value
			{
				if (verbose)
				{
				printf("\tLDAA #%s\n", $1);
				printf("\tSUBA $%s\n", dollarThree->varValue);
				printf("\tSTAA $%s\n\n", tempPseudoAddress);
				}
			
				fprintf(outputFile, "\tLDAA #%s\n", $1);
				fprintf(outputFile, "\tSUBA $%s\n", dollarThree->varValue);
			  	fprintf(outputFile, "\tSTAA $%s\n\n", tempPseudoAddress);

			}


			if ( atoi($1) && atoi($3) != 0 )	// both are numeric values
			{

				if(verbose)
				{
				printf("\tLDAA #%s\n", $1);
				printf("\tSUBA #%s\n", $3);
				printf("\tSTAA $%s\n\n", tempPseudoAddress);
				}

				fprintf(outputFile, "\tLDAA #%s\n", $1);
				fprintf(outputFile, "\tSUBA #%s\n", $3);
				fprintf(outputFile, "\tSTAA $%s\n\n", tempPseudoAddress);

			}

			$$ = strdup(tempPseudo);
			// this will assign pseudo name to $$

		}


		| expression MULTOP expression
		{
			char tempPseudo[BUFFERLEN];	// make a new temp variable.
							// generate a new name for that.
							// generate a new address for that.
			char tempPseudoAddress[BUFFERLEN];
			strncpy ( tempPseudoAddress, generateTempAddress(), sizeof(tempPseudoAddress) );
			strncpy( tempPseudo, generateVariableName(), sizeof(tempPseudo) );
			addToSymbolTableOnlyPseudo( tempPseudo, tempPseudoAddress );
			struct symbol* tempPseudoNode = lookForPseudoName( tempPseudo );

			struct symbol* dollarOne   = lookForSymbol( $1 );
			struct symbol* dollarThree = lookForSymbol( $3 );

			int shiftLabelNumber = generateLabelNumber();
                        int decLabelNumber = generateLabelNumber();



			// if they are not variable names look for them in pseudoname. may introduce errors (bugs) to the program
			if (dollarOne == NULL)
				dollarOne   = lookForPseudoName( $1 );
			if (dollarThree == NULL)
				dollarThree = lookForPseudoName( $3 );

			if (dollarOne != NULL && dollarThree != NULL)	// both first and second are in symbol table and are not numeric values
			{

				if(verbose)
				{
				printf("\tLDAA $%s\n", dollarOne->varValue);	// load from $1's address
				printf("\tLDAB $%s\n", dollarThree->varValue);	// load from $3's address
				printf("\tSTAA $130\n");			// save accumulator A to some temp address 130H
				printf("\tLDX #8\n");         			// load number of bits ofthe multiplier to index register

				printf("SHIFT%d\tASLB\n", shiftLabelNumber);    //shift product one bit
				printf("\tROLA\n");
				printf("\tASL $%s\n", dollarOne->varValue);	// shift multiplier left to exemine one bit
				printf("\tBCC DECR%d\n", decLabelNumber);       // examine next bit
				printf("\tADDB $%s\n", dollarThree->varValue);  // add multiplicand to the product if carry is 1
				printf("\tADCA #0\n");    	          	// product if carry is 1
				printf("DECR%d\tDEX\n", decLabelNumber);
				printf("\tBNE SHIFT%d\n", shiftLabelNumber);    // repeat until index register is 0
				printf("\tSTAB $%s\n\n", tempPseudoAddress);	// store result (8 bit) to tempPseudo's address
				printf("\tLDAA $130\n");			// store B back
				printf("\tSTAA $%s\n", dollarOne->varValue);	// store A back to its original content	
				}

                                fprintf(outputFile, "\tLDAA $%s\n", dollarOne->varValue);    // load from $1's address
                                fprintf(outputFile, "\tLDAB $%s\n", dollarThree->varValue);  // load from $3's address
                                fprintf(outputFile, "\tSTAA $130\n");                        // save accumulator A to some temp address 130H
                                fprintf(outputFile, "\tLDX #8\n");                           // load number of bits ofthe multiplier to index register

                                fprintf(outputFile, "SHIFT%d\tASLB\n", shiftLabelNumber);    //shift product one bit
                                fprintf(outputFile, "\tROLA\n");
                                fprintf(outputFile, "\tASL $%s\n", dollarOne->varValue);     // shift multiplier left to exemine one bit
                                fprintf(outputFile, "\tBCC DECR%d\n", decLabelNumber);       // examine next bit
                                fprintf(outputFile, "\tADDB $%s\n", dollarThree->varValue);  // add multiplicand to the product if carry is 1
                                fprintf(outputFile, "\tADCA #0\n");                          // product if carry is 1
                                fprintf(outputFile, "DECR%d\tDEX\n", decLabelNumber);
                                fprintf(outputFile, "\tBNE SHIFT%d\n", shiftLabelNumber);    // repeat until index register is 0
                                fprintf(outputFile, "\tSTAB $%s\n\n", tempPseudoAddress);    // store result (8 bit) to tempPseudo's address
                                fprintf(outputFile, "\tLDAA $130\n");                        // store B back
                                fprintf(outputFile, "\tSTAA $%s\n", dollarOne->varValue);    // store A back to its original content 

				// write to file

			}	

			if (dollarOne != NULL && atoi($3) != 0 )	// first exists and second is a numeric value
			{

				if (verbose)
				{

                                printf("\tLDAA $%s\n", dollarOne->varValue);    // load from $1's address
                                printf("\tLDAB #%s\n", $3);                     // load second from numeric value 
                                printf("\tSTAA $130\n");                        // backup accumulator A to some temp address 130H
                                printf("\tSTAB $131\n");                        // store second (numeric value) to 131H
                                printf("\tLDX #8\n");                           // load number of bits ofthe multiplier to index register

                                printf("SHIFT%d\tASLB\n", shiftLabelNumber);    //shift product one bit
                                printf("\tROLA\n");
                                printf("\tASL $%s\n", dollarOne->varValue);     // shift multiplier left to exemine one bit
                                printf("\tBCC DECR%d\n", decLabelNumber);       // examine next bit
                                printf("\tADDB $131\n");			// add multiplicand to the product if carry is 1

                                printf("\tADCA #0\n");                          // product if carry is 1
                                printf("DECR%d\tDEX\n", decLabelNumber);
                                printf("\tBNE SHIFT%d\n", shiftLabelNumber);    // repeat until index register is 0
                                printf("\tSTAB $%s\n\n", tempPseudoAddress);    // store result (8 bit) to tempPseudo's address
                                printf("\tLDAA $130\n");                        // store the backup back
                                printf("\tSTAA $%s\n", dollarOne->varValue);    // store A back to its original content 

				}

                                fprintf(outputFile, "\tLDAA $%s\n", dollarOne->varValue);    // load from $1's address
                                fprintf(outputFile, "\tLDAB #%s\n", $3);                     // load second from numeric value 
                                fprintf(outputFile, "\tSTAA $130\n");                        // backup accumulator A to some temp address 130H
                                fprintf(outputFile, "\tSTAB $131\n");                        // store second (numeric value) to 131H
                                fprintf(outputFile, "\tLDX #8\n");                           // load number of bits ofthe multiplier to index register

                                fprintf(outputFile, "SHIFT%d\tASLB\n", shiftLabelNumber);    //shift product one bit
                                fprintf(outputFile, "\tROLA\n");
                                fprintf(outputFile, "\tASL $%s\n", dollarOne->varValue);     // shift multiplier left to exemine one bit
                                fprintf(outputFile, "\tBCC DECR%d\n", decLabelNumber);       // examine next bit
                                fprintf(outputFile, "\tADDB $131\n");                        // add multiplicand to the product if carry is 1

                                fprintf(outputFile, "\tADCA #0\n");                          // product if carry is 1
                                fprintf(outputFile, "DECR%d\tDEX\n", decLabelNumber);
                                fprintf(outputFile, "\tBNE SHIFT%d\n", shiftLabelNumber);    // repeat until index register is 0
                                fprintf(outputFile, "\tSTAB $%s\n\n", tempPseudoAddress);    // store result (8 bit) to tempPseudo's address
                                fprintf(outputFile, "\tLDAA $130\n");                        // store the backup back
                                fprintf(outputFile, "\tSTAA $%s\n", dollarOne->varValue);    // store A back to its original content 




			
			}



			if ( atoi($1) != 0 && dollarThree != NULL )	// second exists and first is a numeric value
			{
				if (verbose)
				{

                                printf("\tLDAA #%s\n", $1);                     // load first numeric value
                                printf("\tSTAA $130\n");                        // store first numeric value to 130H

                                printf("\tLDAB $%s\n", dollarThree->varValue);  // load from $3's address
                                printf("\tLDX #8\n");                           // load number of bits ofthe multiplier to index register

                                printf("SHIFT%d\tASLB\n", shiftLabelNumber);    //shift product one bit
                                printf("\tROLA\n");
                                printf("\tASL $130\n");     // shift multiplier left to exemine one bit
                                printf("\tBCC DECR%d\n", decLabelNumber);       // examine next bit
                                printf("\tADDB $%s\n", dollarThree->varValue);  // add multiplicand to the product if carry is 1
                                printf("\tADCA #0\n");                          // product if carry is 1
                                printf("DECR%d\tDEX\n", decLabelNumber);
                                printf("\tBNE SHIFT%d\n", shiftLabelNumber);    // repeat until index register is 0
                                printf("\tSTAB $%s\n\n", tempPseudoAddress);    // store result (8 bit) to tempPseudo's address



				}
			

                                fprintf(outputFile, "\tLDAA #%s\n", $1);                     // load first numeric value
                                fprintf(outputFile, "\tSTAA $130\n");                        // store first numeric value to 130H

                                fprintf(outputFile, "\tLDAB $%s\n", dollarThree->varValue);  // load from $3's address
                                fprintf(outputFile, "\tLDX #8\n");                           // load number of bits ofthe multiplier to index register

                                fprintf(outputFile, "SHIFT%d\tASLB\n", shiftLabelNumber);    //shift product one bit
                                fprintf(outputFile, "\tROLA\n");
                                fprintf(outputFile, "\tASL $130\n");     // shift multiplier left to exemine one bit
                                fprintf(outputFile, "\tBCC DECR%d\n", decLabelNumber);       // examine next bit
                                fprintf(outputFile, "\tADDB $%s\n", dollarThree->varValue);  // add multiplicand to the product if carry is 1
                                fprintf(outputFile, "\tADCA #0\n");                          // product if carry is 1
                                fprintf(outputFile, "DECR%d\tDEX\n", decLabelNumber);
                                fprintf(outputFile, "\tBNE SHIFT%d\n", shiftLabelNumber);    // repeat until index register is 0
                                fprintf(outputFile, "\tSTAB $%s\n\n", tempPseudoAddress);    // store result (8 bit) to tempPseudo's address

			}


			if ( atoi($1) && atoi($3) != 0 )	// both are numeric values
			{

				if(verbose)
				{
                                printf("\tLDAA #%s\n", $1);			// load first numeric value
                                printf("\tLDAB #%s\n", $3);			// load second numeric value 
                                printf("\tSTAA $130\n");			// store first numeric value to 130H
                                printf("\tSTAB $131\n");			// store second numeric value to 131H
				
                                printf("\tLDX #8\n");                           // load number of bits ofthe multiplier to index register

                                printf("SHIFT%d\tASLB\n", shiftLabelNumber);    //shift product one bit
                                printf("\tROLA\n");
                                printf("\tASL $130\n");     // shift multiplier left to exemine one bit
                                printf("\tBCC DECR%d\n", decLabelNumber);       // examine next bit
                                printf("\tADDB $131\n");  // add multiplicand to the product if carry is 1
                                printf("\tADCA #0\n");                          // product if carry is 1
                                printf("DECR%d\tDEX\n", decLabelNumber);
                                printf("\tBNE SHIFT%d\n", shiftLabelNumber);    // repeat until index register is 0
                                printf("\tSTAB $%s\n\n", tempPseudoAddress);    // store result (8 bit) to tempPseudo's address

				}

                                fprintf(outputFile, "\tLDAA #%s\n", $1);                     // load first numeric value
                                fprintf(outputFile, "\tLDAB #%s\n", $3);                     // load second numeric value 
                                fprintf(outputFile, "\tSTAA $130\n");                        // store first numeric value to 130H
                                fprintf(outputFile, "\tSTAB $131\n");                        // store second numeric value to 131H

                                fprintf(outputFile, "\tLDX #8\n");                           // load number of bits ofthe multiplier to index register
                                fprintf(outputFile, "SHIFT%d\tASLB\n", shiftLabelNumber);    //shift product one bit
                                fprintf(outputFile, "\tROLA\n");
                                fprintf(outputFile, "\tASL $130\n");     // shift multiplier left to exemine one bit
                                fprintf(outputFile, "\tBCC DECR%d\n", decLabelNumber);       // examine next bit
                                fprintf(outputFile, "\tADDB $131\n");  // add multiplicand to the product if carry is 1
                                fprintf(outputFile, "\tADCA #0\n");                          // product if carry is 1
                                fprintf(outputFile, "DECR%d\tDEX\n", decLabelNumber);
                                fprintf(outputFile, "\tBNE SHIFT%d\n", shiftLabelNumber);    // repeat until index register is 0
                                fprintf(outputFile, "\tSTAB $%s\n\n", tempPseudoAddress);    // store result (8 bit) to tempPseudo's address





			}

			$$ = strdup(tempPseudo);
			// this will assign pseudo name to $$


		}



		| OPENPAR expression CLOSEPAR 
		{
			$$ = $2;
		}

		| expression equality expression
		{
			struct symbol* dollarOne   = lookForSymbol( $1 );
			struct symbol* dollarThree = lookForSymbol( $3 );
			// if they are not variable names look for them in pseudoname. may introduce errors (bugs) to the program
			if (dollarOne == NULL)
				dollarOne   = lookForPseudoName( $1 );
			if (dollarThree == NULL)
				dollarThree = lookForPseudoName( $3 );

			if (dollarOne != NULL && dollarThree != NULL)	// both first and second are in symbol table and are not numeric values
			{
				if(verbose)
				{
				printf("\tLDAA $%s\n", dollarOne->varValue);		// load $1's address
				printf("\tCMPA $%s\n\n", dollarThree->varValue);		// compare with $3's address
											// if they are the same the zero flag will be zero
				}
				fprintf(outputFile, "\tLDAA $%s\n", dollarOne->varValue);		  // load $1's address
				fprintf(outputFile, "\tCMPA $%s\n", dollarThree->varValue);		// add $3's address
				// write to file

			}	

			if (dollarOne != NULL && atoi($3) != 0 )	// first exists and second is a numeric value
			{
				if (verbose)
				{
				printf("\tLDAA $%s\n", dollarOne->varValue);
				printf("\tCMPA #%s\n", $3);
				}
				fprintf(outputFile, "\tLDAA $%s\n", dollarOne->varValue);
				fprintf(outputFile, "\tCMPA #%s\n", $3);
			
			}

			if ( atoi($1) != 0 && dollarThree != NULL )	// second exists and first is a numeric value
			{
				if (verbose)
				{
				printf("\tLDAA #%s\n", $1);
				printf("\tCMPA $%s\n", dollarThree->varValue);
				}
				fprintf(outputFile, "\tLDAA #%s\n", $1);
				fprintf(outputFile, "\tCMPA $%s\n", dollarThree->varValue);

			}

			if ( atoi($1) && atoi($3) != 0 )	// both are numeric values
			{
				if(verbose)
				{
				printf("\tLDAA #%s\n", $1);
				printf("\tCMPA #%s\n", $3);
				}
				fprintf(outputFile, "\tLDAA #%s\n", $1);
				fprintf(outputFile, "\tCMPA #%s\n", $3);

			}
$$=$2;	
		}
		;

equality	: EQUAL
		{
			$$ = "eequal";
		}

		| NOTEQUAL
		{
			$$ = "enotequal";

		}

		| GREATERTHAN
		{
			$$ = "egreaterthan";
		}

		| LESSTHAN
		{
			$$ = "elessthan";
		}

		| LESSEQUAL
		{
			$$ = "elessequal";
			
		}

		| GREATEQUAL
		{
			$$ = "egreatequal";
		}

		;

function_decl	: INT IDENTIFIER OPENPAR CLOSEPAR OPENCURL program CLOSECURL
		;

return		: RETURN expression SEMICOLON
		;

%%

void yyerror(char *s) {
	fprintf(stderr, "%s\n ++++ %d", s,linenum);
}
int yywrap(){
	return 1;
}
int main(int argc, char *argv[])
{
	verbose = 0;
	if (argv[2] != NULL)	// decide if this program is verbose (run with -v as its 2nd argument)
		if ( !strncmp(argv[2], "-v", 2) )
			verbose = 1;
	initSymbolTable();

	fclose(fopen("output.asm", "w"));	// reset output file


	outputFile = fopen("output.asm", "a");	// open a file pointer in append mode to 
						// write assembly code

	if (outputFile == NULL)
	{
		fprintf(stderr, "Can't open output file!\n");
		exit(1);
	}

	initNameGenerator();	// initialize variable name generator 
	initAddressGenerator();	// initialize address generator 
	initNumberGenerator();	// initialize number generator for label numbers. (to make labels unique)
	/* Call the lexer, then quit. */
	yyin=fopen(argv[1],"r");
	yyparse();
	fclose(yyin);

        if(verbose)
        {
        printf("return\t.end\n");
        }
        fprintf(outputFile, "return\t.end\n");


	if (verbose)
		printSymbolTable();
	fclose(outputFile);	// close output file

	freeLinkedList();	// free the linked list because i used malloc before
	return 0;

}
