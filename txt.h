//
// written by Quang Trinh <quang.trinh@gmail.com>
//

#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#include "common.h"
#include "acgtn.h"

#ifndef TXT_H
#define TXT_H 

#define MODE_TXT_COUNT_ENTRY 1001
#define MODE_TXT_EXTRACT_COLUMN_FROM_FILE 1010
#define MODE_TXT_EXTRACT_ROW_FROM_FILE 1020

int txt_MODE_TXT_COUNT_ENTRY(struct input_data *id, char inputFileName[], char ignoreLinesStartingWith) ;
int txt_MODE_TXT_EXTRACT_COLUMN_FROM_FILE(struct input_data *id, char inputFileName[], char columnsToBeExtracted[], double value, int alsoPrintAllOtherColumns) ;
int txt_MODE_TXT_DELETE_COLUMN_FROM_FILE(struct input_data *id, char inputFileName[], char columnsToBeExtracted[]) ;



#endif 
