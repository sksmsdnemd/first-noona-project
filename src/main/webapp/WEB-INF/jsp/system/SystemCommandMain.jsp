<%@ page language="java" pageEncoding="UTF-8"
	contentType="text/html; charset=UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html lang="ko">
<head>
<jsp:include page="/WEB-INF/jsp/include/common.jsp" flush="true" />

<link rel="stylesheet" href="<c:url value="/css/w2ui-1.5.rc1.css"/>" type="text/css" />
<link rel="stylesheet" href="<c:url value="/css/w2ui-1.5.rc1.min.css"/>" type="text/css" />
<script type="text/javascript" src="<c:url value="/scripts/jquery/jquery-1.11.3.min.js"/>"></script>
<script type="text/javascript" src="<c:url value="/scripts/jquery/jquery-ui.js?ver=2017011301"/>"></script>
<script type="text/javascript" src="<c:url value="/scripts/argojs/argo.alert.js?ver=2017011301"/>"></script>
<script type="text/javascript" src="<c:url value="/scripts/argojs/w2ui-1.5.rc1.js"/>"></script>
<script type="text/javascript" src="<c:url value="/scripts/argojs/w2ui-1.5.rc1.min.js"/>"></script>
<script type="text/javascript" src="<c:url value="/scripts/security/crypto-js.min.js"/>"></script>
<script type="text/javasc1ript" src="<c:url value="/scripts/security/sha512.js"/>"></script>
<style>
#mask {
	position: absolute;
	left: 0;
	top: 0;
	z-index: 100;
	background-color: #ffffff;
	display: none;
}

#loadingImg {
	position: absolute;
	left: 45%;
	top: 50%;
	z-index: 120;
}

.fileCome {
	margin: 30%;
}

.fileName {
	padding-left: 20px;
	color: #000;
}

.fileSize {
	padding-right: 20px;
	float: right;
	color: #000;
}
</style>
<title>파일/Command 업로드 폼</title>
</head>
<script type="text/javascript">

	$(document).ready(function() {
		try{
			util_Browser_Check($(".fileCome"),"dropdownStr");
			fnSysinfoIpList();
			fnInitCtrl();
			fn_fileDragAndDrop();
		}catch(error){
			console.log(error);
		}
	}).ajaxStart(function(){
	   $("#loadingImg").show();
	   wrapWindowByMask();
	}).ajaxStop(function(){
		$("#loadingImg").hide();
		$('#mask').hide();
	}).ajaxError(function(){
		$("#loadingImg").hide();
		$('#mask').hide();
	}).ajaxComplete(function(){
		$("#loadingImg").hide();
		$('#mask').hide();
	});  
	
	function serverBlankCheck(){
		if(url==""){
			argoAlert("접속서버를 선택해주세요.");
			return false;
		}
	}
	
	var url = "";
	var serverPort = document.location.protocol == "http:" ? 7060 : 7070;

	function fnInitCtrl(){
		$("#btnSearch").click(function(){
			serverBlankCheck();
			fn_CommandSearch();
		})
		
		$("#btnDownload").click(function(){
			serverBlankCheck();
			fn_FileDownload();
		});
		
		$("#btnUpload").click(function(){
			serverBlankCheck();
			fn_MutiPartAction();
		});
		$("#s_FindServer").change(function(){
			url = $("#s_FindServer option:selected").val() + ":" + serverPort + "/";
		})
		$("#s_FindPort").keyup(function(){
			url = $("#s_FindServer option:selected").val() + ":" + serverPort + "/";
		})
	}
	
	function wrapWindowByMask(){
		//화면의 높이와 너비를 구한다.
		var maskHeight = $(document).height();  
		var maskWidth = $(window).width();  
		
		//마스크의 높이와 너비를 화면 것으로 만들어 전체 화면을 채운다.
		$('#mask').css({'width':maskWidth,'height':maskHeight});  
		
		//애니메이션 효과 - 일단 1초동안 까맣게 됐다가 80% 불투명도로 간다.
		//$('#mask').fadeIn(1000);      
		$('#mask').fadeTo("slow",0.6);    
	}

	// 접속서버 리스트
	function fnSysinfoIpList() {
		argoJsonSearchList('sysInfo', 'getSysinfoIpList', 's_', null, function(
				data, textStatus, jqXHR) {
			var row = data.SVCCOMMONID.rows;
			var html = "<option value=''>선택하세요!</option>";
			for (var i = 0; i < row.length; i++) {
				var rowi = row[i];
				html += "<option value='"+document.location.protocol+"//"+rowi.systemIp+"'>"+rowi.systemName+"("+rowi.systemIp+")</option>";
			}
			$("#s_FindServer").html(html);
		});
	}

	//조회
	function fn_CommandSearch() {
		var param = {};
		
		param.path = $("#s_FindPath").val();
		param.command = $("#s_FindCommand").val();
		param.url = url + "CommandAction.do";
		param.paramDataType = "json";
		$("#result").val("");
		
		$.ajax({
			url : gGlobal.ROOT_PATH + "/wau/browserCorsProxyF.do",
			type : "POST",
			data : JSON.stringify(param),
			contentType: "application/json; charset=utf-8",
			success : function(data) {
				try{
// 					console.log(data);
					var json = JSON.parse(decodeURI(data));
					var cmd = json.cmd;
					var line = json.line;

					var html = "cmd : " + cmd + "\r\n";
					for (var i = 0; i < line.length; i++) {
						html += line[i] + "\r\n";
					}
					$("#result").val(html);
				}catch(error){
// 					console.log(error);
					$("#result").val("데이터 파싱 에러");
					$("#loadingImg").hide();
					$('#mask').hide();
				}
			},
			error : function(xhr, status, error) {
				console.log("error");
				$("#result").val(JSON.stringify(status, null, '\t') + "\r\n");
			}
		});
	}

	//업로드
	function fn_MutiPartAction() {
 		var formData = new FormData($("#frmFileAdd")[0]);
 		formData.append("url",url+"MutiPartAction.do");
 		for(i=0;i<fileList.length;i++){
			formData.append("fileName",fileList[i]);
 		}
 		
		$("#result").val("");
		$.ajax({
			//url : url+"MutiPartAction.do",
			url : gGlobal.ROOT_PATH + "/wau/browserCorsProxyMultipartF.do",
			type : "POST",
			data: formData,  
			enctype : 'multipart/form-data',
			processData: false,
		    contentType: false,
		    cache: false,
		    timeout: 600000,
			success : function(data) {
				try{
					var result = JSON.parse(decodeURI(data));
					if(result.result == "OK"){
						fileList = [];
						filesName = [];
						filesSize = [];
						$("#fileListArea").html('');
						$(".fileCome").css("display","");
					}
					$("#result").val("RESULT = "+result.result+"\r\nDATA = "+result.data);
				}catch(error){
					$("#result").val("데이터 파싱 에러");
					$("#loadingImg").hide();
					$('#mask').hide();
				}
				
			},error : function(xhr, status, error) {
				console.log("error");
				$("#result").val(JSON.stringify(status, null, '\t')+"\r\n");
			}
		}); 
		var rmObj = form;
		util_Browser_Check(rmObj,"rm");
	}

	function fn_searchEnterkey() {
		if (window.event.keyCode == 13) {
			serverBlankCheck();
			fn_CommandSearch();
		}
	}

	//다운로드
	function fn_FileDownload() {
		$("#frmFileDownload").attr("action", url + "DownLoadAction.do");
		$("#frmFileDownload").submit();
	}
	/*
	 /파일추가
	function fn_fileAdd(obj) {
		var row = $(obj).parent().parent().parent().clone();

		var div = $("<div class='row'>");
		var ul = $("<ul class='search_terms'>");
		var li1 = $("<li>");
		var strong = $("<strong class='title ml20'>");
		var input = $("<input type='file' name='filename'>").css("margin-left",
				"4px");
		var li2 = $("<li>");
		var button = $(
				"<button class='btn_m confirm' onclick='fn_fileDel(this);'>")
				.text("취소");

		li1.append(strong);
		li1.append(input);
		li2.append(button);
		ul.append(li1);
		ul.append(li2);
		div.append(ul);

		$("#frmFileAdd").append(div);
		$(".search_area").css("height",
				(($("#frmFileAdd").children(".row").length * 32) + 130) + "px");
	} */

	//취소
	/* function fn_fileDel(obj) {
		$(obj).parent().parent().parent(".row").remove();

		$(".search_area").css("height",
				(($("#frmFileAdd").children(".row").length * 32) + 130) + "px");
	} */
	
	// 탭 클릭
	function Display_Input_Panel(obj) {
		// 탭 강조 css
		$('.btn_tab').removeClass('confirm');
		$(obj).addClass('confirm');
		
		// 검색 필터 패널 강조 css
		$(".btnPannel").css("display","none");
		$("#"+$(obj).attr("id")+"Btn").css("display","");
		
		// 버튼 강조 css
		$(".search_area").css("display","none");
		$("#"+$(obj).attr("id")+"Panel").css("display","");
	}
	
	// 파일 업로드 드래그 앤 드랍 
	var fileList = [];
	var filesName = [];
	var filesSize = [];
	
	function fn_fileDelete(num){
		fileList.splice(num,1);
		filesName.splice(num,1);
		filesSize.splice(num,1);
		var rmObj = $("#fileListArea").children('.fileList')[num];
		util_Browser_Check(rmObj,"rm");
		//$("#fileListArea").children('.fileList')[num].remove();
		var tag = "";
		if(fileList.length == 0 ){
			$(".fileCome").css("display","");
			return false;
		}
		for(var i=0;i<fileList.length;i++){
			tag += "<div class='fileList'>" +
	                    "<span class='fileName'>"+filesName[i]+"</span>" +
	                    "<span class='fileSize'>"+filesSize[i]+" MB</span>" +
	                    "<img src='../images/icon_delete2.png' onclick='fn_fileDelete("+(i)+");'>" +
	                "</div>";
		}
		$("#fileListArea").html(tag);
		
	}
	
	// 파일 리스트 보여주기
	function fn_fileShowList(files){
		var tag = "";
        for(var i=0; i<files.length; i++){
            var f = files[i];
            var fileSize = (f.size / 1024 / 1024);
            if(fileSize >500){
            	argoAlert(f.name+"파일의 크기는 500MB 초과합니다.</br>500MB 이하의 파일을 올려주세요.");
            	continue;
            }
            fileList.push(f);
            filesSize.push(fileSize < 1 ? fileSize.toFixed(3) : fileSize.toFixed(1));
            filesName.push(f.name);
            
            tag += "<div class='fileList'>" +
                        "<span class='fileName'>"+filesName[filesName.length-1]+"</span>" +
                        "<span class='fileSize'>"+filesSize[filesSize.length-1]+" MB</span>" +
                        "<img src='../images/icon_delete2.png' onclick='fn_fileDelete("+(fileList.length-1)+");'>" +
                    "</div>";
        }
        
        $("#fileListArea").append(tag);
        $(".fileCome").css("display","none");
	}
	
	function fn_fileDragAndDrop(){
		$("#fileName").on("change",function(e){
// 			console.log($(this).val());
			var files = $(this)[0].files;
			if(files != null && files != undefined){
				fn_fileShowList(files);
				
                // 파일 태그 초기화
                var agent = navigator.userAgent.toLowerCase();
                if ( (navigator.appName == 'Netscape' && navigator.userAgent.search('Trident') != -1) || (agent.indexOf("msie") != -1) ){
                    // ie 일때 input[type=file] init.
                    $("#fileName").replaceWith( $("#fileName").clone(true) );
                } else {
                    //other browser 일때 input[type=file] init.
                    $("#fileName").val("");
                }
			}
		})
		$("#fileDrop").on("dragenter", function(e){
	        e.preventDefault();
	        e.stopPropagation();
	    }).on("dragover", function(e){
	        e.preventDefault();
	        e.stopPropagation();
	        $(this).css("background-color", "#b3b0b0");
	    }).on("dragleave", function(e){
	        e.preventDefault();
	        e.stopPropagation();
	        $(this).css("background-color", "#FFF");
	    }).on("drop", function(e){
            e.preventDefault();

            var files = e.originalEvent.dataTransfer.files;
	            if(files != null && files != undefined){
	            	fn_fileShowList(files);
	            }
	            
	            $(this).css("background-color", "#FFF");
	        });
	}
	
</script>

<body>
	<div class="sub_wrap">

		<div id="mask">
			<img alt="loading" id="loadingImg" src="../images/large-loading.gif"
				style="display: none;">
		</div>
		<div class="location">
			<button type="button" id="btnCommandDisplay" class="btn_tab confirm"
				onclick="Display_Input_Panel( this)">커맨드</button>
			<!-- <button type="button" id="btnDBDisplay" class="btn_tab" onclick="Display_Input_Panel( this)">DB</button> -->
			<span class="location_home">HOME</span><span class="step">시스템관리</span><strong
				class="step">시스템커맨드</strong>
		</div>
		<section class="sub_contents">
			<img id="loadingBar" src="../images/large-loading.gif"
				style="display: none;">
			<!-- 커맨드 패널 -->
			<div class="search_area row6" id="btnCommandDisplayPanel">
				<div style="width: 720px; float: left;">
					<iframe id="iframe1" name="iframe1" style="display: none"></iframe>
					<form id="frmFileDownload" method="POST" target="iframe1">
						<div class="row">
							<ul class="search_terms">
								<li><strong class="title ml20">접속서버</strong> 
								<select id="s_FindServer" name="s_FindServer" style="width:300px;" class="list_box">
	                            </select>
							</ul>
						</div>
						<div class="row">
							<ul class="search_terms">
								<li><strong class="title ml20">경로</strong> <input
									type="text" id="s_FindPath" name="path" style="width: 600px;"
									value="/bridgetec/veloce/bin" /></li>
							</ul>
						</div>
						<div class="row">
							<ul class="search_terms">
								<li><strong class="title ml20">명령어</strong> <input
									type="text" id="s_FindCommand" onkeyup="fn_searchEnterkey();"
									name="s_FindCommand" style="width: 600px;" /></li>
							</ul>
						</div>
						<div class="row">
							<ul class="search_terms">
								<li>
									<span style="margin-left: 30px;">리눅스 명령어 ) ls ,find ,grep ,ps ,cp ,mv</span>
								</li>
							</ul>
						</div>
						<div class="row">
							<ul class="search_terms">
								<li>
									<span style="margin-left: 30px;">윈도우 명령어 ) copy ,move, find, dir</span>
								</li>
							</ul>
						</div>
						<div class="row">
							<ul class="search_terms">
								<li><strong class="title ml20">파일이름</strong> <input
									type="text" id="s_FindFileName" name="fileName"
									style="width: 600px;" value="test.txt" /></li>
							</ul>
						</div>
					</form>
					<form id="frmFileAdd" target="ifrmFileAdd">
						<div class="row">
							<ul class="search_terms">
								<li><strong class="title ml20">파일</strong> <input
									type="file" name="fileName" id="fileName" multiple="multiple" /><br /></li>
								<!-- <li>
								<button type="button" class="btn_m confirm"
									onclick="fn_fileAdd(this);">파일추가</button>
							</li> -->
							</ul>
						</div>
					</form>
				</div>
				<div
					style="float: right; width: 400px; position: absolute; display: inline-block;">
					<div id="fileDrop"
						style="border: 1px solid #d3d3d3; color: #8a8a8a; height: 175px; ">
						<span class="fileCome">파일을 끌어 올려주세요.</span>
						<div style="height: 100%; overflow: auto;" id="fileListArea"></div>
					</div>
				</div>
			</div>
			
			<!-- DB패널 -->
			<!-- <div class="search_area row5" style="display:none;" id="btnDBDisplayPanel">
				<div class="row">
					<ul class="search_terms">
						<li><strong class="title ml20">접속서버</strong> <select id="s_DBFindServer" name="s_DBFindServer" style="width:300px;" class="list_box">
                            </select> <input id="s_DBFindServer"
							name="s_DBFindServer" style="width: 300px;" class="list_box"
							value="http://100.100.107.21" /> &nbsp;: &nbsp; <input
							type="text" id="s_DBFindPort" name="s_DBFindPort"
							style="width: 70px;" value="7060" /></li>
					</ul>
				</div>
				<div class="row">
					<ul class="search_terms">
						<li><strong class="title ml20">SID</strong> <input
							type="text" id="s_inpDBSID" name="s_inpDBSID"
							style="width: 700px;" value="" /></li>
					</ul>
				</div>
				<div class="row">
					<ul class="search_terms">
						<li>
							<strong class="title ml20">아이디</strong>
							<input type="text" id="s_inpDBID" name="s_inpDBID" style="width: 700px;">
						</li> 
					</ul>
				</div>
				<div class="row">
					<ul class="search_terms">
						<li>
							<strong class="title ml20">패스워드</strong>
							<input type="password" id="s_inpDBPw" name="s_inpDBPw" style="width: 700px;">
						</li>
					</ul>
				</div>
				
				<div class="row">
					<ul class="search_terms">
						<li>
							<strong class="title ml20">변경 패스워드</strong>
							<input type="password" id="s_inpDBPwChange" name="s_inpDBPwChange" style="width: 301px;">
						</li> 
						<li>
							<strong class="title ml20">패스워드 확인</strong>
							<input type="password" id="s_inpDBPwChangeChk" name="s_inpDBPwChangeChk" style="width: 301px;">
						</li>
					</ul>
				</div>
				
			</div> -->
			
			<div class="btns_top">
				<div id="btnCommandDisplayBtn" class="btnPannel">
					<button type="button" id="btnSearch" class="btn_m search"
						>조회</button>
					<button type="button" id="btnDownload" class="btn_m confirm"
						>다운로드</button>
					<button type="button" id="btnUpload" class="btn_m confirm"
						>업로드</button>
				</div>
			</div>
			<div class="h136">
				<div>
					<textarea id="result" style="width: 100%; height: 600px;" readonly></textarea>
				</div>
			</div>
		</section>
	</div>
</body>
</html>
