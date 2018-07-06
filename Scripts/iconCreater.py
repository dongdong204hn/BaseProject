# -*- coding: utf-8 -*-  

# import Image  
from PIL import Image
import glob, os  
  
#图片批处理。更换icon时。1、将新的icon1024的图片命名iTunesArtwork.png放在工程根目录下 2、执行本脚本在桌面的icon文件夹中生成各个尺寸的新icon(Xcode7Images.xcassets中火车票所需icon共9组，按从左到右，依次标号Icon_1~9) 3、在Images.xcassets依次替换
def icon():
        # filepath,filename = os.path.split('//Users//zhaosong//Desktop//icon.png')
        # filterame,exts = os.path.splitext(filename)  
        #输出路径  
        opfile = os.path.join(os.path.expanduser("~"), 'Desktop') + '//icon//'
        #判断opfile是否存在，不存在则创建  
        if (os.path.isdir(opfile)==False):  
            os.mkdir(opfile)  
        im = Image.open('..//iTunesArtwork.png')
        # w,h = im.size 
        # im_iTunesArtwork = im.resize((w, h))  
        # im_iTunesArtwork.save(opfile+'iTunesArtwork.png') 
        im_icon29 = im.resize((29,29),Image.ANTIALIAS)
        im_icon29.save(opfile+'Icon_1-29.png')
        im_icon58 = im.resize((58,58),Image.ANTIALIAS)
        im_icon58.save(opfile+'Icon_1-29@2x.png')
        im_icon87 = im.resize((87,87),Image.ANTIALIAS)
        im_icon87.save(opfile+'Icon_1-29@3x.png')
        
        im_icon80 = im.resize((80,80),Image.ANTIALIAS)
        im_icon80.save(opfile+'Icon_2-40@2x.png')
        im_icon120 = im.resize((120,120),Image.ANTIALIAS)
        im_icon120.save(opfile+'Icon_2-40@3x.png')
        
        im_icon57 = im.resize((57,57),Image.ANTIALIAS)
        im_icon57.save(opfile+'Icon_3-57.png')
        im_icon114 = im.resize((114,114),Image.ANTIALIAS)
        im_icon114.save(opfile+'Icon_3_57@2x.png')

        im_icon120 = im.resize((120,120),Image.ANTIALIAS)
        im_icon120.save(opfile+'Icon_4-60@2x.png')
        im_icon180 = im.resize((180,180),Image.ANTIALIAS)
        im_icon180.save(opfile+'Icon_4-60@3x.png')

        im_icon29 = im.resize((29,29),Image.ANTIALIAS)
        im_icon29.save(opfile+'Icon_5-29.png')
        im_icon58 = im.resize((58,58),Image.ANTIALIAS)
        im_icon58.save(opfile+'Icon_5-29@2x.png')

        im_icon40 = im.resize((40,40),Image.ANTIALIAS)
        im_icon40.save(opfile+'Icon_6-40.png')
        im_icon80 = im.resize((80,80),Image.ANTIALIAS)
        im_icon80.save(opfile+'Icon_6-40@2x.png')

        im_icon50 = im.resize((50, 50),Image.ANTIALIAS)  
        im_icon50.save(opfile+'Icon_7-50.png') 
        im_icon100 = im.resize((100, 100),Image.ANTIALIAS)  
        im_icon100.save(opfile+'Icon_7-50@2x.png') 

        im_icon72 = im.resize((72,72),Image.ANTIALIAS)
        im_icon72.save(opfile+'icon_8-72.png')
        im_icon144 = im.resize((144,144),Image.ANTIALIAS)
        im_icon144.save(opfile+'icon_8-72@2x.png')

        im_icon76 = im.resize((76,76),Image.ANTIALIAS)
        im_icon76.save(opfile+'icon_9-76.png')
        im_icon152 = im.resize((152,152),Image.ANTIALIAS)
        im_icon152.save(opfile+'icon_9-76@2x.png')

  
if __name__=='__main__':  
    icon()  
  
    print '--------end-------'  