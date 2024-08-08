/*
 *  jQuery table2excel - v1.1.1
 *  jQuery plugin to export an .xls file in browser from an HTML table
 *  https://github.com/rainabba/jquery-table2excel
 *
 *  Made by rainabba
 *  Under MIT License
 */
//table2excel.js
;(function ( $, window, document, undefined ) {
    var pluginName = "table2excel",

    defaults = {
        exclude: ".noExl",
        name: "Table2Excel",
        filename: "table2excel",
        fileext: ".xls",
        exclude_img: true,
        exclude_links: true,
        exclude_inputs: true,
        
        // 20230711 jslee 헤더가 여러 줄인 엑셀 출력을 위한 변수 선언 
        headerCnt : 1
    };

    // The actual plugin constructor
    function Plugin ( element, options ) {
            this.element = element;
            this.settings = $.extend( {}, defaults, options );
            this._defaults = defaults;
            this._name = pluginName;
            this.init();
    }

    Plugin.prototype = {
        init: function () {
            var e = this;
            
            
            var utf8Heading = "<meta http-equiv=\"content-type\" content=\"application/vnd.ms-excel; charset=UTF-8\">";
            e.template = {
                head: "<html xmlns:o=\"urn:schemas-microsoft-com:office:office\" xmlns:x=\"urn:schemas-microsoft-com:office:excel\" xmlns=\"http://www.w3.org/TR/REC-html40\">" + utf8Heading + "<head><!--[if gte mso 9]><xml><x:ExcelWorkbook><x:ExcelWorksheets>",
                sheet: {
                    head: "<x:ExcelWorksheet><x:Name>",
                    tail: "</x:Name><x:WorksheetOptions><x:DisplayGridlines/></x:WorksheetOptions></x:ExcelWorksheet>"
                },
                mid: "</x:ExcelWorksheets></x:ExcelWorkbook></xml><![endif]--></head><body>",
                table: {
                    head: "<table border='1' bgcolor='#513e4c'><tr><td align='center' colspan='4'><font size='3' color='#ffffff'>"+getFileName(e.settings)+"</font></td></tr></table><table border='1'>",
                    tail: "</table>"
                },
                foot: "</body></html>"
            };

            e.tableRows = [];

            // get contents of table except for exclude
            $(e.element).each( function(i,o) {
                var tempRows = "";
                $(o).find("tr").not(e.settings.exclude).each(function (i,p) {
                    //jslee
                	/*if(i == 0){
                    	tempRows += "<tr height=25 style='height:25.0pt'>";
                    }else{
                    	tempRows += "<tr>";
                    }*/
                	
                	//jslee 설정한 헤더수만큼 생성함. default 1개
                	if(i <= (e.settings.headerCnt-1)){
                    	tempRows += "<tr height=25 style='height:25.0pt'>";
                    }else{
                    	tempRows += "<tr>";
                    }
                	
                    
                    var strV = '"@"';
                    
                    $(p).find("td,th").not(e.settings.exclude).each(function (j,q) { // p did not exist, I corrected
                        
                        var rc = {
                            rows: $(this).attr("rowspan"),
                            cols: $(this).attr("colspan"),
                            flag: $(q).find(e.settings.exclude)
                        };
                        
                        if( rc.flag.length > 0 ) {
                            tempRows += "<td align='center' style='mso-number-format: " + strV + ";'> </td>"; // exclude it!!
                        } else {
                            if( rc.rows  & rc.cols ) {
                                tempRows += "<td align='center' style='mso-number-format: " + strV + ";'>" + $(q).html() + "</td>";
                            } else {
                            	//jslee
                            	if(i <= (e.settings.headerCnt-1)){
                            		tempRows += "<td bgcolor='#d1becc' align='center' style='mso-number-format: " + strV + ";'";
                            	}else{
                            		tempRows += "<td bgcolor='#f9f7f9' align='center' style='mso-number-format: " + strV + ";'";
                            	}
                                if( rc.rows > 0) {
                                    tempRows += " rowspan=\'" + rc.rows + "\' ";
                                }
                                if( rc.cols > 0) {
                                    tempRows += " colspan=\'" + rc.cols + "\' ";
                                }
                            		
                            		
                            	/*if(i==0||i==1){
                            		tempRows += "<td bgcolor='#d1becc' align='center' style='mso-number-format: " + strV + ";'";
                            	}else{
                            		tempRows += "<td bgcolor='#f9f7f9' align='center' style='mso-number-format: " + strV + ";'";
                            	}
                                if( rc.rows > 0) {
                                    tempRows += " rowspan=\'" + rc.rows + "\' ";
                                }
                                if( rc.cols > 0) {
                                    tempRows += " colspan=\'" + rc.cols + "\' ";
                                }*/
                                
                                //jslee
                                if(i <= (e.settings.headerCnt-1)){
                                	tempRows += "/><strong>" + $(q).html() + "</strong></td>";
                                }else{
                                	tempRows += "/>" + $(q).html() + "</td>";
                                }
                                	
                                	
                                /*if(i==0 || i==0){
                                	tempRows += "/><strong>" + $(q).html() + "</strong></td>";
                                }else{
                                	tempRows += "/>" + $(q).html() + "</td>";
                                }*/
                                
                            }
                        }
                    });

                    tempRows += "</tr>";
                    console.log(tempRows);
                    
                });
                // exclude img tags
                if(e.settings.exclude_img) {
                    tempRows = exclude_img(tempRows);
                }

                // exclude link tags
                if(e.settings.exclude_links) {
                    tempRows = exclude_links(tempRows);
                }

                // exclude input tags
                if(e.settings.exclude_inputs) {
                    tempRows = exclude_inputs(tempRows);
                }
                e.tableRows.push(tempRows);
            });

            var chk = e.tableToExcel(e.tableRows, e.settings.name, e.settings.sheetName);

            if(chk == true){
            	//setTimeout("argoPopupClose();",500);
            }
        },

        tableToExcel: function (table, name, sheetName) {
            var e = this, fullTemplate="", i, link, a;

            e.format = function (s, c) {
                return s.replace(/{(\w+)}/g, function (m, p) {
                    return c[p];
                });
            };

            sheetName = typeof sheetName === "undefined" ? "Sheet" : sheetName;

            e.ctx = {
                worksheet: name || "Worksheet",
                table: table,
                sheetName: sheetName
            };

            fullTemplate= e.template.head;

            if ( $.isArray(table) ) {
                for (i in table) {
                      //fullTemplate += e.template.sheet.head + "{worksheet" + i + "}" + e.template.sheet.tail;
                      fullTemplate += e.template.sheet.head + sheetName + i + e.template.sheet.tail;
                }
            }

            fullTemplate += e.template.mid;

            if ( $.isArray(table) ) {
                for (i in table) {
                    fullTemplate += e.template.table.head + "{table" + i + "}" + e.template.table.tail;
                }
            }

            fullTemplate += e.template.foot;

            for (i in table) {
                e.ctx["table" + i] = table[i];
            }
            delete e.ctx.table;

            var isIE = /*@cc_on!@*/false || !!document.documentMode; // this works with IE10 and IE11 both :)            
            //if (typeof msie !== "undefined" && msie > 0 || !!navigator.userAgent.match(/Trident.*rv\:11\./))      // this works ONLY with IE 11!!!
            if (isIE) {
                if (typeof Blob !== "undefined") {
                    //use blobs if we can
                    fullTemplate = e.format(fullTemplate, e.ctx); // with this, works with IE
                    fullTemplate = [fullTemplate];
                    //convert to array
                    var blob1 = new Blob(fullTemplate, { type: "text/html" });
                    window.navigator.msSaveBlob(blob1, getFileName(e.settings) );
                } else {
                    //otherwise use the iframe and save
                    //requires a blank iframe on page called txtArea1
                    txtArea1.document.open("text/html", "replace");
                    txtArea1.document.write(e.format(fullTemplate, e.ctx));
                    txtArea1.document.close();
                    txtArea1.focus();
                    sa = txtArea1.document.execCommand("SaveAs", true, getFileName(e.settings) );
                }

            } else {
                var blob = new Blob([e.format(fullTemplate, e.ctx)], {type: "application/vnd.ms-excel"});
                window.URL = window.URL || window.webkitURL;
                link = window.URL.createObjectURL(blob);
                a = document.createElement("a");
                a.download = getFileName(e.settings);
                a.href = link;

                document.body.appendChild(a);

                a.click();

                document.body.removeChild(a);
            }
            return true;
        }
    };

    function getFileName(settings) {
        return ( settings.filename ? settings.filename : "table2excel" );
    }

    // Removes all img tags
    function exclude_img(string) {
        var _patt = /(\s+alt\s*=\s*"([^"]*)"|\s+alt\s*=\s*'([^']*)')/i;
        return string.replace(/<img[^>]*>/gi, function myFunction(x){
            var res = _patt.exec(x);
            if (res !== null && res.length >=2) {
                return res[2];
            } else {
                return "";
            }
        });
    }

    // Removes all link tags
    function exclude_links(string) {
        return string.replace(/<a[^>]*>|<\/a>/gi, "");
    }

    // Removes input params
    function exclude_inputs(string) {
        var _patt = /(\s+value\s*=\s*"([^"]*)"|\s+value\s*=\s*'([^']*)')/i;
        return string.replace(/<input[^>]*>|<\/input>/gi, function myFunction(x){
            var res = _patt.exec(x);
            if (res !== null && res.length >=2) {
                return res[2];
            } else {
                return "";
            }
        });
    }

    $.fn[ pluginName ] = function ( options ) {
        var e = this;
            e.each(function() {
                if ( !$.data( e, "plugin_" + pluginName ) ) {
                    $.data( e, "plugin_" + pluginName, new Plugin( this, options ) );
                }
            });

        // chain jQuery functions
        return e;
    };

})( jQuery, window, document );