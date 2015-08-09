#Oracle Apex Region Plugin - ODF Viewer
ODF Viewer is a region type plugin that allows you to display ODF files like spreadsheets(.ods) or documents(.odt) with a single sql query.
It is based on JS Framework webodf.js (https://github.com/kogmbh/WebODF).


##Changelog
####1.0 - Initial Release

##Install
- Import plugin file "region_type_plugin_de_danielh_odfviewer.sql" from source directory into your application
- (Optional) Deploy the CSS/JS files from "server" directory on your webserver and change the "File Prefix" to webservers folder.

##Plugin Settings
- single row SQL Query that returns a BLOB value
- Select the BLOB column (Content should be a ODF compatible file, all other kind of files doesn´t work)

####Example SQL Query:
```language-sql
SELECT content (BLOB)
  FROM file_table
 WHERE id = :P10_FILE_ID
```
##Demo Application
https://apex.oracle.com/pls/apex/f?p=57743:10

---
