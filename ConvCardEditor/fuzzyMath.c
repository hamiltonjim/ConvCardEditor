//
//  fuzzyMath.c
//  ConvCardEditor
//
//  Created by Jim Hamilton on 1/30/13.
//  Copyright (c) 2013 Jim Hamilton. All rights reserved.
//

#include "math.h"

static const double kEpsilon = 1e-6;

    // return {-1, 0, 1} comparing left with right, within epsilon
int fuzzyCompareEps(double left, double right, double epsilon)
{
    double cmp = left - right;
    epsilon = fabs(epsilon);
    
    if (cmp < -epsilon) {
        return -1;
    } else if (cmp > epsilon) {
        return 1;
    } else {
            // fuzzy equal
        return 0;
    }
}

    // same as above, but with (epsilon == one millionth)
int fuzzyCompare(double left, double right)
{
    return fuzzyCompareEps(left, right, kEpsilon);
}

    // is num within epsilon of zero?  Returns TRUE when num approx 0
int fuzzyZeroEps(double num, double epsilon)
{
    return fabs(num) < epsilon;
}
int fuzzyZero(double num)
{
    return fabs(num) < kEpsilon;
}


    // count 1 bits in a word -- use 2's complement property of negatives
int count1bits(unsigned long bits)
{
    int ones = 0;
    
    while (bits) {
            // bits & -bits == rightmost 1 bit in word!
            // next statement zeroes rightmost 1 bit
        bits ^= bits & -bits;
            // ...and count each zeroed bit
        ++ones;
    }
    
    return ones;
}
