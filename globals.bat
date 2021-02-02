@echo off

set PATH=%JP_MyToolsDir%;%JP_ToolsDir%;%PATH%

rem --------------- common -----------------
set AppName=IniMod
set AppVer=1.0
set AppDate=2021.02.02
set AppFullName=%AppName% %AppVer%
set AppName_=IniMod
set AppExe=IniMod.exe
set AppExeLinux=inimod
set AppUrl=https://www.pazera-software.com/products/inimod/
set README=README.txt
set LicenseFileT=%AppName_%_License.txt

::set ArchiveSrc=%AppFullName%_Project.7z


rem ----------------- Windows 32 bit ---------------------
set AppExe32Compiled=IniMod32.exe
set PortableFileZip32=%AppName_%_win32.zip
set CreatePortableZip32=7z a -tzip -mx=9 %PortableFileZip32% %AppExe% %README%


rem ----------------- Windows 64 bit ---------------------
set AppExe64Compiled=IniMod64.exe
set PortableFileZip64=%AppName_%_win64.zip
set CreatePortableZip64=7z a -tzip -mx=9 %PortableFileZip64% %AppExe% %README%


rem ----------------- Linux 32 bit ---------------------
set AppExe32CompiledLinux=inimod32
set PortableFileZipLinux32=%AppName_%_linux32.zip
set CreatePortableZipLinux32=7z a -tzip -mx=9 %PortableFileZipLinux32% %AppExeLinux% %README%


rem ----------------- Linux 64 bit ---------------------
set AppExe64CompiledLinux=inimod64
set PortableFileZipLinux64=%AppName_%_linux64.zip
set CreatePortableZipLinux64=7z a -tzip -mx=9 %PortableFileZipLinux64% %AppExeLinux% %README%

