/**
 * veloceExcelExport 그리드 공통 스타일 적용
 * @param sSelector (필수) - 그리드
 * oOptions (선택) - fileName(파일명)
 * @returns
 */
function veloceExcelExport(sSelector ,oOptions)
{
	
	oOptions = oOptions || {};
    oOptions.get = function(key, value) 
    {
    	return this[key] === undefined ? value : this[key];
    };
    
    var sFileName = "veloceExcelExport.xlsx" ;
    if(oOptions.fileName!=undefined)
    {
    	sFileName = oOptions.fileName ;
	 }
    
    sSelector.exportGrid(
    {
	    type: "excel",
	    target: "local",
	    fileName:sFileName,
	    showProgress: true,
	    applyDynamicStyles: true, 
	    progressMessage: "excel Export 중입니다..",
	    indicator: true,
	    header: true,
	    footer: true,
	    compatibility: true,
	    done: function () { 
	        argoAlert("excel export 완료되었습니다.");
	    }
	});
}

/**
 * EXCEL IMPORT 기능 연결처리
 * @param String sSelector (필수) - EXCEL File선택 버튼ID
 * @param gridView gridView (필수) - EXCEL File 바인딩 대상 그리드 
 
 * {} oOptions(필수) - excelFilePath :선택파일 표시될 input box id
 					 isSetColumns   :그리드 Columns 및 Fields 생성할지 여부 /true 이면 엑셀 Sheet의 첫로우를 읽어 생성함
 					 startRowIndex  :데이터 첫로우 위치 , 첫로우가 타이틀 부분일 경우 1로 지정
 					 fillMode : defalut (set) / 데이터 채움모드, set, append, inser, update
  					  
 * e.g veloceSetExcelImport('excelImport',gridView,{excelFilePath:'excelFilePath',isSetColumns:true ,startRowIndex:1});
 *   
 */
 var g_ExcelOptions  ; //EXCEL Import 변수사용을 위해
function veloceSetExcelImport(sSelector , oGridView, oOptions) 
{
 
 	if (typeof sSelector == 'string') 
 	{
        if(sSelector.indexOf("#") != 0) sSelector = "#" + sSelector;
    }
 	
	oOptions = oOptions || {};
    oOptions.get = function(key, value) 
    {
    	return this[key] === undefined ? value : this[key];
    };
    
    g_ExcelOptions = oOptions ;

 	//  선택파일 표시할 INPUT BOX
 	var sExcelFile = '#'+oOptions.excelFilePath ;
  	
 	$(sSelector).change(function()
 	{
 		var sFile = this.value ;
        var RegExtFilter = /\.(xlsx)$/i;
  	   
        if (sFile.match(RegExtFilter) == null)
        {
  	    	argoAlert("엑셀파일(.xlsx)을 선택하세요");
  	    	return;
  	    }
 		
 		$(sExcelFile).prop('value', sFile);
 		veloceExcelImport(this, oGridView);

 	});

}

  function veloceExcelImport(pObj, oGridView) 
  {
	  	var files = pObj.files;
  	    var i, f;
  	    for (i = 0, f = files[i]; i != files.length; ++i) 
  	    {
  	        var reader = new FileReader();
  	        var name = f.name;
  	   
  	        reader.onload = function (e) 
  	        {
  	            var data = e.target.result;
  	 
  	            var arr = _fixdata(data);
  	            workbook = XLSX.read(btoa(arr), { type: 'base64' });
  	 
  	            _veloceProcessWb(workbook,oGridView);
    	    };
  	        //reader.readAsBinaryString(f);
  	        reader.readAsArrayBuffer(f);  	 
  	    }  	
  }

/////EXCEL IMPORT 관련 내부 프로세스  /////////////////////////
function _fixdata(data) 
{
    var o = "", l = 0, w = 10240;
    for (; l < data.byteLength / w; ++l) o += String.fromCharCode.apply(null, new Uint8Array(data.slice(l * w, l * w + w)));
    o += String.fromCharCode.apply(null, new Uint8Array(data.slice(l * w)));
    return o;
}
 
function _veloceProcessWb(wb,oGridView) 
{
    var output = "";
 
    output = _veloceToJson(wb);
    var sheetNames = Object.keys(output);
 
    if (sheetNames.length > 0) 
    {
        var colsObj = output[sheetNames][0];
        
        if (colsObj) 
        {
        	var columns	= _veloceSetFieldsSetColumns(colsObj, oGridView);
        	for (var index in output[sheetNames])
        	{
        		if (index == 0)
        			continue;
        		
        		//oGridView.add(output[sheetNames][index]);
        		var datas	= output[sheetNames][index];
        		var result	= {};
        		
        		datas			= Object.values(datas);
        		result["recid"]	= index - 1;
        		
        		for (var i = 0; i < columns.length; i++)
        		{
        			var column		= columns[i];
        			var data		= "";
        			if (datas.length > i)
        				 data		= datas[i];
        			
        			result[column.field]	= data;
        		}
        		
        		oGridView.add(result);
        	}
        }
    }
}
 
function _veloceSetFieldsSetColumns(colsObj, oGridView) 
{
    var fields 	= [];
    var columns = [];
 
    var colNames = Object.values(colsObj);
 
    for (var i = 0 ; i < colNames.length ; i++) 
    {
    	var field = {};
        field.fieldName = colNames[i];
        fields.push(field);
        
        var column = {} ;
        column.field 	= field.fieldName;
        column.caption 	= field.fieldName;
        column.size		= "80px";
        columns.push(column);
    }
    
    return columns;
}
 
function _veloceToJson(workbook) 
{
    var result = {};
    workbook.SheetNames.forEach(function (sheetName) 
    {
        var roa = XLSX.utils.sheet_to_row_object_array(workbook.Sheets[sheetName], { header: "A" });
        if (roa.length > 0) 
        {
            result[sheetName] = roa;
        }
    });
    
    return result;
}