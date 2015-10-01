#Oracle Apex Region Plugin - ODF Viewer
ODF Viewer is a region type plugin that allows you to display ODF files like spreadsheets(.ods) or documents(.odt) with a single sql query.
It is based on JS Framework webodf.js (https://github.com/kogmbh/WebODF).


##Changelog
####Beta - In development

##Install
- Import plugin file "region_type_plugin_de_danielh_odfviewer.sql" from source directory into your application
- (Optional) Deploy the CSS/JS files from "server" directory on your webserver and change the "File Prefix" to webservers folder.

##Plugin Settings
- SQL Query that returns a BLOB value and the filename as text
- Select the BLOB column (Content should be a ODF compatible file, all other kind of files doesn´t work)
- Select the filename column (should contain the whole filename incl. file ending)
- Error Text when filetype is not a ODF file

####Example SQL Query:
```language-sql
SELECT content, (BLOB)
       filename (varchar2)
  FROM file_table
 WHERE id = :P10_FILE_ID
```
##Demo Application
https://apex.oracle.com/pls/apex/f?p=57743:10

##Preview
![](https://github.com/Dani3lSun/apex-plugin-odfviewer/blob/master/preview.png)
---
