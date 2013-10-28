/*
 *  ATMTextLayer.m
 *  ATMHud
 *
 *  Created by Marcel Müller on 2011-03-01.
 *  Copyright (c) 2010-2011, Marcel Müller (atomcraft)
 *  All rights reserved.
 *
 *	https://github.com/atomton/ATMHud
 */

#import "ATMTextLayer.h"

@implementation ATMTextLayer
@synthesize caption;
@synthesize font;
@synthesize lineBreakMode;
@synthesize textAlignment;
@synthesize shadowEnabled;

- (id)init {
    self = [super init];
    if (self) {
        [self _initialize];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self _initialize];
    }
    return self;
}

- (id)initWithLayer:(id)layer {
	if ((self = [super init])) {
        [self _initialize];
	}
	return self;
}

- (void)_initialize
{
    self.caption = @"";
    self.font = [UIFont boldSystemFontOfSize:14];
#if defined(__IPHONE_6_0)
    lineBreakMode = NSLineBreakByCharWrapping;
    textAlignment = NSTextAlignmentCenter;
#else
    lineBreakMode = UILineBreakModeWordWrap;
    textAlignment = UITextAlignmentCenter;
#endif
    shadowEnabled = YES;
}

+ (BOOL)needsDisplayForKey:(NSString *)key {
	if ([key isEqualToString:@"caption"]) {
		return YES;
	} else {
		return [super needsDisplayForKey:key];
	}
}

- (void)drawInContext:(CGContextRef)ctx {
	UIGraphicsPushContext(ctx);
	
	CGRect f = self.bounds;
    CGRect s = f;
    s.origin.y -= 1;
    
    if ( self.shadowEnabled ) {
        [[UIColor blackColor] set];
        [caption drawInRect:f withFont:self.font lineBreakMode:self.lineBreakMode alignment:self.textAlignment];
    }
	
	[[UIColor whiteColor] set];
	[caption drawInRect:s withFont:self.font lineBreakMode:self.lineBreakMode alignment:self.textAlignment];
	
	UIGraphicsPopContext();
}

- (void)dealloc {
    self.font = nil;
    self.caption = nil;
	[super dealloc];
}

@end
