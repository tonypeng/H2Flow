/*
 *  Globals.h
 *  H2Flow
 *
 *  Created by Tony Peng on 1/23/11.
 *
 */

#define _DEBUG

#ifdef _DEBUG
#define DbgPrint(x, ...) NSLog(x)
#else
#define DbgPrint
#endif