#include "util.h"

// initializes the name generator
void initNameGenerator()
{
	nameGenCounter = 1;

}


// generates a variable name sequentially
char* generateVariableName()
{

//	this one generates v000, v001, ... , v010, v011, ... , v998, v999
	name[0] = 't';
	name[1] = 'm';
	name[2] = 'p';
	sprintf(name + 3, "%.3d", nameGenCounter);

	++nameGenCounter;

	return name;


//	this one generates a, b, c, d, e, ...
/*        sprintf(name, "%c", 'a' + nameGenCounter);

        ++nameGenCounter;
*/
        return name;


}


void initAddressGenerator()
{
	mainAddressCounter = 0x110;
	tempAddressCounter = 0x120;
//printf("Start From: %x\n", tempAddressCounter);
}

// generates an address for temp(intermediate) variables
char* generateTempAddress()
{
	sprintf(tempAddress, "%x", tempAddressCounter);

	++tempAddressCounter;

	return tempAddress;
}

// generates an address for variables
char* generateMainAddress()
{
        sprintf(mainAddress, "%x", mainAddressCounter);
//        printf("%x\n", mainAddressCounter);

        ++mainAddressCounter;

        return mainAddress;
}

// generates sequential numbers
void initNumberGenerator()
{
	labelCounter = 0;

}



// returns generated numbers as string
int generateLabelNumber()
{
	++labelCounter;

	return labelCounter;

}


