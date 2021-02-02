@echo off
call globals.bat

set Line=--------------------------------------------------------------------------------

set bash=C:\Windows\Sysnative\bash.exe
if not exist %bash% set bash=C:\Windows\system32\bash.exe

echo( > %LicenseFileT%
echo %Line% >> %LicenseFileT%
echo( >> %LicenseFileT%
echo LICENSE >> %LicenseFileT%
echo( >> %LicenseFileT%
%AppExe32Compiled% --license >> %LicenseFileT%



copy %AppExe32Compiled% %AppExe%
%AppExe% --help > %README%
type %LicenseFileT% >> %README%
if exist %PortableFileZip32% del %PortableFileZip32%
%CreatePortableZip32%


copy %AppExe64Compiled% %AppExe%
%AppExe% --help > %README%
type %LicenseFileT% >> %README%
if exist %PortableFileZip64% del %PortableFileZip64%
%CreatePortableZip64%


:: Needed to run 32-bit Linux executable
%bash% -c "sudo service binfmt-support start"

echo ---------------- Linux 32-bit ------------------
copy %AppExe32CompiledLinux% %AppExeLinux%
%bash% -c "./%AppExeLinux% --help > %README%"
type %LicenseFileT% >> %README%
if exist %PortableFileZipLinux32% del %PortableFileZipLinux32%
%CreatePortableZipLinux32%


echo ---------------- Linux 64-bit ------------------
copy %AppExe64CompiledLinux% %AppExeLinux%
%bash% -c "./%AppExeLinux% > %README%"
type %LicenseFileT% >> %README%
if exist %PortableFileZipLinux64% del %PortableFileZipLinux64%
%CreatePortableZipLinux64%




del %AppExe%
del %AppExeLinux%
del %LicenseFileT%


pause