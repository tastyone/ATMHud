/*
 *  ATMTextLayer.h
 *  ATMHud
 *
 *  Created by Marcel Müller on 2011-03-01.
 *  Copyright (c) 2010-2011, Marcel Müller (atomcraft)
 *  All rights reserved.
 *
 *	https://github.com/atomton/ATMHud
 */

#import <QuartzCore/CALayer.h>

@interface ATMTextLayer : CALayer {
	NSString *caption;
    UIFont *font;
    UILineBreakMode lineBreakMode;
    UITextAlignment textAlignment;
    BOOL shadowEnabled;
}

@property (nonatomic, retain) NSString *caption;
@property (nonatomic, retain) UIFont *font;
@property (nonatomic, assign) UILineBreakMode lineBreakMode;
@property (nonatomic, assign) UITextAlignment textAlignment;
@property (nonatomic, assign) BOOL shadowEnabled;

@end
