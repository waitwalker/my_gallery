#!/user/local/bin/python3
#将本文件放在Flutter项目的根目录

from genericpath import isdir
import imghdr
from operator import delitem
import os
from re import search
import re
import string
from sys import path
import sys
from tokenize import String
from typing import List

print("---Analyze unused Assets----")

print ('***获取当前目录***')
print (os.getcwd())
print (os.path.abspath(os.path.dirname(__file__)))

print ('***获取上级目录***')
print (os.path.abspath(os.path.dirname(os.path.abspath(os.path.dirname(__file__)))))
print (os.path.abspath(os.path.dirname(os.getcwd())))
print (os.path.abspath(os.path.join(os.getcwd(), "..")))

#项目目录
projectAbsRootPath = os.path.abspath(os.path.join(os.getcwd(), ".."))

#图片所在的资源目录路径
assetPath="/assets"
#项目中dart代码所在目录
libPath = projectAbsRootPath+ "/lib"
assetAbPath = projectAbsRootPath+assetPath

print("projectRootPath:" + projectAbsRootPath +  "   assets:" +assetAbPath + "     lib:" + libPath)
print("----------开始查找图片--------------")
#遍历目录，将图片存储到list中的方法
def searchImage(filePath:String):
    list = []
    isDir = os.path.isdir(filePath)
    if isDir:
        for f in os.listdir(filePath):
            if f.startswith("."):
                print(filePath+"/"+f)
            else:
                tList = searchImage(filePath+"/"+f)
                list.extend(tList)
    else:
        if imghdr.what(filePath) in {"jpg","bmp","jpeg","webp","tif","png"}:
            list.append(filePath)
    return list

#项目中使用的图片资源路径集合
imageList = searchImage(assetAbPath)

print("-------------遍历dart文件，分析未使用的图片---------")
def matchAndDelImage(contentStr:String,list:List):
    #遍历拷贝的list,操作原始的list，list[:]是对原始的一个拷贝
    for imgPath in list[:]:
        #以文件名匹配图片的使用
        # pList = imgPath.split("/")
        # imgName = pList[-1]
        #以使用的文件路径匹配图片
        index = imgPath.find(assetPath)
        imgName = imgPath[index+1:]

        match = re.search(imgName,contentStr)
        if match:
            list.remove(imgPath)
            # print("used-->" + imgPath)

#
def searchImageInDart(filePath:String,list:List):
    if os.path.isdir(filePath):
        for f in os.listdir(filePath):
            searchImageInDart(filePath+"/"+f,list)
    else:
        with open(filePath,"r") as f:
            contentStr = f.read()
            f.close()
            if len(contentStr) != 0:
                matchAndDelImage(contentStr,list)

#
searchImageInDart(libPath,imageList)

print("------在dart文件中未找到被使用的图片如下-----size:" + str(len(imageList)))
for img in imageList:
    print("may be unused-->" + img)
    # os.remove(img)
print("-------------------分析完成-------------------------------")
