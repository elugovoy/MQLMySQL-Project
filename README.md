![FxCodex Laboratory](https://github.com/elugovoy/Common/raw/master/img/FxCodex-Logo.png)
# MQLMySQL Library
The problem of interaction of MQL with databases is not new, however it's still relevant. Use of databases can greatly enhance the possibilities of MetaTrader: storage and analysis of the price history, copying trades from one trading platform to another, providing quotes/trades in real time, heavy analytical computations on the server side and/or using a schedule, monitoring and remote control of accounts using web technologies. See article "[How to Access MySQL Databases from MQL5 (MQL4)](https://www.mql5.com/en/articles/932)"".
The MQLMySQL library is a solution for accessing MySQL database from MQL4/MQL5 side.
**If you:**
  - work with MetaTrader 4 (32-bit) you can use [this "MQL4"](https://github.com/elugovoy/MQLMySQL-Project/tree/master/MQL4) package (TRM included)
  - work with MetaTrader 5 (64-bit) and love "*old school*" development, you can use [this "MQL5 old school"](https://github.com/elugovoy/MQLMySQL-Project/tree/master/MQL5%20old%20school) package where simply set of functions implemented (TRM included)
  - work with MetaTrader 5 (64-bit) and love "*CLASSic*" development, you can use [this "MQL5 classes"](https://github.com/elugovoy/MQLMySQL-Project/tree/master/MQL5%20classes) package where implemented classes to work with database (TRM included)
  - very improved developer and want to extend library functionality by yourself - you would need:
    - MS Visual Studio 2017 project [MQLMySQL](https://github.com/elugovoy/MQLMySQL-Project/tree/master/MQLMySQL) to compile MQLMySQL.DLL for x86 and x64 platforms, also this project depends on MySQL headers you can find below
    - [MySQL-5.7.28 x32](https://github.com/elugovoy/MQLMySQL-Project/tree/master/MySQL-5.7.28%20x32) - MySQL v5.7.28 header files to compile DLL for x86 platforms
    - [MySQL-8.0.18 x64](https://github.com/elugovoy/MQLMySQL-Project/tree/master/MySQL-8.0.18%20x64) - MySQL v8.0.18 header files to compile DLL for x64 platforms
  - appreciate work I've done and want to support me with this and other related projects - I accept [PayPal donation](https://www.paypal.me/elugovoy)

**This solution is developed to be free** (c) Eugene Lugovoy

### What's new in version 3.0

  - Concurrently open connections - up to 32
  - Concurrently open cursors - up to 256
  - Length of SQL query - up to 64Kb
  - Length of string field value - up to 32Kb
  - Support x86 and x64 platforms
  - Support UTF-8 string conversion
  - Support DML/DDL/DCL command execution
  - Support cursors for SELECT commands to retreive data from database 

### Installation

The structure of ["MQL4"](https://github.com/elugovoy/MQLMySQL-Project/tree/master/MQL4), ["MQL5 old school"](https://github.com/elugovoy/MQLMySQL-Project/tree/master/MQL5%20old%20school) and ["MQL5 classes"](https://github.com/elugovoy/MQLMySQL-Project/tree/master/MQL5%20classes) directories are similar to MetaTrader terminal's directory structure, so you just need to:
  - Setup your MySQL/MariaDB database
  - Make sure you can connect to database by using standard tools (like HeidiSQL or so)
  - Download sources you need and copy them into MetaTrader **Data Folder**
*Note: If you have UAC disabled on your OS, the **Data Folder** could be similar to Terminal Folder. But if UAC is enabled - you can open Data Folder from terminal by pressing **Ctrl+Shift+D** or from main menu **File->Open Data Folder***
  - Open **Scripts\MyConnection.ini** and edit database credentials to connect to your database
  - Run MetaTrader terminal and try to run scripts MySQL-XXX on any chart.

When all tests are done successful, you can build your own functionality.

### Useful Links
The article "How to Access MySQL Databases from MQL5 (MQL4)" - [https://www.mql5.com/en/articles/932](https://www.mql5.com/en/articles/932)  

Discussion forum can help to solve your difficulties - [https://www.mql5.com/en/forum/37085](https://www.mql5.com/en/forum/37085)  

My Profile at MQL5 Community - [https://www.mql5.com/en/users/elugovoy](https://www.mql5.com/en/users/elugovoy)  

To support over PayPal - [paypal.me/elugovoy](https://www.paypal.me/elugovoy)  


