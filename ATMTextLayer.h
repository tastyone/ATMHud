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
#if defined(__IPHONE_6_0)
    NSLineBreakMode lineBreakMode;
    NSTextAlignment textAlignment;
#else
    UILineBreakMode lineBreakMode;
    UITextAlignment textAlignment;
#endif
    BOOL shadowEnabled;
}

@property (nonatomic, retain) UIColor *color;
@property (nonatomic, retain) NSString *caption;
@property (nonatomic, retain) UIFont *font;
#if defined(__IPHONE_6_0)
@property (nonatomic, assign) NSLineBreakMode lineBreakMode;
@property (nonatomic, assign) NSTextAlignment textAlignment;
#else
@property (nonatomic, assign) UILineBreakMode lineBreakMode;
@property (nonatomic, assign) UITextAlignment textAlignment;
#endif
@property (nonatomic, assign) BOOL shadowEnabled;

@end
