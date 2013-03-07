//
//  fuzzyMath.h
//  ConvCardEditor
//
//  Created by Jim Hamilton on 1/30/13.
//  Copyright (c) 2013 Jim Hamilton. All rights reserved.
//

#ifndef ConvCardEditor_fuzzyMath_h
#define ConvCardEditor_fuzzyMath_h

    // return {-1, 0, 1} comparing left with right, within epsilon
int fuzzyCompareEps(double left, double right, double epsilon);
    // same as above, but with (epsilon == one millionth)
int fuzzyCompare(double left, double right);

    // is num within epsilon of zero?  Returns TRUE when num approx 0
int fuzzyZeroEps(double num, double epsilon);
    // same as above, with assumed epsilon of 1e-6
int fuzzyZero(double num);

    // return the number of 1 bits in the word, as efficiently as
    // possible for all values
int count1bits(unsigned long bits);

    // rounding with a twist:
    //  position: round at any decimal position, with -1 meaning the
    //      nearest tenth, and 1 meaning the tens column; i.e., multiply
    //      by pow(10, position), round, divide by pow(10, position)
    //  boundary: from here up, round away from zero; from here down,
    //      round toward zero.  boundary MUST be between 0.0 and 1.0,
    //      exclusive.
double fuzzyRound(double value, int position, double boundary);
    // version where position is always zero (ones column)
double fuzzyRoundInt(double value, double boundary);

#endif
