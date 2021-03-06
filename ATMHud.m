/*
 *  ATMHud.m
 *  ATMHud
 *
 *  Created by Marcel Müller on 2011-03-01.
 *  Copyright (c) 2010-2011, Marcel Müller (atomcraft)
 *  All rights reserved.
 *
 *	https://github.com/atomton/ATMHud
 */

#import "ATMHud.h"
#import <QuartzCore/QuartzCore.h>
#import <AudioToolbox/AudioServices.h>
#import "ATMHudView.h"
#import "ATMProgressLayer.h"
#import "ATMHudDelegate.h"
#import "ATMSoundFX.h"
#import "ATMHudQueueItem.h"
#import "ATMTextLayer.h"

@interface ATMHud (Private)
- (void)construct;
@end

@implementation ATMHud
@synthesize margin, padding, alpha, appearScaleFactor, disappearScaleFactor, progressBorderRadius, progressBorderWidth, progressBarRadius, progressBarInset;
@synthesize accessoryPosition;
@synthesize center;
@synthesize shadowEnabled, blockTouches, allowSuperviewInteraction;
@synthesize showSound, updateSound, hideSound;
@synthesize __view, sound, displayQueue, queuePosition;

+ (ATMHud *)hudForThinLargeTextFullScreenOnView:(UIView *)targetView withDelegate:(id)hudDelegate;
{
    ATMHud* hud = [[ATMHud alloc] initWithDelegate:hudDelegate];
    [targetView addSubview:hud.view];
    [hud setMargin:2.f];
    [hud setPadding:2.f];
    [hud.__view.captionLayer setShadowEnabled:NO];
    [hud.__view.captionLayer setFont:[UIFont fontWithName:@"AvenirNextCondensed-UltraLight" size:80.f]];
    //[hud.__view.captionLayer setFont:[UIFont boldSystemFontOfSize:62.f]];
    [hud.__view.backgroundLayer setBackgroundColor:[UIColor clearColor].CGColor];
    [hud setFixedSize:targetView.frame.size];
    [hud setShadowEnabled:NO];
    
    [hud setBlockTouches:NO];
    return hud;
}

+ (ATMHud *)hudForMediumTextFullScreenOnView:(UIView *)targetView withDelegate:(id)hudDelegate;
{
    ATMHud* hud = [[ATMHud alloc] initWithDelegate:hudDelegate];
    [targetView addSubview:hud.view];
    [hud.__view.captionLayer setShadowEnabled:NO];
    [hud.__view.captionLayer setFont:[UIFont fontWithName:@"AvenirNext-Medium" size:62.f]];
    //[hud.__view.captionLayer setFont:[UIFont boldSystemFontOfSize:62.f]];
    [hud.__view.backgroundLayer setBackgroundColor:[UIColor clearColor].CGColor];
    [hud setFixedSize:targetView.frame.size];
    [hud setShadowEnabled:NO];
    
    [hud setBlockTouches:NO];
    return hud;
}

- (id)init {
	if ((self = [super init])) {
		[self construct];
	}
	return self;
}

- (id)initWithDelegate:(id)hudDelegate {
	if ((self = [super init])) {
		_delegate = hudDelegate;
		[self construct];
	}
	return self;
}

- (void)releaseAll {
    [self.__view setP:nil];
    [self.__view removeFromSuperview];
    self.__view = nil;
    
    [self.view removeFromSuperview];
    self.view = nil;
    
    [self removeFromParentViewController];
    [self setDelegate:nil];
}

- (BOOL)isDone {
    return [self isDoneWithDoneString:NSLocalizedString(@"Done", nil)];
}

- (BOOL)isDoneWithDoneString:(NSString*)doneString {
    return ( self.__view.progress == 0.f && self.__view.showActivity == NO && [self.__view.caption isEqualToString:doneString] );
}

- (void)loadView {
	UIView *base = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	base.backgroundColor = [UIColor clearColor];
	base.autoresizingMask = (UIViewAutoresizingFlexibleWidth |
							 UIViewAutoresizingFlexibleHeight);
	base.userInteractionEnabled = NO;
	[base addSubview:__view];
	
	self.view = base;
#if __has_feature(objc_arc)
    base = nil;
#else
	[base release];
#endif
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

- (void)dealloc {
#if __has_feature(objc_arc)
    sound = nil;
    __view = nil;
    displayQueue = nil;
	
    showSound = nil;
    updateSound = nil;
    hideSound = nil;
    
    self.delegate = nil;
	
    NSLog(@"ATMHud dealloc ~~~~~~ : %@", self);
#else
	[sound release]; sound = nil;
	[__view release]; __view = nil;
	[displayQueue release]; displayQueue = nil;
	
	[showSound release]; showSound = nil;
	[updateSound release]; updateSound = nil;
	[hideSound release]; hideSound = nil;
    
    self.delegate = nil;
	
    NSLog(@"ATMHud dealloc ~~~~~~ : %@", self);
    
    [super dealloc];
#endif
}

+ (NSString *)buildInfo {
	return @"atomHUD 1.2 • 2011-03-01";
}

#pragma mark -
#pragma mark Overrides
- (void)setAppearScaleFactor:(CGFloat)value {
	if (value == 0) {
		value = 0.01;
	}
	appearScaleFactor = value;
}

- (void)setDisappearScaleFactor:(CGFloat)value {
	if (value == 0) {
		value = 0.01;
	}
	disappearScaleFactor = value;
}

- (void)setAlpha:(CGFloat)value {
	alpha = value;
	[CATransaction begin];
	[CATransaction setDisableActions:YES];
	__view.backgroundLayer.backgroundColor = [UIColor colorWithWhite:0.0 alpha:value].CGColor;
	[CATransaction commit];
}

- (void)setShadowEnabled:(BOOL)value {
	shadowEnabled = value;
	if (shadowEnabled) {
		__view.layer.shadowOpacity = 0.4;
	} else {
		__view.layer.shadowOpacity = 0.0;
	}
}

#pragma mark -
#pragma mark Property forwards
- (void)setCaption:(NSString *)caption {
	__view.caption = caption;
}

- (void)setImage:(UIImage *)image {
	__view.image = image;
}

- (void)setActivity:(BOOL)activity {
	__view.showActivity = activity;
	if (activity) {
		[__view.activity startAnimating];
	} else {
		[__view.activity stopAnimating];
	}
}

- (void)setActivityStyle:(UIActivityIndicatorViewStyle)activityStyle {
	__view.activityStyle = activityStyle;
	if (activityStyle == UIActivityIndicatorViewStyleWhiteLarge) {
		__view.activitySize = CGSizeMake(37, 37);
	} else {
		__view.activitySize = CGSizeMake(20, 20);
	}
}

- (void)setFixedSize:(CGSize)fixedSize {
	__view.fixedSize = fixedSize;
}

- (void)setProgress:(CGFloat)progress {
	__view.progress = progress;
	
	[__view.progressLayer setTheProgress:progress];
	[__view.progressLayer setNeedsDisplay];
}

#pragma mark -
#pragma mark Queue
- (void)addQueueItem:(ATMHudQueueItem *)item {
	[displayQueue addObject:item];
}

- (void)addQueueItems:(NSArray *)items {
	[displayQueue addObjectsFromArray:items];
}

- (void)clearQueue {
	[displayQueue removeAllObjects];
}

- (void)startQueue {
	queuePosition = 0;
	if (!CGSizeEqualToSize(__view.fixedSize, CGSizeZero)) {
		CGSize newSize = __view.fixedSize;
		CGSize targetSize;
		ATMHudQueueItem *queueItem;
		for (int i = 0; i < [displayQueue count]; i++) {
			queueItem = [displayQueue objectAtIndex:i];
			
			targetSize = [__view calculateSizeForQueueItem:queueItem];
			if (targetSize.width > newSize.width) {
				newSize.width = targetSize.width;
			}
			if (targetSize.height > newSize.height) {
				newSize.height = targetSize.height;
			}
		}
		[self setFixedSize:newSize];
	}
	[self showQueueAtIndex:queuePosition];
}

- (void)showNextInQueue {
	queuePosition++;
	[self showQueueAtIndex:queuePosition];
}

- (void)showQueueAtIndex:(NSInteger)index {
	if ([displayQueue count] > 0) {
		queuePosition = index;
		if (queuePosition == [displayQueue count]) {
			[self hide];
			return;
		}
		ATMHudQueueItem *item = [displayQueue objectAtIndex:queuePosition];
		
		__view.caption = item.caption;
		__view.image = item.image;
		
		BOOL flag = item.showActivity;
		__view.showActivity = flag;
		if (flag) {
			[__view.activity startAnimating];
		} else {
			[__view.activity stopAnimating];
		}
		
		self.accessoryPosition = item.accessoryPosition;
		[self setActivityStyle:item.activityStyle];
		
		if (queuePosition == 0) {
			[__view show];
		} else {
			[__view update];
		}
	}
}

#pragma mark -
#pragma mark Controlling
- (void)show {
	[__view show];
}

- (void)update {
	[__view update];
    
    self.view.frame = CGRectMake(0.f, 0.f, self.view.superview.frame.size.width, self.view.superview.frame.size.height);
}

- (void)hide {
	[__view hide];
}

- (void)hideAfter:(NSTimeInterval)delay {
	[self performSelector:@selector(hide) withObject:nil afterDelay:delay];
}

#pragma mark -
#pragma mark Internal methods
- (void)construct {
    NSLog(@"ATMHud constructing ~~~~~~ : %@", self);
	margin = padding = 10.0;
	alpha = 0.7;
	progressBorderRadius = 8.0;
	progressBorderWidth = 2.0;
	progressBarRadius = 5.0;
	progressBarInset = 3.0;
	accessoryPosition = ATMHudAccessoryPositionBottom;
	appearScaleFactor = disappearScaleFactor = 1.4;
	
	__view = [[ATMHudView alloc] initWithFrame:CGRectZero andController:self];
	__view.autoresizingMask = (UIViewAutoresizingFlexibleTopMargin |
							   UIViewAutoresizingFlexibleRightMargin |
							   UIViewAutoresizingFlexibleBottomMargin |
							   UIViewAutoresizingFlexibleLeftMargin);
	
	displayQueue = [[NSMutableArray alloc] init];
	queuePosition = 0;
	center = CGPointZero;
	blockTouches = NO;
	allowSuperviewInteraction = NO;
    self.animate = YES;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	if (!blockTouches) {
		UITouch *aTouch = [touches anyObject];
		if (aTouch.tapCount == 1) {
			CGPoint p = [aTouch locationInView:self.view];
			if (CGRectContainsPoint(__view.frame, p)) {
				if ([(id)self.delegate respondsToSelector:@selector(userDidTapHud:)]) {
					[self.delegate userDidTapHud:self];
				}
			}
		}
	}
}

- (void)playSound:(NSString *)soundPath {
	sound = [[ATMSoundFX alloc] initWithContentsOfFile:soundPath];
	[sound play];
}

@end
