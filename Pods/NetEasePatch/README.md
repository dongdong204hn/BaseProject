## ios热更新-基于wax+lua框架的动态补丁修复已发布app的bug
wax框架能够把lua脚本和已有的线上ios项目无缝的结合起来，wax框架既可以用lua脚本直接编写native app程序，也可以在不改变项目使用Objective-C开发的方式，在项目上线后通过Wax来改变程序运行时的行为。这样就可以避免漫长的AppStore上线审核，随时对线上程序进行调整，甚至是修复线上程序的问题或缺陷。   
    
* 能够对已经发布的ios应用程序打补丁，来修复紧急的线上bug；
* 能够通过插件安装的方式， 对即时的运营策略上线对应的功能模块；      

1. Homepage:https://git.ms.netease.com/huipang/neteasepatch
2. Wiki: https://git.ms.netease.com/huipang/neteasepatch/wikis/home
3. Issues:https://git.ms.netease.com/huipang/neteasepatch/issues
4. Tags: ios, objc   

## Wax+lua的的基本框架和改进
waxPatch框架地址：[wax patch]: https://github.com/mmin18/WaxPatch
waxPatch 主要是利用oc的运行时环境，用lua生成的类方法去代替原有objc生成的类方法，我们在此基础上在方法替换时加入了现场保留的代码，以保证当关闭wax框架运行之后，能够重新使用原OC的方法；
另外也对wax框架对于oc和lua数据结构的相互转化进行了丰富。

Wax Lua的优势：
* 开源、免费，遵循MIT协议。项目地址：[Wax Lua]: https://github.com/probablycorey/wax
* 可以使用原生API，可以访问所有ios的框架。
* Lua类型和OC类型自动转化。
* 自动内存管理。
* 便捷的Lua模块，使得HTTP请求和JSON解析容易且快速。
* 简洁的代码，不再有头文件，数组和字典等语句。
* Lua支持闭包，相当强大的功能。

注意：对于修复bug的程序员，需要学会通过lua脚本编写obj-c程序，并修改相应版本的obj-c代码方便下次提交更新审核；   
Lua脚本语法参考：[lua api]: http://www.lua.org/manual/5.1/manual.html#pdf-table.concat

## Patch版本控制方案
* 服务器patch包管理：   

1. 从后台管理选择某个产品，然后选择该产品的某个版本，然后选择zip包，上传到服务器端，服务器将zip包的MD5存储到数据库中，供查询；
2. 注意打包时，.lua文件所在的目录文件夹以“patch”命名，启动的lua文件统一命名为patch.lua，这个文件需要包括所有其他的lua文件；
3. 对patch目录打成zip格式的包，打成的包名可以随意变更；

* 客户端启动当前版本Patch:    
* 客户端检查当前版本Patch更新：    


## NetEasePatch补丁集成到各个项目说明
     
        
* 第一步：从git上下载代码：
https://git.ms.netease.com/huipang/neteasepatch.git
可以先整个工程运行看看：


* 第二步：将NetEasePath/patch 和 NetEasePatch/Wax 两个文件夹内的代码 拷贝加入到您的工程文件夹中并配置一下编译环境：
      

   配置wax框架环境：
     
     
1. 加入framework: libz.dylib, libxml2.dylib, CoreGraphics.framework
2. Patch包中引入了minizip第三方包用于解压zip文件，如果有zip文件的命名冲突：build setting->other linker flag把 -all_load换成-ObjC
3. Building Setting:  Architectures 设置为${ARCHS_STANDARD_32_BIT};
4. Header Search Paths:  加入${SDK_DIR}/usr/include/libxml2 引用系统xml头文件；
5. Prefix Header: 配置：工程名/patch/ NetEasePatch-Prefix.pch  
6. 如果您的工程是ARC模式：在build Phases里配置MRC编译参数：-fno-objc-arc, 需要加参数的文件包括：wax_*的文件，ZipArchive.mm


* 第三步：只需要在appdelegate 里引用LDPatchService.h文件：
    
1. 在didFinishLaunching中调用启动wax框架的方法
``[[LDPatchService sharedManager] startNetpatchWithAppcode:[self appBundleIdentifier] andAppVersion:[self appBundleShortVersion]];``
    
2. 在applicationDidBecomeActive 中调用检查更新脚本的方法
``[[LDPatchService sharedManager] refreshPatchWithAppcode:[self appBundleIdentifier] andAppVersion:[self appBundleShortVersion]];``
       
3. 在app 退出的时候停止wax框架
``[[LDPatchService sharedManager] closeNetpatch];``