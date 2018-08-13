//
//  CXXDemangler.h
//  ModuleViewer
//
//  Created by Ceylo on 12/08/2018.
//  Copyright © 2018 Yalir. All rights reserved.
//

#ifndef CXXDemangler_h
#define CXXDemangler_h

#import <Foundation/Foundation.h>

#ifdef __cplusplus
extern "C" {
#endif
    NSString* _Nonnull DemangleCXXSymbol(NSString* _Nonnull symbol);
#ifdef __cplusplus
}
#endif

#endif /* CXXDemangler_h */
