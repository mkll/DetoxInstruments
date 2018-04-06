//
//  DTXFileSystemItem.m
//  DTXProfiler
//
//  Created by Leo Natan (Wix) on 3/29/18.
//  Copyright © 2018 Wix. All rights reserved.
//

#import "DTXFileSystemItem.h"

#if __has_include("DTXZipper.h")
#import "DTXZipper.h"
#endif

@implementation DTXFileSystemItem

+ (BOOL)supportsSecureCoding
{
	return YES;
}

- (instancetype)initWithFileURL:(NSURL *)fileURL
{
	self = [super init];
	
	if(self)
	{
		NSArray<NSURLResourceKey>* propKeys = @[NSURLIsDirectoryKey, NSURLNameKey, NSURLTotalFileSizeKey];
		NSDictionary<NSURLResourceKey, id>* properties = [fileURL resourceValuesForKeys:propKeys error:NULL];
		
		_isDirectory = [properties[NSURLIsDirectoryKey] boolValue];
		self.name = properties[NSURLNameKey];
		self.size = properties[NSURLTotalFileSizeKey];
		self.URL = fileURL;
		
		if([properties[NSURLIsDirectoryKey] boolValue])
		{
			NSArray<NSURL*>* childURLs = [[[NSFileManager defaultManager] contentsOfDirectoryAtURL:self.URL includingPropertiesForKeys:propKeys options:NSDirectoryEnumerationSkipsSubdirectoryDescendants | NSDirectoryEnumerationSkipsPackageDescendants | NSDirectoryEnumerationSkipsHiddenFiles error:NULL] sortedArrayUsingComparator:^NSComparisonResult(NSURL* _Nonnull obj1, NSURL* _Nonnull obj2) {
				
				NSString* val1;
				NSString* val2;
				
				[obj1 getResourceValue:&val1 forKey:NSURLNameKey error:NULL];
				[obj2 getResourceValue:&val2 forKey:NSURLNameKey error:NULL];
				
				return [val1 compare:val2 options:(NSCaseInsensitiveSearch)];
			}];
			
			NSMutableArray* children = [NSMutableArray new];
			
			[childURLs enumerateObjectsUsingBlock:^(NSURL * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
				DTXFileSystemItem* child = [[DTXFileSystemItem alloc] initWithFileURL:obj];
				[children addObject:child];
			}];
			
			self.children = children;
		}
		else
		{
			self.children = nil;
		}
	}
	
	return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
	self = [super init];
	
	if(self)
	{
		_isDirectory = [aDecoder decodeBoolForKey:@"isDirectory"];
		self.name = [aDecoder decodeObjectForKey:@"name"];
		self.size = [aDecoder decodeObjectForKey:@"size"];
		self.URL = [aDecoder decodeObjectForKey:@"URL"];
		self.children = [aDecoder decodeObjectForKey:@"children"];
	}
	
	return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
	[aCoder encodeBool:_isDirectory forKey:@"isDirectory"];
	[aCoder encodeObject:self.name forKey:@"name"];
	[aCoder encodeObject:self.size forKey:@"size"];
	[aCoder encodeObject:self.URL forKey:@"URL"];
	[aCoder encodeObject:self.children forKey:@"children"];
}

- (BOOL)isDirectory
{
	return _isDirectory && [self.name.pathExtension isEqualToString:@"dtxprof"] == NO;
}

- (NSString*)description
{
	return [NSString stringWithFormat:@"<%@: %p [%@] name: %@, size: %@>", self.class, self, self.isDirectory ? @"D" : @"F", self.name, self.size == nil ? @"--" : [NSByteCountFormatter stringFromByteCount:self.size.unsignedIntegerValue countStyle:NSByteCountFormatterCountStyleFile]];
}

- (NSData*)zipContents
{
#if __has_include("DTXZipper.h")
	NSURL* tempFileURL = [[NSURL fileURLWithPath:NSTemporaryDirectory() isDirectory:YES] URLByAppendingPathComponent:@".containerContents.zip"];	
	DTXWriteZipFileWithDirectoryContents(tempFileURL, self.URL);
	
	NSData* data = [NSData dataWithContentsOfURL:tempFileURL];
	
	[[NSFileManager defaultManager] removeItemAtURL:tempFileURL error:NULL];
	
	return data;
#else
	return nil;
#endif
}

@end