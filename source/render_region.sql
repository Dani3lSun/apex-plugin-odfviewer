/*-------------------------------------
 * ODF Viewer Functions
 * Version: 1.0 (10.08.2015)
 * Author:  Daniel Hochleitner
 *-------------------------------------
*/
FUNCTION render_odf(p_region              IN apex_plugin.t_region,
                    p_plugin              IN apex_plugin.t_plugin,
                    p_is_printer_friendly IN BOOLEAN)
  RETURN apex_plugin.t_region_render_result IS
  -- plugin attributes
  l_blob_column     VARCHAR2(100) := p_region.attribute_01;
  l_filename_column VARCHAR2(100) := p_region.attribute_02;
  l_err_text_column VARCHAR2(500) := p_region.attribute_03;
  -- other variables
  l_region_id         VARCHAR2(100);
  l_column_value_list apex_plugin_util.t_column_value_list2;
  l_blob_no           PLS_INTEGER;
  l_filename_no       PLS_INTEGER;
  l_blob_value        BLOB;
  l_filename_value    VARCHAR2(500);
  l_clob_base64       CLOB;
  l_inline_string     CLOB;
  l_file_ending       VARCHAR2(100);
  l_mime_type         VARCHAR2(100);
  -- vars vor clob splitting
  l_offset      NUMBER := 1;
  l_amount      NUMBER := 32767;
  l_length      NUMBER;
  l_char_string VARCHAR2(32767);
  --
BEGIN
  -- set variables
  l_region_id := apex_escape.html_attribute(p_region.static_id || '_odf');
  --
  -- add webodf js
  apex_javascript.add_library(p_name           => 'webodf',
                              p_directory      => p_plugin.file_prefix,
                              p_version        => NULL,
                              p_skip_extension => FALSE);
  --
  -- Get Data from Source
  l_column_value_list := apex_plugin_util.get_data2(p_sql_statement  => p_region.source,
                                                    p_min_columns    => 2,
                                                    p_max_columns    => 2,
                                                    p_component_name => p_region.name);
  --
  -- Get columns and validate
  l_blob_no     := apex_plugin_util.get_column_no(p_attribute_label   => 'BLOB Content',
                                                  p_column_alias      => l_blob_column,
                                                  p_column_value_list => l_column_value_list,
                                                  p_is_required       => TRUE,
                                                  p_data_type         => apex_plugin_util.c_data_type_blob);
  l_filename_no := apex_plugin_util.get_column_no(p_attribute_label   => 'Filename',
                                                  p_column_alias      => l_filename_column,
                                                  p_column_value_list => l_column_value_list,
                                                  p_is_required       => TRUE,
                                                  p_data_type         => apex_plugin_util.c_data_type_varchar2);
  --
  -- get value from sql query
  -- Content in BLOB
  l_blob_value := l_column_value_list(l_blob_no).value_list(1).blob_value;
  -- Filename in varchar2
  l_filename_value := l_column_value_list(l_filename_no).value_list(1)
                      .varchar2_value;
  -- extract filetype from filename
  l_file_ending := nvl(lower(substr(l_filename_value,
                                    instr(l_filename_value,
                                          '.',
                                          -1) + 1)),
                       'xxx');
  --
  -- render only when correct filetype
  IF l_file_ending IN ('ods',
                       'odt',
                       'odp',
                       'odg',
                       'odf') THEN
    -- set correct mimetype for data-uri
    IF l_file_ending = 'odt' THEN
      l_mime_type := 'application/vnd.oasis.opendocument.text';
    ELSIF l_file_ending = 'ods' THEN
      l_mime_type := 'application/vnd.oasis.opendocument.spreadsheet';
    ELSIF l_file_ending = 'odp' THEN
      l_mime_type := 'application/vnd.oasis.opendocument.presentation';
    ELSIF l_file_ending = 'odg' THEN
      l_mime_type := 'application/vnd.oasis.opendocument.graphics';
    ELSIF l_file_ending = 'odf' THEN
      l_mime_type := 'application/vnd.oasis.opendocument.formula';
    END IF;
    --
    -- add div for webodf
    sys.htp.p('<div id="' || l_region_id || '"></div>');
    --
    -- BLOB2CLOB Base64
    IF l_blob_value IS NOT NULL THEN
      l_clob_base64 := apex_web_service.blob2clobbase64(p_blob => l_blob_value);
      -- escape chars
      l_clob_base64 := REPLACE(REPLACE(REPLACE(l_clob_base64,
                                               chr(10),
                                               ''),
                                       chr(13),
                                       ''),
                               chr(9),
                               '');
    END IF;
    --
    -- inline js string for webodf
    l_inline_string := '<script type="text/javascript">' || chr(10);
    l_inline_string := l_inline_string || 'function init_odf() { ';
    l_inline_string := l_inline_string ||
                       'var odfelement = document.getElementById("' ||
                       l_region_id || '"),';
    l_inline_string := l_inline_string ||
                       'odfcanvas = new odf.OdfCanvas(odfelement);';
    l_inline_string := l_inline_string || chr(10) ||
                       'odfcanvas.load("data:' || l_mime_type || ';base64,' ||
                       l_clob_base64 || '"); ' || chr(10) || '}' || chr(10);
    l_inline_string := l_inline_string || '</script>';
    --
    -- split clob into 32k varchar2 parts (can be very big) and write to http
    l_length := dbms_lob.getlength(l_inline_string);
    -- Loop over clob
    WHILE l_offset < l_length LOOP
      l_char_string := dbms_lob.substr(lob_loc => l_inline_string,
                                       amount  => l_amount,
                                       offset  => l_offset);
      --
      htp.prn(l_char_string);
      --
      l_offset := l_offset + l_amount;
      --
    END LOOP;
    -- call the webodf function onload
    apex_javascript.add_onload_code(p_code => 'init_odf()');
    -- if wrong filetype, print div with err msg
  ELSE
    --
    -- add div for err msg
    sys.htp.p('<div id="' || l_region_id || '"><p>' || l_err_text_column ||
              '</div>');
  END IF;
  --
  RETURN NULL;
  --
END render_odf;