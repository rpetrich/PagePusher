#import <UIKit/UIKit.h>

// Hook present/dismiss modal view controller

%hook UIViewController

- (int)_transitionForModalTransitionStyle:(UIModalTransitionStyle)modalTransitionStyle appearing:(BOOL)appearing
{
	switch (modalTransitionStyle) {
		case UIModalTransitionStyleCoverVertical:
			%orig;
			return appearing ? 13 : 14; // Page Curl
			//return appearing ? 10 : 11; // Flip
			//return appearing ? 8 : 9; // Normal
		default:
			return %orig;
	}
}

%end

// Push/pop on navigation controller

%hook UINavigationController

- (NSTimeInterval)navigationTransitionView:(id)navigationTransitionView durationForTransition:(NSInteger)transition
{
	switch (transition) {
		case 5: // Push from right
		case 6: // Push from left
			%orig;
			return 2.0 / 3.0;
		default:
			return %orig;
	}
}

%end

static NSInteger pushCurl;

%hook UINavigationTransitionView

- (BOOL)transition:(NSInteger)transition fromView:(UIView *)fromView toView:(UIView *)toView
{
	switch (transition) {
		case 0: // None
			break;
		case 1: // Push from right
			transition = 6;
			pushCurl++;
			break;
		case 2: // Push from left
			transition = 5;
			pushCurl++;
			break;
	}
	return %orig;
}

%end

%hook UIView

+ (void)setAnimationTransition:(UIViewAnimationTransition)transition forView:(UIView *)view cache:(BOOL)cache
{
	if (pushCurl) {
		switch (transition) {
			case UIViewAnimationTransitionFlipFromLeft:
				transition = UIViewAnimationTransitionCurlUp;
				break;
			case UIViewAnimationTransitionFlipFromRight:
				transition = UIViewAnimationTransitionCurlDown;
				break;
			default:
				break;
		}
		pushCurl--;
	}
	%orig;
}

%end
