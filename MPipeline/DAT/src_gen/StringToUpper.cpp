#include <ctype.h>
#include <string>
// namespaces
using namespace std;
string StringToUpper(string strToConvert)

{//change each element of the string to upper case
   for(unsigned int i=0;i<strToConvert.length();i++)

   {
      strToConvert[i] = toupper(strToConvert[i]);
   }

   return strToConvert;//return the converted string
}

