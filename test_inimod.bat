@echo off

chcp 65001

set Exe=IniMod64.exe
set TestFile1=test1.ini
set TestFile2=test2.ini
set TestFiles=%TestFile1% %TestFile2% test*.ini
set UnicodeStr="łóńążśćĘŁÓŚĆ - Αποσύμπλεξη - Аутоматски - 自動的に"

echo( > %TestFile1%
echo( > %TestFile2%


%Exe% w %TestFiles% -s "Section1  " -k Key1 -v Value1
%Exe% w %TestFiles% -s Section1 -k Key2 -v Value2
%Exe% w %TestFiles% -s Section1 -k Key3 -v Value3
%Exe% w %TestFiles% -s Section1 -k KeyUnicode -v %UnicodeStr%
%Exe% w %TestFiles% -s Section1 -k "some key with spaces" -v " some value"

%Exe% w %TestFiles% -s Section2 -k Key1 -v Value1
%Exe% w %TestFiles% -s Section2 -k Key2 -v Value2
%Exe% w %TestFiles% -s Section2 -k Key3 -v Value3

%Exe% RemoveFileComment %TestFiles%
%Exe% wfc %TestFiles% -c "----------------------------"
%Exe% wfc %TestFiles% -c "File comment - line 1" -x 2
%Exe% wfc %TestFiles% -c "File comment - line 2" -x 2
%Exe% wfc %TestFiles% -c "File comment - line 3" -x 2
%Exe% wfc %TestFiles% -c "File comment - line 4" -x 2
%Exe% wfc %TestFiles% -c "----------------------------"




pause
