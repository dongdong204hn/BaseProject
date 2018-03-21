/*
 *  wax_instance.c
 *  Lua
 *
 *  Created by ProbablyInteractive on 5/18/09.
 *  Copyright 2009 Probably Interactive. All rights reserved.
 *
 */

#import "wax_instance.h"
#import "wax_class.h"
#import "wax.h"
#import "wax_helpers.h"

#import "lauxlib.h"
#import "lobject.h"

#import "LDAOPAspect.h"


static int __index(lua_State *L);
static int __newindex(lua_State *L);
static int __gc(lua_State *L);
static int __tostring(lua_State *L);
static int __eq(lua_State *L);

static int methods(lua_State *L);

static int methodClosure(lua_State *L);
static int superMethodClosure(lua_State *L);
static int customInitMethodClosure(lua_State *L);

static BOOL overrideMethod(lua_State *L, wax_instance_userdata *instanceUserdata);
static int pcallUserdata(lua_State *L, id self, SEL selector, va_list args);

static const struct luaL_Reg metaFunctions[] = {{"__index", __index},
                                                {"__newindex", __newindex},
                                                {"__gc", __gc},
                                                {"__tostring", __tostring},
                                                {"__eq", __eq},
                                                {NULL, NULL}};

static const struct luaL_Reg functions[] = {{"methods", methods}, {NULL, NULL}};

int luaopen_wax_instance(lua_State *L)
{
    BEGIN_STACK_MODIFY(L);

    luaL_newmetatable(L, WAX_INSTANCE_METATABLE_NAME);
    luaL_register(L, NULL, metaFunctions);
    luaL_register(L, WAX_INSTANCE_METATABLE_NAME, functions);

    END_STACK_MODIFY(L, 0)

    return 1;
}


#pragma mark -
#pragma mark - Instance Utils

// Creates userdata object for obj-c instance/class and pushes it onto the stack
wax_instance_userdata *wax_instance_create(lua_State *L, id instance, BOOL isClass)
{
    BEGIN_STACK_MODIFY(L)

    // Does user data already exist?
    wax_instance_pushUserdata(L, instance);

    if (lua_isnil(L, -1)) {
        // wax_log(LOG_GC, @"Creating %@ for %@(%p)", isClass ? @"class" : @"instance", [instance
        // class], instance);
        lua_pop(L, 1);  // pop nil stack
    } else {
        // wax_log(LOG_GC, @"Found existing userdata %@ for %@(%p)", isClass ? @"class" :
        // @"instance", [instance class], instance);
        return lua_touserdata(L, -1);
    }

    size_t nbytes = sizeof(wax_instance_userdata);
    wax_instance_userdata *instanceUserdata = (wax_instance_userdata *)lua_newuserdata(L, nbytes);
    instanceUserdata->instance = instance;
    instanceUserdata->isClass = isClass;
    instanceUserdata->isSuper = nil;
    instanceUserdata->actAsSuper = NO;

    if (!isClass) {
        // wax_log(LOG_GC, @"Retaining %@ for %@(%p -> %p)", isClass ? @"class" : @"instance",
        // [instance class], instance, instanceUserdata);
        [instanceUserdata->instance retain];
    }

    // set the metatable
    luaL_getmetatable(L, WAX_INSTANCE_METATABLE_NAME);
    lua_setmetatable(L, -2);

    // give it a nice clean environment
    lua_newtable(L);
    lua_setfenv(L, -2);

    wax_instance_pushUserdataTable(L);

    // register the userdata table in the metatable (so we can access it from obj-c)
    // wax_log(LOG_GC, @"Storing reference of %@ to userdata table %@(%p -> %p)", isClass ? @"class"
    // : @"instance", [instance class], instance, instanceUserdata);
    lua_pushlightuserdata(L, instanceUserdata->instance);
    lua_pushvalue(L, -3);  // Push userdata
    lua_rawset(L, -3);

    lua_pop(L, 1);  // Pop off userdata table


    wax_instance_pushStrongUserdataTable(L);
    lua_pushlightuserdata(L, instanceUserdata->instance);
    lua_pushvalue(L, -3);  // Push userdata
    lua_rawset(L, -3);

    // wax_log(LOG_GC, @"Storing reference to strong userdata table %@(%p -> %p)", [instance class],
    // instance, instanceUserdata);

    lua_pop(L, 1);  // Pop off strong userdata table

    END_STACK_MODIFY(L, 1)

    return instanceUserdata;
}

// Creates pseudo-super userdata object for obj-c instance and pushes it onto the stack
wax_instance_userdata *wax_instance_createSuper(lua_State *L,
                                                wax_instance_userdata *instanceUserdata)
{
    BEGIN_STACK_MODIFY(L)

    size_t nbytes = sizeof(wax_instance_userdata);
    wax_instance_userdata *superInstanceUserdata =
        (wax_instance_userdata *)lua_newuserdata(L, nbytes);
    superInstanceUserdata->instance = instanceUserdata->instance;
    superInstanceUserdata->isClass = instanceUserdata->isClass;
    superInstanceUserdata->actAsSuper = YES;

    // isSuper not only stores whether the class is a super, but it also contains the value of the
    // next superClass
    if (instanceUserdata->isSuper) {
        superInstanceUserdata->isSuper = [instanceUserdata->isSuper superclass];
    } else {
        superInstanceUserdata->isSuper = [instanceUserdata->instance superclass];
    }


    // set the metatable
    luaL_getmetatable(L, WAX_INSTANCE_METATABLE_NAME);
    lua_setmetatable(L, -2);

    wax_instance_pushUserdata(L, instanceUserdata->instance);
    if (lua_isnil(L, -1)) {  // instance has no lua object, push empty env table (This shouldn't
                             // happen, tempted to remove it)
        lua_pop(L, 1);       // Remove nil and superclass userdata
        lua_newtable(L);
    } else {
        lua_getfenv(L, -1);
        lua_remove(L, -2);  // Remove nil and superclass userdata
    }

    // Give it the instance's metatable
    lua_setfenv(L, -2);

    END_STACK_MODIFY(L, 1)

    return superInstanceUserdata;
}

// The userdata table holds weak references too all the instance userdata
// created. This is used to manage all instances of Objective-C objects created
// via Lua so we can release/gc them when both Lua and Objective-C are finished with
// them.
void wax_instance_pushUserdataTable(lua_State *L)
{
    BEGIN_STACK_MODIFY(L)
    static const char *userdataTableName = "__wax_userdata";
    luaL_getmetatable(L, WAX_INSTANCE_METATABLE_NAME);
    lua_getfield(L, -1, userdataTableName);

    if (lua_isnil(L, -1)) {  // Create new userdata table, add it to metatable
        lua_pop(L, 1);       // Remove nil

        lua_pushstring(L, userdataTableName);  // Table name
        lua_newtable(L);
        lua_rawset(L, -3);  // Add userdataTableName table to WAX_INSTANCE_METATABLE_NAME
        lua_getfield(L, -1, userdataTableName);

        lua_pushvalue(L, -1);
        lua_setmetatable(L, -2);  // userdataTable is it's own metatable

        lua_pushstring(L, "v");
        lua_setfield(L, -2, "__mode");  // Make weak table
    }

    END_STACK_MODIFY(L, 1)
}

// Holds strong references to userdata created by wax... if the retain count dips below
// 2, then we can remove it because we know obj-c doesn't care about it anymore
void wax_instance_pushStrongUserdataTable(lua_State *L)
{
    BEGIN_STACK_MODIFY(L)
    static const char *userdataTableName = "__wax_strong_userdata";
    luaL_getmetatable(L, WAX_INSTANCE_METATABLE_NAME);
    lua_getfield(L, -1, userdataTableName);

    if (lua_isnil(L, -1)) {  // Create new userdata table, add it to metatable
        lua_pop(L, 1);       // Remove nil

        lua_pushstring(L, userdataTableName);  // Table name
        lua_newtable(L);
        lua_rawset(L, -3);  // Add userdataTableName table to WAX_INSTANCE_METATABLE_NAME
        lua_getfield(L, -1, userdataTableName);
    }

    END_STACK_MODIFY(L, 1)
}


// First look in the object's userdata for the function, then look in the object's class's userdata
BOOL wax_instance_pushFunction(lua_State *L, id self, SEL selector)
{
    BEGIN_STACK_MODIFY(L)

    wax_instance_pushUserdata(L, self);
    if (lua_isnil(L, -1)) {
        END_STACK_MODIFY(L, 0)
        return NO;  // userdata doesn't exist
    }

    lua_getfenv(L, -1);
    wax_pushMethodNameFromSelector(L, selector);
    lua_rawget(L, -2);

    BOOL result = YES;

    if (!lua_isfunction(L, -1)) {    // function not found in userdata
        lua_pop(L, 3);               // Remove userdata, env and non-function
        if ([self class] == self) {  // This is a class, not an instance
            // Check to see if the super classes know about this function
            result = wax_instance_pushFunction(L, [self superclass], selector);
        } else {
            result = wax_instance_pushFunction(L, [self class], selector);
        }
    }

    END_STACK_MODIFY(L, 1)

    return result;
}

// Retrieves associated userdata for an object from the wax instance userdata table
void wax_instance_pushUserdata(lua_State *L, id object)
{
    BEGIN_STACK_MODIFY(L);

    wax_instance_pushUserdataTable(L);
    lua_pushlightuserdata(L, object);
    lua_rawget(L, -2);
    lua_remove(L, -2);  // remove userdataTable


    END_STACK_MODIFY(L, 1)
}

BOOL wax_instance_isWaxClass(id instance)
{
    // If this is a wax class, or an instance of a wax class, it has the userdata ivar set
    return (class_getVersion([instance class]) == WAX_CLASS_VERSION);
}


#pragma mark -
#pragma mark - Override Metatable Functions

static int __index(lua_State *L)
{
    wax_instance_userdata *instanceUserdata =
        (wax_instance_userdata *)luaL_checkudata(L, 1, WAX_INSTANCE_METATABLE_NAME);

    if (lua_isstring(L, 2) && strcmp("super", lua_tostring(L, 2)) == 0) {  // call to super!
        wax_instance_createSuper(L, instanceUserdata);
        return 1;
    }

    // Check instance userdata, unless we are acting like a super
    if (!instanceUserdata->actAsSuper) {
        lua_getfenv(L, -2);
        lua_pushvalue(L, -2);
        lua_rawget(L, 3);
    } else {
        lua_pushnil(L);
    }

    // Check instance's class userdata, or if it is a super, check the super's class data
    Class classToCheck = instanceUserdata->actAsSuper ? instanceUserdata->isSuper
                                                      : [instanceUserdata->instance class];
    while (lua_isnil(L, -1) && wax_instance_isWaxClass(classToCheck)) {
        // Keep checking superclasses if they are waxclasses, we want to treat those like they are
        // lua
        lua_pop(L, 1);
        wax_instance_pushUserdata(L, classToCheck);

        // If there is no userdata for this instance's class, then leave the nil on the stack and
        // don't anything else
        if (!lua_isnil(L, -1)) {
            lua_getfenv(L, -1);
            lua_pushvalue(L, 2);
            lua_rawget(L, -2);
            lua_remove(L, -2);  // Get rid of the userdata env
            lua_remove(L, -2);  // Get rid of the userdata
        }

        classToCheck = class_getSuperclass(classToCheck);
    }

    // If we are calling a super class, or if we couldn't find the index in the userdata environment
    // table, assume it is defined in obj-c classes
    if (lua_isnil(L, -1)) {
        SEL foundSelectors[2] = {nil, nil};
        BOOL foundSelector =
            wax_selectorForInstance(instanceUserdata, foundSelectors, lua_tostring(L, 2), NO);

        if (foundSelector) {  // If the class has a method with this name, push as a closure
            lua_pushstring(L, sel_getName(foundSelectors[0]));
            foundSelectors[1] ? lua_pushstring(L, sel_getName(foundSelectors[1])) : lua_pushnil(L);
            lua_pushcclosure(L, instanceUserdata->actAsSuper ? superMethodClosure : methodClosure,
                             2);
        }
    } else if (!instanceUserdata->isSuper && instanceUserdata->isClass &&
               wax_isInitMethod(lua_tostring(L, 2))) {  // Is this an init method create in lua?
        lua_pushcclosure(L, customInitMethodClosure, 1);
    }

    // Always reset this, an object only acts like a super ONE TIME!
    instanceUserdata->actAsSuper = NO;

    return 1;
}

static int __newindex(lua_State *L)
{
    wax_instance_userdata *instanceUserdata =
        (wax_instance_userdata *)luaL_checkudata(L, 1, WAX_INSTANCE_METATABLE_NAME);

    // If this already exists in a protocol, or superclass make sure it will call the lua functions
    if (instanceUserdata->isClass && lua_type(L, 3) == LUA_TFUNCTION) {
        overrideMethod(L, instanceUserdata);
    }

    // Add value to the userdata's environment table
    lua_getfenv(L, 1);
    lua_insert(L, 2);
    lua_rawset(L, 2);

    return 0;
}

static int __gc(lua_State *L)
{
    wax_instance_userdata *instanceUserdata =
        (wax_instance_userdata *)luaL_checkudata(L, 1, WAX_INSTANCE_METATABLE_NAME);

    // wax_log(LOG_GC, @"Releasing %@ %@(%p)", instanceUserdata->isClass ? @"Class" : @"Instance",
    // [instanceUserdata->instance class], instanceUserdata->instance);

    if (!instanceUserdata->isClass && !instanceUserdata->isSuper) {
        // This seems like a stupid hack. But...
        // If we want to call methods on an object durring gc, we have to readd
        // the instance/userdata to the userdata table. Why? Because it is
        // removed from the weak table before GC is called.
        wax_instance_pushUserdataTable(L);
        lua_pushlightuserdata(L, instanceUserdata->instance);
        lua_pushvalue(L, -3);
        lua_rawset(L, -3);

        [instanceUserdata->instance release];

        lua_pushlightuserdata(L, instanceUserdata->instance);
        lua_pushnil(L);
        lua_rawset(L, -3);
        lua_pop(L, 1);
    }

    return 0;
}

static int __tostring(lua_State *L)
{
    wax_instance_userdata *instanceUserdata =
        (wax_instance_userdata *)luaL_checkudata(L, 1, WAX_INSTANCE_METATABLE_NAME);
    lua_pushstring(
        L,
        [[NSString stringWithFormat:@"(%p => %p) %@", instanceUserdata, instanceUserdata->instance,
                                    instanceUserdata->instance] UTF8String]);

    return 1;
}

static int __eq(lua_State *L)
{
    wax_instance_userdata *o1 =
        (wax_instance_userdata *)luaL_checkudata(L, 1, WAX_INSTANCE_METATABLE_NAME);
    wax_instance_userdata *o2 =
        (wax_instance_userdata *)luaL_checkudata(L, 2, WAX_INSTANCE_METATABLE_NAME);

    lua_pushboolean(L, [o1->instance isEqual:o2->instance]);
    return 1;
}


#pragma mark -
#pragma mark - Userdata Functions

static int methods(lua_State *L)
{
    wax_instance_userdata *instanceUserdata =
        (wax_instance_userdata *)luaL_checkudata(L, 1, WAX_INSTANCE_METATABLE_NAME);

    uint count;
    Method *methods = class_copyMethodList([instanceUserdata->instance class], &count);

    lua_newtable(L);

    for (int i = 0; i < count; i++) {
        Method method = methods[i];
        lua_pushstring(L, sel_getName(method_getName(method)));
        lua_rawseti(L, -2, i + 1);
    }

    return 1;
}


#pragma mark -
#pragma mark - Function Closures

static int methodClosure(lua_State *L)
{
    if (![[NSThread currentThread] isEqual:[NSThread mainThread]])
        NSLog(@"METHODCLOSURE: OH NO SEPERATE THREAD");

    wax_instance_userdata *instanceUserdata =
        (wax_instance_userdata *)luaL_checkudata(L, 1, WAX_INSTANCE_METATABLE_NAME);
    const char *selectorName = luaL_checkstring(L, lua_upvalueindex(1));

    // If the only arg is 'self' and there is a selector with no args. USE IT!
    if (lua_gettop(L) == 1 && lua_isstring(L, lua_upvalueindex(2))) {
        selectorName = luaL_checkstring(L, lua_upvalueindex(2));
    }

    SEL selector = sel_getUid(selectorName);
    id instance = instanceUserdata->instance;
    BOOL autoAlloc = NO;

    // If init is called on a class, auto-allocate it.
    if (instanceUserdata->isClass && wax_isInitMethod(selectorName)) {
        autoAlloc = YES;
        instance = [instance alloc];
    }

    NSMethodSignature *signature = [instance methodSignatureForSelector:selector];
    if (!signature) {
        const char *className = [NSStringFromClass([instance class]) UTF8String];
        luaL_error(L, "'%s' has no method selector '%s'", className, selectorName);
    }

    NSInvocation *invocation = nil;
    invocation = [NSInvocation invocationWithMethodSignature:signature];

    [invocation setTarget:instance];
    [invocation setSelector:selector];

    // skip the hidden self and _cmd argument
    unsigned long objcArgumentCount = [signature numberOfArguments] - 2;
    int luaArgumentCount = lua_gettop(L) - 1;

    // 检查参数个数
    if (objcArgumentCount > luaArgumentCount && !wax_instance_isWaxClass(instance)) {
        luaL_error(L, "Not Enough arguments given! Method named '%s' requires %d argument(s), you "
                      "gave %d. (Make sure you used ':' to call the method)",
                   selectorName, objcArgumentCount + 1, lua_gettop(L));
    }

    void **arguements = calloc(sizeof(void *), objcArgumentCount);
    for (int i = 0; i < objcArgumentCount; i++) {
        arguements[i] = wax_copyToObjc(L, [signature getArgumentTypeAtIndex:i + 2], i + 2, nil);
        [invocation setArgument:arguements[i] atIndex:i + 2];
    }

    @try {
        [invocation invoke];
    } @catch (NSException *exception) {
        luaL_error(L, "Error invoking method '%s' on '%s' because %s", selector,
                   class_getName([instance class]), [[exception description] UTF8String]);
    }

    for (int i = 0; i < objcArgumentCount; i++) {
        const char *type = [signature getArgumentTypeAtIndex:i + 2];
        //因为在wax_copyToObjc方法中，没有对char*类型进行内存分配，所以这里不需要释放
        if (type[0] == WAX_TYPE_STRING) {
            continue;
        }
        free(arguements[i]);
    }
    free(arguements);

    unsigned long methodReturnLength = [signature methodReturnLength];
    if (methodReturnLength > 0) {
        void *buffer = calloc(1, methodReturnLength);
        [invocation getReturnValue:buffer];

        wax_fromObjc(L, [signature methodReturnType], buffer);

        if (autoAlloc) {
            if (lua_isnil(L, -1)) {
                // The init method returned nil... means initialization failed!
                // Remove it from the userdataTable (We don't ever want to clean up after this... it
                // should have cleaned up after itself)
                wax_instance_pushUserdataTable(L);
                lua_pushlightuserdata(L, instance);
                lua_pushnil(L);
                lua_rawset(L, -3);
                lua_pop(L, 1);  // Pop the userdataTable

                lua_pushnil(L);
                [instance release];
            } else {
                wax_instance_userdata *returnedInstanceUserdata =
                    (wax_instance_userdata *)lua_topointer(L, -1);
                // Could return nil
                if (returnedInstanceUserdata) {
                    // Wax automatically retains a copy of the object, so the alloc needs to be
                    // released
                    [returnedInstanceUserdata->instance release];
                }
            }
        }

        free(buffer);
    }

    return 1;
}

static int superMethodClosure(lua_State *L)
{
    wax_instance_userdata *instanceUserdata =
        (wax_instance_userdata *)luaL_checkudata(L, 1, WAX_INSTANCE_METATABLE_NAME);
    const char *selectorName = luaL_checkstring(L, lua_upvalueindex(1));

    // If the only arg is 'self' and there is a selector with no args. USE IT!
    if (lua_gettop(L) == 1 && lua_isstring(L, lua_upvalueindex(2))) {
        selectorName = luaL_checkstring(L, lua_upvalueindex(2));
    }

    SEL selector = sel_getUid(selectorName);

    // Super Swizzle
    Method selfMethod = class_getInstanceMethod([instanceUserdata->instance class], selector);
    Method superMethod = class_getInstanceMethod(instanceUserdata->isSuper, selector);

    if (superMethod && selfMethod != superMethod) {  // Super's got what you're looking for
        IMP selfMethodImp = method_getImplementation(selfMethod);
        IMP superMethodImp = method_getImplementation(superMethod);
        method_setImplementation(selfMethod, superMethodImp);

        methodClosure(L);

        method_setImplementation(selfMethod, selfMethodImp);  // Swap back to self's original method
    } else {
        methodClosure(L);
    }

    return 1;
}

static int customInitMethodClosure(lua_State *L)
{
    wax_instance_userdata *classInstanceUserdata =
        (wax_instance_userdata *)luaL_checkudata(L, 1, WAX_INSTANCE_METATABLE_NAME);
    wax_instance_userdata *instanceUserdata = nil;

    id instance = nil;
    BOOL shouldRelease = NO;
    if (classInstanceUserdata->isClass) {
        shouldRelease = YES;
        instance = [classInstanceUserdata->instance alloc];
        instanceUserdata = wax_instance_create(L, instance, NO);
        lua_replace(L, 1);  // replace the old userdata with the new one!
    } else {
        luaL_error(L, "I WAS TOLD THIS WAS A CUSTOM INIT METHOD. BUT YOU LIED TO ME");
        return -1;
    }

    lua_pushvalue(L, lua_upvalueindex(1));  // Grab the function!
    lua_insert(L, 1);                       // push it up top

    if (wax_pcall(L, lua_gettop(L) - 1, 1)) {
        const char *errorString = lua_tostring(L, -1);
        luaL_error(L, "Custom init method on '%s' failed.\n%s",
                   class_getName([instanceUserdata->instance class]), errorString);
    }

    if (shouldRelease) {
        [instance release];
    }

    if (lua_isnil(L, -1)) {  // The init method returned nil... return the instanceUserdata instead
        luaL_error(L, "Init method must return the self");
    }

    return 1;
}


#pragma mark -
#pragma mark - Override Methods

static int pcallUserdata_new(lua_State *L, id self, SEL selector, NSInvocation *invocation)
{
    BEGIN_STACK_MODIFY(L)

    if (![[NSThread currentThread] isEqual:[NSThread mainThread]])
        NSLog(@"PCALLUSERDATA: OH NO SEPERATE THREAD");

    // A WaxClass could have been created via objective-c (like via NSKeyUnarchiver)
    // In this case, no lua object was ever associated with it, so we've got to
    // create one.
    if (wax_instance_isWaxClass(self)) {
        BOOL isClass = self == [self class];
        // If it already exists, then it will just return without doing anything
        wax_instance_create(L, self, isClass);
        // Pops userdata off
        lua_pop(L, 1);
    }

    // Find the function... could be in the object or in the class
    if (!wax_instance_pushFunction(L, self, selector)) {
        lua_pushfstring(L, "Could not find function named \"%s\" associated with object %s(%p).(It "
                           "may have been released by the GC)",
                        selector, class_getName([self class]), self);
        // function not found in userdata...
        goto error;
    }

    // Push userdata as the first argument
    wax_fromInstance(L, self);
    if (lua_isnil(L, -1)) {
        lua_pushfstring(L, "Could not convert '%s' into lua", class_getName([self class]));
        goto error;
    }

    NSMethodSignature *signature = [self methodSignatureForSelector:selector];
    // Don't send in the _cmd argument, only self
    int nargs = (int)([signature numberOfArguments] - 1);
    int nresults = [signature methodReturnLength] ? 1 : 0;

    // start at 2 because to skip the automatic self and _cmd arugments
    for (int i = 2; i < [signature numberOfArguments]; i++) {
        const char *type = [signature getArgumentTypeAtIndex:i];
        wax_fromObjc_new(L, type, invocation, i);
    }

    // Userdata will allways be the first object sent to the function
    if (wax_pcall(L, nargs, nresults)) {
        goto error;
    }

    END_STACK_MODIFY(L, nresults)
    return nresults;

error:
    END_STACK_MODIFY(L, 1)
    return -1;
}

static int pcallUserdata(lua_State *L, id self, SEL selector, va_list args)
{
    BEGIN_STACK_MODIFY(L)

    if (![[NSThread currentThread] isEqual:[NSThread mainThread]])
        NSLog(@"PCALLUSERDATA: OH NO SEPERATE THREAD");

    // A WaxClass could have been created via objective-c (like via NSKeyUnarchiver)
    // In this case, no lua object was ever associated with it, so we've got to
    // create one.
    if (wax_instance_isWaxClass(self)) {
        BOOL isClass = self == [self class];
        // If it already exists, then it will just return without doing anything
        wax_instance_create(L, self, isClass);
        // Pops userdata off
        lua_pop(L, 1);
    }

    // Find the function... could be in the object or in the class
    if (!wax_instance_pushFunction(L, self, selector)) {
        lua_pushfstring(L, "Could not find function named \"%s\" associated with object %s(%p).(It "
                           "may have been released by the GC)",
                        selector, class_getName([self class]), self);
        goto error;
    }

    // Push userdata as the first argument
    wax_fromInstance(L, self);
    if (lua_isnil(L, -1)) {
        lua_pushfstring(L, "Could not convert '%s' into lua", class_getName([self class]));
        goto error;
    }

    NSMethodSignature *signature = [self methodSignatureForSelector:selector];
    // Don't send in the _cmd argument, only self
    int nargs = (int)([signature numberOfArguments] - 1);
    int nresults = [signature methodReturnLength] ? 1 : 0;

    // start at 2 because to skip the automatic self and _cmd arugments
    for (int i = 2; i < [signature numberOfArguments]; i++) {
        const char *type = [signature getArgumentTypeAtIndex:i];
        int size = wax_fromObjc(L, type, args);
        args += size;  // HACK! Since va_arg requires static type, I manually increment the args
    }

    // Userdata will allways be the first object sent to the function
    if (wax_pcall(L, nargs, nresults)) {
        goto error;
    }

    END_STACK_MODIFY(L, nresults)
    return nresults;

error:
    END_STACK_MODIFY(L, 1)
    return -1;
}

#define WAX_METHOD_NAME(_type_) wax_##_type_##_call

#define WAX_METHOD(_type_)                                                                         \
    static _type_ WAX_METHOD_NAME(_type_)(id self, SEL _cmd, ...)                                  \
    {                                                                                              \
        va_list args;                                                                              \
        va_start(args, _cmd);                                                                      \
        va_list args_copy;                                                                         \
        va_copy(args_copy, args);                                                                  \
        /* Grab the static L... this is a hack */                                                  \
        lua_State *L = wax_currentLuaState();                                                      \
        BEGIN_STACK_MODIFY(L);                                                                     \
        int result = pcallUserdata(L, self, _cmd, args_copy);                                      \
        va_end(args_copy);                                                                         \
        va_end(args);                                                                              \
        if (result == -1) {                                                                        \
            luaL_error(L, "Error calling '%s' on '%s'\n%s", _cmd, [[self description] UTF8String], \
                       lua_tostring(L, -1));                                                       \
        } else if (result == 0) {                                                                  \
            _type_ returnValue;                                                                    \
            bzero(&returnValue, sizeof(_type_));                                                   \
            END_STACK_MODIFY(L, 0)                                                                 \
            return returnValue;                                                                    \
        }                                                                                          \
                                                                                                   \
        NSMethodSignature *signature = [self methodSignatureForSelector:_cmd];                     \
        _type_ *pReturnValue = (_type_ *)wax_copyToObjc(L, [signature methodReturnType], -1, nil); \
        _type_ returnValue = *pReturnValue;                                                        \
        free(pReturnValue);                                                                        \
        END_STACK_MODIFY(L, 0)                                                                     \
        return returnValue;                                                                        \
    }

typedef struct _buffer_16 {
    char b[16];
} buffer_16;
typedef struct _buffer_32 {
    char b[32];
} buffer_32;

WAX_METHOD(buffer_32)
WAX_METHOD(buffer_16)
WAX_METHOD(id)
WAX_METHOD(int)
WAX_METHOD(long)
WAX_METHOD(float)
WAX_METHOD(BOOL)
WAX_METHOD(double)

static char *wax_charptr_call(id self, SEL _cmd, ...)
{
    va_list args;
    va_start(args, _cmd);
    va_list args_copy;
    va_copy(args_copy, args);
    /* Grab the static L... this is a hack */
    lua_State *L = wax_currentLuaState();
    BEGIN_STACK_MODIFY(L);
    int result = pcallUserdata(L, self, _cmd, args_copy);
    va_end(args_copy);
    va_end(args);

    if (result == -1) {
        luaL_error(L, "Error calling '%s' on '%s'\n%s", _cmd, [[self description] UTF8String],
                   lua_tostring(L, -1));
    } else if (result == 0) {
        char *returnValue;
        bzero(&returnValue, sizeof(char *));
        END_STACK_MODIFY(L, 0)
        return returnValue;
    }
    NSMethodSignature *signature = [self methodSignatureForSelector:_cmd];
    //此方法中，对char*的处理，没有分配内存，所以下面不需要free
    char *pReturnValue = wax_copyToObjc(L, [signature methodReturnType], -1, nil);
    END_STACK_MODIFY(L, 0)
    return pReturnValue;
}
#define WAX_METHOD_NAME_NEW(_type_, self, _cmd, invocation)                                        \
    wax_##_type_##_call_new(id self, SEL _cmd, NSInvocation *invocation)

#define WAX_METHOD_NEW(_type_)                                                                     \
    static _type_ WAX_METHOD_NAME_NEW(_type_, self, _cmd, invocation)                              \
    {                                                                                              \
        lua_State *L = wax_currentLuaState();                                                      \
        BEGIN_STACK_MODIFY(L);                                                                     \
        int result = pcallUserdata_new(L, self, _cmd, invocation);                                 \
        if (result == -1) {                                                                        \
            luaL_error(L, "Error calling '%s' on '%s'\n%s", _cmd, [[self description] UTF8String], \
                       lua_tostring(L, -1));                                                       \
        } else if (result == 0) {                                                                  \
            _type_ returnValue;                                                                    \
            bzero(&returnValue, sizeof(_type_));                                                   \
            END_STACK_MODIFY(L, 0)                                                                 \
            return returnValue;                                                                    \
        }                                                                                          \
        NSMethodSignature *signature = [self methodSignatureForSelector:_cmd];                     \
        _type_ *pReturnValue = (_type_ *)wax_copyToObjc(L, [signature methodReturnType], -1, nil); \
        _type_ returnValue = *pReturnValue;                                                        \
        free(pReturnValue);                                                                        \
        END_STACK_MODIFY(L, 0)                                                                     \
        return returnValue;                                                                        \
    }

WAX_METHOD_NEW(buffer_16)
WAX_METHOD_NEW(buffer_32)
WAX_METHOD_NEW(id)
WAX_METHOD_NEW(int)
WAX_METHOD_NEW(long)
WAX_METHOD_NEW(float)
WAX_METHOD_NEW(BOOL)
WAX_METHOD_NEW(double)

static char *wax_charptr_call_new(id self, SEL _cmd, NSInvocation *invocation)
{
    lua_State *L = wax_currentLuaState();
    BEGIN_STACK_MODIFY(L);
    int result = pcallUserdata_new(L, self, _cmd, invocation);
    if (result == -1) {
        luaL_error(L, "Error calling '%s' on '%s'\n%s", _cmd, [[self description] UTF8String],
                   lua_tostring(L, -1));
    } else if (result == 0) {
        char *returnValue;
        bzero(&returnValue, sizeof(char *));
        END_STACK_MODIFY(L, 0)
        return returnValue;
    }
    NSMethodSignature *signature = [self methodSignatureForSelector:_cmd];
    //此方法中，对char*的处理，没有分配内存，所以下面不需要free
    char *pReturnValue = wax_copyToObjc(L, [signature methodReturnType], -1, nil);
    END_STACK_MODIFY(L, 0)
    return pReturnValue;
}


// Only allow classes to do this
// instanceUserdata是一个Obj-C的类，指向当前lua类的父类
static BOOL overrideMethod(lua_State *L, wax_instance_userdata *instanceUserdata)
{
    BEGIN_STACK_MODIFY(L);
    BOOL success = NO;
    const char *methodName = lua_tostring(L, 2);
    // 在instanceUserdata中找到对应name的method selector，存放在foundSelectors[]中
    SEL foundSelectors[2] = {nil, nil};
    wax_selectorForInstance(instanceUserdata, foundSelectors, methodName, YES);
    //如果找到了2个selector，则会使用第一个
    SEL selector = foundSelectors[0];

    // instanceUserdata类的实现的class 若原obj-C代码中无此lua类，则应该为空类。
    // 若原obj-C代码中有此lua类，则应该指向obj-C类。
    Class klass = [instanceUserdata->instance class];

    NSString *classStr = NSStringFromClass(klass);
    // Wax自带的方法替换，在这里屏蔽掉。
    // 如果不屏蔽，后面InterceptorView
    // touchesEnded:Event:方法会使UIResponder的对应方法被替换，而引起异常
    // 屏蔽而引起的负面作用，目前还没有发现
    if ([classStr isEqualToString:@"WaxServer"] || [classStr isEqualToString:@"InterceptorView"]) {
        return YES;
    }

    char *typeDescription = nil;
    char *returnType = nil;

    // 从class的instance中寻找selector的method
    // 若原obj-C代码中无此lua类，则应该指向对应function。
    // 若原obj-C代码中有此lua类，则应该为空。
    Method method = class_getInstanceMethod(klass, selector);

    // 如果找到了，那么获得参数列表类型和返回值类型, 如果没找到，延父类继续向上寻找。
    if (method) {
        typeDescription = (char *)method_getTypeEncoding(method);
        returnType = method_copyReturnType(method);
    } else {
        Class currentClass = klass;

        while (!returnType && [currentClass superclass] != [currentClass class]) {
            uint count;
            Protocol **protocols = class_copyProtocolList(currentClass, &count);

            SEL possibleSelectors[2];
            wax_selectorsForName(methodName, possibleSelectors);

            for (int i = 0; !returnType && i < count; i++) {
                Protocol *protocol = protocols[i];
                struct objc_method_description m_description;

                for (int j = 0; !returnType && j < 2; j++) {
                    selector = possibleSelectors[j];
                    // There may be only one acceptable selector sent back
                    if (!selector) continue;

                    m_description = protocol_getMethodDescription(protocol, selector, YES, YES);
                    if (!m_description.name)
                        // Check if it is not a "required" method
                        m_description = protocol_getMethodDescription(protocol, selector, NO, YES);

                    if (m_description.name) {
                        typeDescription = m_description.types;
                        returnType = method_copyReturnType((Method)&m_description);
                    }
                }
            }

            free(protocols);

            currentClass = [currentClass superclass];
        }
    }

    // 如果找到了，则向class中添加此方法。
    // 如果没有找到，则当做一个新的方法添加入此类。
    ldaspect_block_t invocationBlock = ^(NSInvocation *invocation) {

        const char *r_type = invocation.methodSignature.methodReturnType;
        switch (r_type[0]) {
            case WAX_TYPE_VOID:
            case WAX_TYPE_ID: {
                id returnValue =
                    wax_id_call_new(invocation.target, invocation.selector, invocation);
                if (returnValue) {
                    [invocation setReturnValue:&returnValue];
                }
            } break;

            // 以下类型可自动转换为int
            case WAX_TYPE_CHAR:
            case WAX_TYPE_INT:
            case WAX_TYPE_SHORT:
            case WAX_TYPE_UNSIGNED_CHAR:
            case WAX_TYPE_UNSIGNED_INT:
            case WAX_TYPE_UNSIGNED_SHORT: {
                int returnValue =
                    wax_int_call_new(invocation.target, invocation.selector, invocation);
                [invocation setReturnValue:&returnValue];
            } break;

            // 以下类型可自动转换为long, long 和 long long还是需要分开处理
            case WAX_TYPE_LONG: {
                long returnValue =
                    wax_long_call_new(invocation.target, invocation.selector, invocation);
                [invocation setReturnValue:&returnValue];
            } break;

            case WAX_TYPE_UNSIGNED_LONG: {
                unsigned long returnValue = (unsigned long)wax_long_call_new(
                    invocation.target, invocation.selector, invocation);
                [invocation setReturnValue:&returnValue];
            } break;

            case WAX_TYPE_LONG_LONG: {
                long long returnValue = (long long)wax_long_call_new(
                    invocation.target, invocation.selector, invocation);
                [invocation setReturnValue:&returnValue];
            } break;

            case WAX_TYPE_UNSIGNED_LONG_LONG: {
                unsigned long long returnValue = (unsigned long long)wax_long_call_new(
                    invocation.target, invocation.selector, invocation);
                [invocation setReturnValue:&returnValue];
            } break;

            case WAX_TYPE_FLOAT: {
                float returnValue =
                    wax_float_call_new(invocation.target, invocation.selector, invocation);
                [invocation setReturnValue:&returnValue];
            } break;

            case WAX_TYPE_DOUBLE: {
                double returnValue =
                    wax_double_call_new(invocation.target, invocation.selector, invocation);
                [invocation setReturnValue:&returnValue];
            } break;

            case WAX_TYPE_C99_BOOL: {
                BOOL returnValue =
                    wax_BOOL_call_new(invocation.target, invocation.selector, invocation);
                [invocation setReturnValue:&returnValue];
            } break;
            case WAX_TYPE_STRING: {
                char *returnValue =
                    wax_charptr_call_new(invocation.target, invocation.selector, invocation);
                [invocation setReturnValue:&returnValue];
            } break;
            case WAX_TYPE_STRUCT: {
                int size = wax_sizeOfTypeDescription(r_type);
                switch (size) {
                    case 16: {
                        buffer_16 returnValue = wax_buffer_16_call_new(
                            invocation.target, invocation.selector, invocation);
                        [invocation setReturnValue:&returnValue];
                    } break;
                    case 32: {
                        buffer_32 returnValue = wax_buffer_32_call_new(
                            invocation.target, invocation.selector, invocation);
                        [invocation setReturnValue:&returnValue];
                    } break;
                    default:
                        luaL_error(L, "Trying to override a method that has a struct return type "
                                      "of size '%d'. There is no implementation for this size yet.",
                                   size);
                        return;
                        break;
                }
                break;
            }

            default:
                luaL_error(L, "Can't override method with return type %s", r_type);
                return;
                break;
        }

    };

    // Matching method found! Create an Obj-C method on the
    if (returnType) {
        if (!instanceUserdata->isClass) {
            luaL_error(
                L, "Trying to override method '%s' on an instance. You can only override classes",
                methodName);
        }

        const char *simplifiedReturnType = wax_removeProtocolEncodings(returnType);

        IMP imp;
        switch (simplifiedReturnType[0]) {
            case WAX_TYPE_VOID:
            case WAX_TYPE_ID:
                imp = (IMP)WAX_METHOD_NAME(id);
                break;

            // 以下类型可自动转换为int
            case WAX_TYPE_CHAR:
            case WAX_TYPE_INT:
            case WAX_TYPE_SHORT:
            case WAX_TYPE_UNSIGNED_CHAR:
            case WAX_TYPE_UNSIGNED_INT:
            case WAX_TYPE_UNSIGNED_SHORT:
                imp = (IMP)WAX_METHOD_NAME(int);
                break;

            // 以下类型可自动转换为long
            case WAX_TYPE_LONG:
            case WAX_TYPE_LONG_LONG:
            case WAX_TYPE_UNSIGNED_LONG:
            case WAX_TYPE_UNSIGNED_LONG_LONG:
                imp = (IMP)WAX_METHOD_NAME(long);
                break;

            case WAX_TYPE_FLOAT:
                imp = (IMP)WAX_METHOD_NAME(float);
                break;

            case WAX_TYPE_C99_BOOL:
                imp = (IMP)WAX_METHOD_NAME(BOOL);
                break;

            case WAX_TYPE_DOUBLE:
                imp = (IMP)WAX_METHOD_NAME(double);
                break;
            case WAX_TYPE_STRING:
                imp = (IMP)wax_charptr_call;
                break;

            case WAX_TYPE_STRUCT: {
                int size = wax_sizeOfTypeDescription(simplifiedReturnType);
                switch (size) {
                    case 16:
                        imp = (IMP)WAX_METHOD_NAME(buffer_16);
                        break;
                    case 32:
                        imp = (IMP)WAX_METHOD_NAME(buffer_32);
                        break;
                    default:
                        luaL_error(L, "Trying to override a method that has a struct return type "
                                      "of size '%d'. There is no implementation for this size yet.",
                                   size);
                        return NO;
                        break;
                }
                break;
            }

            default:
                luaL_error(L, "Can't override method with return type %s", simplifiedReturnType);
                return NO;
                break;
        }

        id metaclass = objc_getMetaClass(object_getClassName(klass));

        IMP instImp = class_respondsToSelector(klass, selector)
                          ? class_getMethodImplementation(klass, selector)
                          : NULL;
        IMP metaImp = class_respondsToSelector(metaclass, selector)
                          ? class_getMethodImplementation(metaclass, selector)
                          : NULL;

        if (instImp) {
            IMP prevImp = class_getMethodImplementation(klass, selector);
            NSString *identifier = [[LDAOPAspect instance] interceptClass:klass
                                                          insteadSelector:selector
                                                               usingBlock:invocationBlock];

            const char *selectorName = sel_getName(selector);
            char newSelectorName[strlen(selectorName) + 10];
            strcpy(newSelectorName, "objc");
            strcat(newSelectorName, selectorName);
            SEL newSelector = sel_getUid(newSelectorName);
            if (!class_respondsToSelector(klass, newSelector)) {
                class_addMethod(klass, newSelector, prevImp, typeDescription);
            } else {
                class_replaceMethod(klass, newSelector, prevImp, typeDescription);
            }
            success = YES;

            NSDictionary *dict = @{
                @"class" : klass,
                @"sel" : selector ? NSStringFromSelector(selector) : [NSNull null],
                @"sel_objc" :
                    newSelector ? NSStringFromSelector(newSelector) : [NSNull null],  // objcXXXX
                @"typeDesc" : typeDescription ? [NSString stringWithUTF8String:typeDescription]
                                              : [NSNull null],
                @"identifier" : identifier
            };
            addMethodReplaceDict(dict);
        } else if (metaImp) {
            IMP prevImp = class_replaceMethod(metaclass, selector, imp, typeDescription);
            const char *selectorName = sel_getName(selector);
            char newSelectorName[strlen(selectorName) + 10];
            strcpy(newSelectorName, "objc");
            strcat(newSelectorName, selectorName);
            SEL newSelector = sel_getUid(newSelectorName);
            if (!class_respondsToSelector(metaclass, newSelector)) {
                class_addMethod(metaclass, newSelector, prevImp, typeDescription);
            } else {
                class_replaceMethod(metaclass, newSelector, prevImp, typeDescription);
            }
            success = YES;

            NSDictionary *dict = @{
                @"class" : metaclass,
                @"sel" : selector ? NSStringFromSelector(selector) : [NSNull null],
                @"sel_objc" :
                    newSelector ? NSStringFromSelector(newSelector) : [NSNull null],  // objcXXXX
                @"typeDesc" : typeDescription ? [NSString stringWithUTF8String:typeDescription]
                                              : [NSNull null]
            };
            addMethodReplaceDict(dict);
        } else {
            success = class_addMethod(klass, selector, imp, typeDescription) &&
                      class_addMethod(metaclass, selector, imp, typeDescription);
        }
        if (returnType) free(returnType);
    } else {
        SEL possibleSelectors[2];
        wax_selectorsForName(methodName, possibleSelectors);

        success = YES;
        for (int i = 0; i < 2; i++) {
            selector = possibleSelectors[i];
            if (!selector) continue;  // There may be only one acceptable selector sent back

            int argCount = 0;
            char *match = (char *)sel_getName(selector);
            // match中首次出现:的位置
            while ((match = strchr(match, ':'))) {
                match += 1;  // Skip past the matched char
                argCount++;
            }

            size_t typeDescriptionSize = 3 + argCount;
            typeDescription = calloc(typeDescriptionSize + 1, sizeof(char));
            memset(typeDescription, '@', typeDescriptionSize);
            typeDescription[2] = ':';  // Never forget _cmd!

            IMP imp = (IMP)WAX_METHOD_NAME(id);
            id metaclass = objc_getMetaClass(object_getClassName(klass));

            IMP instImp = class_respondsToSelector(klass, selector)
                              ? class_getMethodImplementation(klass, selector)
                              : NULL;
            IMP metaImp = class_respondsToSelector(metaclass, selector)
                              ? class_getMethodImplementation(metaclass, selector)
                              : NULL;
            if (instImp) {
                IMP prevImp = class_getMethodImplementation(klass, selector);
                NSString *identifier = [[LDAOPAspect instance] interceptClass:klass
                                                              insteadSelector:selector
                                                                   usingBlock:invocationBlock];
                const char *selectorName = sel_getName(selector);
                char newSelectorName[strlen(selectorName) + 10];
                strcpy(newSelectorName, "objc");
                strcat(newSelectorName, selectorName);
                SEL newSelector = sel_getUid(newSelectorName);
                if (!class_respondsToSelector(klass, newSelector)) {
                    class_addMethod(klass, newSelector, prevImp, typeDescription);
                } else {
                    class_replaceMethod(klass, newSelector, prevImp, typeDescription);
                }
                success = YES;

                NSDictionary *dict = @{
                    @"class" : klass,
                    @"sel" : selector ? NSStringFromSelector(selector) : [NSNull null],
                    @"sel_objc" : newSelector ? NSStringFromSelector(newSelector)
                                              : [NSNull null],  // objcXXXX
                    @"typeDesc" : typeDescription ? [NSString stringWithUTF8String:typeDescription]
                                                  : [NSNull null],
                    @"identifier" : identifier
                };
                addMethodReplaceDict(dict);
            } else if (metaImp) {
                IMP prevImp = class_replaceMethod(metaclass, selector, imp, typeDescription);
                const char *selectorName = sel_getName(selector);
                char newSelectorName[strlen(selectorName) + 10];
                strcpy(newSelectorName, "objc");
                strcat(newSelectorName, selectorName);
                SEL newSelector = sel_getUid(newSelectorName);
                if (!class_respondsToSelector(metaclass, newSelector)) {
                    class_addMethod(metaclass, newSelector, prevImp, typeDescription);
                } else {
                    class_replaceMethod(metaclass, newSelector, prevImp, typeDescription);
                }
                success = YES;

                NSDictionary *dict = @{
                    @"class" : metaclass,
                    @"sel" : selector ? NSStringFromSelector(selector) : [NSNull null],
                    @"sel_objc" : newSelector ? NSStringFromSelector(newSelector)
                                              : [NSNull null],  // objcXXXX
                    @"typeDesc" : typeDescription ? [NSString stringWithUTF8String:typeDescription]
                                                  : [NSNull null]
                };
                addMethodReplaceDict(dict);
            } else {
                success = class_addMethod(klass, selector, imp, typeDescription) &&
                          class_addMethod(metaclass, selector, imp, typeDescription);
            }

            free(typeDescription);
        }
    }

    END_STACK_MODIFY(L, 1)
    return success;
}