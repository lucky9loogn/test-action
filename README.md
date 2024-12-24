# BleHelper

基于 [Qt](https://www.qt.io/) ([6.7.0](https://www.qt.io/blog/qt-6.7-released)) 和 [FluentUI](https://github.com/zhuzichu520/FluentUI/) ([1.7.7](https://github.com/zhuzichu520/FluentUI/tree/1.7.7)) 打造的低功耗蓝牙助手

## 运行说明

由于需要在 `C:/Users/你的用户名/AppData/Roaming/` 和 `C:/Users/你的用户名/AppData/Local/` 下创建配置文件夹 `BleHelper`, 
如果在使用本应用时遇到 `设置` 中更改选择后在下次启动时失效、出现无法切换语言等问题，请右键选择 `以管理员身份运行` 打开一次本应用。
如果编译时出现上述问题，请 `以管理员身份运行` 打开 `Qt Creator`. 

## 编译说明


使用 **Qt Creator (推荐 13.0.1以上)** 打开顶层 [CMakeLists.txt](./CMakeLists.txt)

**MacOS** 请给整个项目路径权限，不然可能会导致编译失败，缺少权限

### 脚本说明


1. **Script-UpdateTranslations**

   用于更新 **ts** 与 **qm** 文件，当你的代码添加了 `tr` 或者 `qsTr` 函数后，执行这个脚本会更新 **ts** 文件，然后编写翻译后，再执行这个脚本，**qm** 文件会更新生效

2. **Script-DeployRelease**

   执行 **Qt** 的 **windeployqt** 或 **macdeployqt** 命令，这个脚本只在 **Windows** 与 **MacOS** 才有，**Linux** 不支持
