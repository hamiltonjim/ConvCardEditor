//
//  CCLeadChoice.h
//  CCardX
//
//  Created by Jim Hamilton on 8/28/10.
//  Copyright 2010 Jim Hamilton. All rights reserved.
//
//  $Id: CCLeadChoice.h,v 1.1 2010/10/20 03:00:17 jimh Exp $

#import <Cocoa/Cocoa.h>
#import "CCctrlParent.h"
#import "CCLeadChoiceCell.h"
#import "CCDebuggableControl.h"

@interface CCLeadChoice : NSButton <CCDebuggableControl> 

@property (weak, nonatomic) id <CCctrlParent> parent;

@end
