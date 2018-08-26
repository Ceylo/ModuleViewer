//
//  CXXDemangler.m
//  ModuleViewer
//
//  Created by Ceylo on 12/08/2018.
//  Copyright © 2018 Yalir. All rights reserved.
//

#import "CXXDemangler.h"

#include <cxxabi.h>
#include <memory>
#include <string>

namespace {
    using CXADemangleStorage = std::unique_ptr<char, void(*)(void*)>;
    
    CXADemangleStorage DemangleName(const char* name)
    {
        int status = -1;
        
        CXADemangleStorage demangled {
            abi::__cxa_demangle(name, nullptr, nullptr, &status),
            std::free
        };
        
        return demangled;
    }
}

@interface NSString (CXXBridge)
+ (instancetype)stringWithCxxString:(const std::string&)cxxString;
- (std::string)cxxString;
@end

@implementation NSString (CXXBridge)

+ (instancetype)stringWithCxxString:(const std::string&)cxxString
{
    return [NSString stringWithUTF8String: cxxString.c_str()];
}

- (std::string)cxxString
{
    return std::string([self UTF8String],
                       [self lengthOfBytesUsingEncoding:NSUTF8StringEncoding]);
}

@end

NSString* _Nonnull DemangleCXXSymbol(NSString* _Nonnull symbol)
{
    // Workaround, C++ mangled name should have only a single leading _
    // According to https://stackoverflow.com/questions/17572962/gcc-api-unable-to-demangle-its-own-exported-symbols
    // it seems to be an issue with the output of nm
    const char* cString = [symbol UTF8String];
    if ([symbol hasPrefix:@"__"]) {
        cString++;
    }
    
    if (CXADemangleStorage demangled = DemangleName(cString))
        return [NSString stringWithCxxString:demangled.get()];
    else
        return symbol;
}
