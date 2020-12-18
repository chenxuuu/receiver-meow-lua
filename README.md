# receiver-meow-lua

[![license](https://img.shields.io/github/license/chenxuuu/receiver-meow-lua)](https://github.com/chenxuuu/receiver-meow-lua/blob/master/LICENSE)
[![receiver-meow](https://img.shields.io/badge/dependencies-receiver_meow-blueviolet.svg)](https://github.com/chenxuuu/receiver-meow)
[![code-size](https://img.shields.io/github/languages/code-size/chenxuuu/receiver-meow-lua.svg)](https://github.com/chenxuuu/receiver-meow-lua/archive/master.zip)

接待喵lua插件的lua脚本仓库

这个仓库的代码需要配合lua插件本体食用

lua插件餐具地址：[https://github.com/chenxuuu/receiver-meow](https://github.com/chenxuuu/receiver-meow)

# 处理流程

## 入口文件

代码入口为`main.lua`，进行了如下操作：

初始化各项需要用到的接口

添加需要`require`文件的所在路径

分配各个`Task框架`事件到`events`文件夹下的文件

## 定时任务

在`events/AppEnable.lua`文件中，声明了多个定时任务，同时使用了timer和task接口

## 私聊和群消息功能

所有私聊消息与群消息，统一经由`events/Message.lua`文件处理

接着，会自动遍历加载`require\apps`下的所有`lua`文件，使每个文件的功能都能正常起作用

你可以自行删减`require\apps`的文件以便删减功能，注意匹配顺序按文件名来排序

## 注意事项

调用C#接口，请参考[Nlua](https://github.com/NLua/NLua/)关于`import`函数的使用说明

主虚拟机由Task框架调度，具体的任务、定时器用法请见[LuaTask项目的Readme](https://github.com/chenxuuu/LuaTask-csharp)
