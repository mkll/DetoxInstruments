//
//  DTXSignpostDataProvider.m
//  DetoxInstruments
//
//  Created by Leo Natan (Wix) on 6/24/18.
//  Copyright © 2018 Wix. All rights reserved.
//

#import "DTXSignpostDataProvider.h"
#import "DTXSignpostSummaryRootProxy.h"
#import "DTXSignpostProtocol.h"
#import "DTXDetailOutlineView.h"
#import "DTXEventInspectorDataProvider.h"
#import "DTXSignpostSample+UIExtensions.h"
#import "DTXSignpostDataExporter.h"

@implementation DTXSignpostDataProvider

+ (Class)inspectorDataProviderClass
{
	return [DTXEventInspectorDataProvider class];
}

- (Class)dataExporterClass
{
	return DTXSignpostDataExporter.class;
}

- (NSString *)displayName
{
	return NSLocalizedString(@"Summary", @"");;
}

- (NSImage *)displayIcon
{
	NSImage* image = [NSImage imageNamed:@"samples_nonflat"];
	image.size = NSMakeSize(16, 16);
	
	return image;
}

- (void)setManagedOutlineView:(NSOutlineView *)managedOutlineView
{
	[self _enableOutlineRespectIfNeededForOutlineView:managedOutlineView];
	
	[super setManagedOutlineView:managedOutlineView];
}

- (void)_enableOutlineRespectIfNeededForOutlineView:(NSOutlineView*)outlineView
{
	if([outlineView respondsToSelector:@selector(setRespectsOutlineCellFraming:)])
	{
		[(DTXDetailOutlineView*)outlineView setRespectsOutlineCellFraming:YES];
	}
}

- (NSArray<DTXColumnInformation *> *)columns
{
	DTXColumnInformation* name = [DTXColumnInformation new];
	name.title = NSLocalizedString(@"Category / Name", @"");
	name.minWidth = 320;
	
	const CGFloat durationMinWidth = 80;
	
	DTXColumnInformation* count = [DTXColumnInformation new];
	count.title = NSLocalizedString(@"Count", @"");
	count.minWidth = 40;
	
	DTXColumnInformation* timestamp = [DTXColumnInformation new];
	timestamp.title = NSLocalizedString(@"Start", @"");
	timestamp.minWidth = durationMinWidth;
	
	DTXColumnInformation* duration = [DTXColumnInformation new];
	duration.title = NSLocalizedString(@"Duration", @"");
	duration.minWidth = durationMinWidth;
	
	DTXColumnInformation* minDuration = [DTXColumnInformation new];
	minDuration.title = NSLocalizedString(@"Min Duration", @"");
	minDuration.minWidth = durationMinWidth;
	
	DTXColumnInformation* avgDuration = [DTXColumnInformation new];
	avgDuration.title = NSLocalizedString(@"Avg Duration", @"");
	avgDuration.minWidth = durationMinWidth;
	
	DTXColumnInformation* maxDuration = [DTXColumnInformation new];
	maxDuration.title = NSLocalizedString(@"Max Duration", @"");
	maxDuration.minWidth = durationMinWidth;
	
	DTXColumnInformation* status = [DTXColumnInformation new];
	status.title = NSLocalizedString(@"Status", @"");
	status.minWidth = 100;
	
	DTXColumnInformation* moreInfo1 = [DTXColumnInformation new];
	moreInfo1.title = NSLocalizedString(@"Additional Info (Start)", @"");
	moreInfo1.minWidth = 320;
	moreInfo1.sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"additionalInfoStart" ascending:YES];
	
	DTXColumnInformation* moreInfo2 = [DTXColumnInformation new];
	moreInfo2.title = NSLocalizedString(@"Additional Info (End)", @"");
	moreInfo2.minWidth = 320;
	moreInfo2.sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"additionalInfoEnd" ascending:YES];
	
	return @[name, count, timestamp, duration, minDuration, avgDuration, maxDuration, status, moreInfo1, moreInfo2];
}

- (Class)sampleClass
{
	return DTXSignpostSample.class;
}

- (NSString*)formattedStringValueForItem:(id)item column:(NSUInteger)column
{
	id<DTXSignpost> signpostSample = item;
	DTXSignpostSample* realSignpostSample = (id)signpostSample;
	
//	if(signpostSample.isExpandable == NO && column != 0 && column != 2 && column != 3 && column != 7)
//	{
//		return @"—";
//	}
	
//	if(signpostSample.isExpandable == YES && column == 7)
//	{
//		return @"—";
//	}
	
	switch (column)
	{
		case 0:
			return signpostSample.name;
		case 1:
			return [NSFormatter.dtx_stringFormatter stringForObjectValue:@(signpostSample.count)];
		case 2:
		{
			NSTimeInterval ti = signpostSample.timestamp.timeIntervalSinceReferenceDate - self.document.firstRecording.startTimestamp.timeIntervalSinceReferenceDate;
			return [[NSFormatter dtx_secondsFormatter] stringForObjectValue:@(ti)];
		}
		case 3:
			if(realSignpostSample.isEvent || realSignpostSample.endTimestamp == nil)
			{
				return @"—";
			}
			return [NSFormatter.dtx_durationFormatter stringFromTimeInterval:signpostSample.duration];
		case 4:
			if(realSignpostSample.isEvent || realSignpostSample.endTimestamp == nil)
			{
				return @"—";
			}
			return [NSFormatter.dtx_durationFormatter stringFromTimeInterval:signpostSample.minDuration];
		case 5:
			if(realSignpostSample.isEvent || realSignpostSample.endTimestamp == nil)
			{
				return @"—";
			}
			return [NSFormatter.dtx_durationFormatter stringFromTimeInterval:signpostSample.avgDuration];
		case 6:
			if(realSignpostSample.isEvent || realSignpostSample.endTimestamp == nil)
			{
				return @"—";
			}
			return [NSFormatter.dtx_durationFormatter stringFromTimeInterval:signpostSample.maxDuration];
		case 7:
			if(realSignpostSample.isExpandable)
			{
				return @"—";
			}
			return realSignpostSample.eventStatusString;
		case 8:
			if(realSignpostSample.isExpandable)
			{
				return @"—";
			}
			return realSignpostSample.additionalInfoStart;
		case 9:
			if(realSignpostSample.isExpandable)
			{
				return @"—";
			}
			return realSignpostSample.additionalInfoEnd;
		default:
			return nil;
	}
}

- (NSColor *)backgroundRowColorForItem:(id)item
{
	DTXSignpostSample* sample = item;
	
	if(sample.eventStatus == DTXEventStatusPrivateError)
	{
		return NSColor.warning3Color;
	}
	
	if(sample.isExpandable == NO && sample.endTimestamp == nil)
	{
		return NSColor.warningColor;
	}
	
	return sample.plotControllerColor;
}

- (NSString*)statusTooltipforItem:(id)item
{
	DTXSignpostSample* sample = item;
	
	if(sample.eventStatus == DTXEventStatusPrivateError)
	{
		return NSLocalizedString(@"Event error", @"");
	}
	
	if(sample.isExpandable == NO && sample.endTimestamp == nil)
	{
		return NSLocalizedString(@"Incomplete event", @"");
	}
	
	return nil;
}

- (BOOL)supportsDataFiltering
{
	return YES;
}

- (BOOL)supportsSorting
{
	return NO;
}

- (NSArray<NSString *> *)filteredAttributes
{
	return @[@"category", @"name", @"additionalInfoStart", @"additionalInfoEnd"];
}

- (DTXSampleContainerProxy *)rootSampleContainerProxy
{
	return [[DTXSignpostSummaryRootProxy alloc] initWithManagedObjectContext:self.document.firstRecording.managedObjectContext outlineView:self.managedOutlineView];
}

- (BOOL)showsTimestampColumn
{
	return NO;
}

@end
