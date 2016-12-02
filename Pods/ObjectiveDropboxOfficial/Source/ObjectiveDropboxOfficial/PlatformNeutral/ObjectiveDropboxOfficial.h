//
//  ObjectiveDropboxOfficial.h
//  ObjectiveDropboxOfficial
//
//  Copyright © 2016 Dropbox. All rights reserved.
//

#import "TargetConditionals.h"

#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#else
#import <Cocoa/Cocoa.h>
#endif

//! Project version number for ObjectiveDropboxOfficial.
FOUNDATION_EXPORT double ObjectiveDropboxOfficialVersionNumber;

//! Project version string for ObjectiveDropboxOfficial.
FOUNDATION_EXPORT const unsigned char ObjectiveDropboxOfficialVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import
// <ObjectiveDropboxOfficial/PublicHeader.h>

#if TARGET_OS_IPHONE
#import <ObjectiveDropboxOfficial/DropboxSDKImportsMobile.h>
#else
#import <ObjectiveDropboxOfficial/DropboxSDKImportsDesktop.h>
#endif
