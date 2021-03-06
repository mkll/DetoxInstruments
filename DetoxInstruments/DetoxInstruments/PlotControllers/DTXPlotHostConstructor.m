//
//  DTXPlotHostConstructor.m
//  DetoxInstruments
//
//  Created by Leo Natan (Wix) on 4/26/18.
//  Copyright © 2017-2019 Wix. All rights reserved.
//

#import "DTXPlotHostConstructor.h"

@implementation DTXPlotHostConstructor

@dynamic requiredHeight;

- (instancetype)initForTouchBar:(BOOL)isForTouchBar
{
	self = [super init];
	
	if(self)
	{
		_isForTouchBar = isForTouchBar;
	}
	
	return self;
}


- (void)setUpWithView:(NSView *)view
{
	[self setUpWithView:view insets:NSEdgeInsetsMake(0, 0, 0, 0)];
}

- (void)setUpWithView:(NSView *)view insets:(NSEdgeInsets)insets
{
	if(_wrapperView)
	{
		[_wrapperView removeFromSuperview];
		_wrapperView.frame = view.bounds;
	}
	else
	{
		_wrapperView = [DTXLayerView new];
		_wrapperView.translatesAutoresizingMaskIntoConstraints = NO;
		
		BOOL usesInternalPlots = self.usesInternalPlots;
		
		if(usesInternalPlots)
		{
			_plotStackView = [DTXPlotStackView new];
			_plotStackView.translatesAutoresizingMaskIntoConstraints = NO;
			_plotStackView.orientation = NSUserInterfaceLayoutOrientationVertical;
			_plotStackView.distribution = NSStackViewDistributionFillEqually;
			_plotStackView.spacing = 0;
			
			[_plotStackView setContentCompressionResistancePriority:NSLayoutPriorityRequired forOrientation:NSLayoutConstraintOrientationVertical];
			[_plotStackView setContentHuggingPriority:NSLayoutPriorityRequired forOrientation:NSLayoutConstraintOrientationVertical];
			
			if(_isForTouchBar)
			{
				[NSLayoutConstraint activateConstraints:@[
														  [_plotStackView.heightAnchor constraintEqualToConstant:30],
														  ]];
			}
			
			[_wrapperView addSubview:_plotStackView];
			
			[NSLayoutConstraint activateConstraints:@[
													  [_wrapperView.topAnchor constraintEqualToAnchor:_plotStackView.topAnchor],
													  [_wrapperView.leadingAnchor constraintEqualToAnchor:_plotStackView.leadingAnchor],
													  [_wrapperView.trailingAnchor constraintEqualToAnchor:_plotStackView.trailingAnchor],
													  [_wrapperView.bottomAnchor constraintEqualToAnchor:_plotStackView.bottomAnchor],
													  ]];
			
			[self setupPlotViews];
		}
		else
		{
			_hostingView = [[_isForTouchBar ? DTXTouchBarGraphHostingView.class : DTXGraphHostingView.class alloc] initWithFrame:view.bounds];
			_hostingView.translatesAutoresizingMaskIntoConstraints = NO;
			
			_graph = [[CPTXYGraph alloc] initWithFrame:_hostingView.bounds];
			
			_graph.paddingLeft = 0;
			_graph.paddingTop = 0;
			_graph.paddingRight = 0;
			_graph.paddingBottom = 0;
			_graph.masksToBorder  = NO;
			_graph.backgroundColor = _isForTouchBar ? NSColor.gridColor.CGColor : NSColor.clearColor.CGColor;
			
			[self setupPlotsForGraph];
			
			self.graph.plotAreaFrame.masksToBorder = NO;
			
			[self.graph.allPlots enumerateObjectsUsingBlock:^(__kindof CPTPlot * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
				obj.backgroundColor = _isForTouchBar ? NSColor.blackColor.CGColor : NSColor.clearColor.CGColor;
			}];
			
			_hostingView.hostedGraph = _graph;
			
			_hostingView.layer.backgroundColor = NSColor.redColor.CGColor;
			
			[_wrapperView addSubview:_hostingView];
			
			[NSLayoutConstraint activateConstraints:@[
													  [_hostingView.heightAnchor constraintEqualToConstant:self.requiredHeight],
													  [_wrapperView.topAnchor constraintEqualToAnchor:_hostingView.topAnchor],
													  [_wrapperView.leadingAnchor constraintEqualToAnchor:_hostingView.leadingAnchor],
													  [_wrapperView.trailingAnchor constraintEqualToAnchor:_hostingView.trailingAnchor],
													  [_wrapperView.bottomAnchor constraintEqualToAnchor:_hostingView.bottomAnchor],
													  ]];
		}
	}
	
	[view addSubview:_wrapperView];
	
	[NSLayoutConstraint activateConstraints:@[
											  [view.topAnchor constraintEqualToAnchor:_wrapperView.topAnchor constant:-insets.top],
											  [view.leadingAnchor constraintEqualToAnchor:_wrapperView.leadingAnchor constant:-insets.left],
											  [view.trailingAnchor constraintEqualToAnchor:_wrapperView.trailingAnchor constant:insets.right],
											  [view.bottomAnchor constraintEqualToAnchor:_wrapperView.bottomAnchor constant:insets.bottom]
											  ]];
	
	[self didFinishViewSetup];
}

- (BOOL)usesInternalPlots
{
	return YES;
}

- (void)setupPlotViews
{
	
}

- (void)setupPlotsForGraph
{
	
}

- (void)dealloc
{
	[_hostingView removeFromSuperview];
	[_wrapperView removeFromSuperview];
}

- (void)didFinishViewSetup
{
	
}

@end
