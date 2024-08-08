<%@ page language="java" pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<!DOCTYPE html>
<html lang="ko">
<head>
<jsp:include page="/WEB-INF/jsp/include/common.jsp" flush="true" />
<link rel="stylesheet" href="<c:url value="/css/argo.main.css?ver=20170103"/>" type="text/css" />
<link rel="stylesheet" href="<c:url value="/css/veloce.svrmon.css"/>" type="text/css" />

<script>
	var dataArray = new Array();
	var serverPort = document.location.protocol == "http:" ? 7060 : 7070;

	$(document).ready(function() {
		fnInitCtrl();
		fnGetSysInfo();
		fnInitGrid();
		fnSearchList();
	});

	function fnInitCtrl() {
		$("#autoRefresh").change(function()	{	 	
			if($("input:checkbox[id='autoRefresh']").is(":checked")){
				var delayTime = $("#refreshValue option:selected").val();	
				playInter("Y", delayTime);
			}
		});
	}
	
	function fnGetSysInfo() {
		$(".resultData").empty();
		
		argoJsonSearchList('sysGroup', 'getSysIpList', 's_', null, function (data, textStatus, jqXHR) {
			try {
				var objHtml = "";
				
				objHtml += "<tr>";
				objHtml += "<th style='padding:0px; text-align:center;'>시스템</th>";
				objHtml += "<th style='padding:0px; text-align:center;'>프로세스</th>";
				objHtml += "<th style='padding:0px; text-align:center;'>CPU</th>";
				objHtml += "<th style='padding:0px; text-align:center;'>MEMORY</th>";
				objHtml += "<th style='padding:0px; text-align:center;'>HDD</th>";
				objHtml += "</tr>";
				
				if(data.isOk()) {
					
					$.each(data.getRows(), function( index, row ) {
						var url = document.location.protocol+"//"+row.code +":"+serverPort+"/"+ "GetServerInfo.do" ;
						var param = {
							index:String(index),
							paramDataType:"json",
							url:url
						};
						
						$.ajax({
							url : gGlobal.ROOT_PATH + "/wau/browserCorsProxyF.do",
							type : "POST",
							async: false,
							data : JSON.stringify(param),
							contentType: "application/json; charset=utf-8",
							success : function(jsonData) {
// console.log(JSON.parse(decodeURI(jsonData)));
								if(JSON.parse(decodeURI(jsonData)).result != "NG") {
									var cpuVal = JSON.parse(decodeURI(jsonData)).CPU;
									var memVal = JSON.parse(decodeURI(jsonData)).MEMORY;
									
									// hddPopLayr 삭제
									$("#hddPopLayer_"+index).remove();
									
									// hddPopLayer 생성 후 section에 추가
									var div = document.createElement("div");
									div.setAttribute("id", "hddPopLayer_"+index);
									div.setAttribute("style", "display: none;");
									document.getElementById("section").appendChild(div);

									// hddPopLayer 내용 생성 시작
									var hddPopHtml = "";
									hddPopHtml += "<table class='input_table2' style='width:300px;'>";
									hddPopHtml += "<tr>";
									hddPopHtml += "<th style='width:40%; padding:0px; text-align:center;'>HDD</th>";
									hddPopHtml += "<th style='width:60%; padding:0px; text-align:center;'>사용량</th>";
									hddPopHtml += "</tr>";
									
									var totHDD = 0;
									var hddWarn = false;
									$.each(JSON.parse(decodeURI(jsonData)).DISK, function( i, p ) {
										totHDD += parseInt(p.DISKVALUE);
										
										if(parseInt(p.DISKVALUE) >= 90) { hddWarn = true; }
										
										hddPopHtml += "<tr>";
										hddPopHtml += "<td>"+p.DISKNAME+"</td>";
										hddPopHtml += "<td>";
										if(parseInt(p.DISKVALUE) >= 90) {
											hddPopHtml += "<div class='bar_max bar_h20 bar_red_bgcolor'>";
											hddPopHtml += "<div class='bar_per bar_red_color' style='width:"+p.DISKVALUE+"%;'></div>";
										} else {
											hddPopHtml += "<div class='bar_max bar_h20 bar_hdd_bgcolor'>";
											hddPopHtml += "<div class='bar_per bar_hdd_color' style='width:"+p.DISKVALUE+"%;'></div>";
										}
										hddPopHtml += "<div class='bar_str' style='padding-top:1px;'>"+p.DISKVALUE+"%</div>";
										hddPopHtml += "</div>";
										hddPopHtml += "</td>";
										hddPopHtml += "</tr>";
									});
									totHDD = Math.round(totHDD / JSON.parse(decodeURI(jsonData)).DISK.length);
									
									hddPopHtml += "</table>";
									$("#hddPopLayer_"+index).append(hddPopHtml);
									// hddPopLayer 내용 생성 종료
							
									objHtml += "<tr>";
									objHtml += "<td>"+row.systemName+" ("+row.code+")</td>";
									
									// 프로세스 정보
									objHtml += "<td>";
									$.each(JSON.parse(decodeURI(jsonData)).PROCESS, function( idx, item ) {
										var procTy = "";
										var procSt = "";
										if(item.nHAMode == "0") {
											procTy = "standalone";
										} else if(item.nHAMode == "1") {
											procTy = "active";
										} else if(item.nHAMode == "2") {
											procTy = "standby";
										}
										if(item.nProcessState == "1") {
											procSt = "running";
										} else if(item.nProcessState == "2") {
											procSt = "down";
										} else if(item.nProcessState == "3") {
											procSt = "userStop";
										}
										objHtml += "<span class='proc_btn "+procTy+" "+procSt+"'>"+item.szProcessName.split("_")[1]+"</span>";
									});
									objHtml += "</td>";
									
									// CPU 정보
									objHtml += "<td>";
									if(cpuVal >= 90) {
										objHtml += "<div class='bar_max bar_h40 bar_red_bgcolor'>";
										objHtml += "<div class='bar_per bar_red_color' style='width:"+cpuVal+"%;'></div>";
									} else {
										objHtml += "<div class='bar_max bar_h40 bar_cpu_bgcolor'>";
										objHtml += "<div class='bar_per bar_cpu_color' style='width:"+cpuVal+"%;'></div>";
									}
									objHtml += "<div class='bar_str' style='padding-top:10px;'>"+cpuVal+"%</div>";
									objHtml += "</div>";
									objHtml += "</td>";
									
									// MEMORY 정보
									objHtml += "<td>";
									if(memVal >= 90) {
										objHtml += "<div class='bar_max bar_h40 bar_red_bgcolor'>";
										objHtml += "<div class='bar_per bar_red_color' style='width:"+memVal+"%;'></div>";
									} else {
										objHtml += "<div class='bar_max bar_h40 bar_mem_bgcolor'>";
										objHtml += "<div class='bar_per bar_mem_color' style='width:"+memVal+"%;'></div>";
									}
									objHtml += "<div class='bar_str' style='padding-top:10px;'>"+memVal+"%</div>";
									objHtml += "</div>";
									objHtml += "</td>";
									
									// HDD 정보
									objHtml += "<td onmouseover='fnOpenHddLayer("+index+",event);' onmouseout='fnCloseHddLayer("+index+");' style='cursor:pointer;'>";
									if(hddWarn) {
										objHtml += "<div class='bar_max bar_h40 bar_red_bgcolor'>";
										objHtml += "<div class='bar_per bar_red_color' style='width:"+totHDD+"%;'></div>";
										objHtml += "<div class='bar_str' style=padding-top:2px;'>"+totHDD+"%<br>* 90% 이상 HDD 존재</div>";
									} else {
										objHtml += "<div class='bar_max bar_h40 bar_hdd_bgcolor'>";
										objHtml += "<div class='bar_per bar_hdd_color' style='width:"+totHDD+"%;'></div>";
										objHtml += "<div class='bar_str' style=padding-top:10px;'>"+totHDD+"%</div>";
									}
									objHtml += "</div>";
									objHtml += "</td>";
									objHtml += "</tr>";
								} else {
									objHtml += "<tr>";
									objHtml += "<td>"+row.systemName+" ("+row.code+")</td>";
									objHtml += "<td colspan='4' style='text-align:center; height:42px;'>WAU 미설치 서버입니다.</td>";
									objHtml += "</tr>";
								}
								
							},
							error : function(xhr, status, error) {
								objHtml += "<tr>";
								objHtml += "<td>"+row.systemName+" ("+row.code+")</td>";
								objHtml += "<td colspan='4' style='text-align:center; height:42px;'>서버 통신 장애!!</td>";
								objHtml += "</tr>";
							}
						});
					});
					
				}
				
				$(".resultData").append(objHtml);
			} catch(e) {
				console.log(e);			
			}
		});
		
		var curDt = argoCurrentDateToStr();
		var curTm = argoCurrentTimeToStr();
		var updateTm = curDt.substr(0, 4) + "-" + curDt.substr(4, 2) + "-" + curDt.substr(6, 2) + " "
					 + curTm.substr(0, 2) + ":" + curTm.substr(2, 2) + ":" + curTm.substr(4, 2);

		$("#updateTime").text(updateTm);
		
		if($("input:checkbox[id='autoRefresh']").is(":checked")) {
			var delayTime = $("#refreshValue option:selected").val();	
			playInter("Y", delayTime);
		} else {
			playInter("N");
		}
	}
	
	// 타이머
	var timer;
	function playInter(playFlag, delay) {
		if (playFlag == "Y") {
			clearInterval(timer);
			timer = setInterval("fnGetSysInfo(); fnSearchList();", delay);
		} else {
			clearInterval(timer);
		}
	}
	
	function fnOpenHddLayer(idx, e) {
		var sWidth = window.innerWidth;
		var sHeight = window.innerHeight;

		var oWidth = $("#hddPopLayer_"+idx).width();
		var oHeight = $("#hddPopLayer_"+idx).height();
		
		// 레이어가 나타날 위치를 셋팅한다.
		var divLeft = e.clientX;
		var divTop = e.clientY;
		
		// 레이어가 화면 크기를 벗어나면 위치를 바꾸어 배치한다.
		if( divLeft + oWidth > sWidth ) { divLeft -= oWidth; }
		if( divTop + oHeight > sHeight ) { divTop -= oHeight; }
		
		// 레이어 위치를 바꾸었더니 상단기준점(0,0) 밖으로 벗어난다면 상단기준점(0,0)에 배치하자.
		if( divLeft < 0 ) divLeft = 0;
		if( divTop < 0 ) divTop = 0;
		
		$('#hddPopLayer_'+idx).css({
			"top": divTop,
			"left": divLeft,
			"position": "absolute"
		}).show();
	}
	
	function fnCloseHddLayer(idx) {
		$("#hddPopLayer_"+idx).hide();
	}

	function fnInitGrid() {
		$('#gridList').w2grid({ 
	        name: 'grid', 
	        show: {
	            lineNumbers: true,
	            footer: false,
	            selectColumn: false
	        },
	        multiSelect: false,
	        columns: [  
				  { field: 'recid', 		caption: 'recid', 		size: '0%', 	sortable: true, attr: 'align=center' }
				, { field: 'errDate', 		caption: '발생일', 		size: '15%', 	sortable: true, attr: 'align=center' }
				, { field: 'errGradeName', 	caption: '등급', 			size: '6%', 	sortable: true, attr: 'align=center' }
				, { field: 'systemName', 	caption: '시스템명', 		size: '12%', 	sortable: true, attr: 'align=center' }
				, { field: 'processName', 	caption: '프로세스', 		size: '8%', 	sortable: true, attr: 'align=center' }
				, { field: 'errMsg', 		caption: '장애메시지', 		size: '59%', 	sortable: true, attr: 'align=left'   }
	        ],
	        records: dataArray
	    });
		
		w2ui['grid'].hideColumn('recid');
	}

	function fnSearchList() {
		w2ui.grid.lock('조회중', true);
		
		var cDtStr = argoCurrentDateToStr();
		var param = {"iSPageNo":3, "iEPageNo":3, "findSErrDate":cDtStr+"000000", "findEErrDate":cDtStr+"235959"};
		argoJsonSearchList('errCode', 'getCurErrList', 's_', param, function (data, textStatus, jqXHR) {
			try{
				if (data.isOk()) {
					w2ui.grid.clear();
					
					if (data.getRows() != "") { 
						dataArray = new Array();
						$.each(data.getRows(), function( index, row ) {
							gObject = {
								  "recid" 			: index
								, "errGradeName" 	: row.errGradeName
								, "systemName" 		: row.systemName
								, "processName" 	: row.processName
								, "errDate" 		: fnStrMask("DHMS", row.errDate)
								, "errMsg" 			: row.errMsg
							};
										
							dataArray.push(gObject);
						});
						
						w2ui['grid'].add(dataArray);
					}
				}
				
				w2ui.grid.unlock();
			} catch(e) {
				console.log(e);			
			}
		});
	}
</script>
</head>
<body>
	<div class="sub_wrap">
		<div class="location">
			<span class="location_home">HOME</span>
			<span class="step">시스템관리</span>
			<span class="step">시스템점검</span>
			<strong class="step">서버모니터링</strong>
		</div>
		<section class="sub_contents" id="section">
            <div class="btns_top" style="margin-bottom:2px;">
            	<div class="sub_l">
		            <img src="../images/icons/ico_refresh.gif">
	            	<select id="refreshValue" name="refreshValue" style="width:70px" class="list_box">
						<option value="5000">5 Sec</option>
						<option value="10000">10 Sec</option>
						<option value="20000">20 Sec</option>
						<option value="30000">30 Sec</option>
					</select>
					<input type="checkbox" id="autoRefresh" name="autoRefresh" checked>
					<label>Auto Refresh &nbsp;&nbsp;&nbsp;&nbsp;</label>
	            	&nbsp;&nbsp;&nbsp;&nbsp;
	            	<img src="../images/icon_arrR.png">
					<label><strong>최근업데이트시간 : </strong></label><span id="updateTime"></span>  
                </div>
                
                <div>
                	
                </div>
            </div>
            
            <div style="width:99%; height:68%; border:1px solid #d6d6d6; padding:10px 5px; margin-bottom:3px;">
            	<div style="float:left; width:30%; margin-bottom:10px;">▶ 시스템 모니터링</div>
            	<div style="float:right; width:60%; margin-bottom:10px; padding-right:5px; text-align:right;">
            		프로세스&nbsp;종류&nbsp;:&nbsp;
<!--             		<span class="proc_desc active"></span>&nbsp;Active&nbsp; -->
<!--             		<span class="proc_desc standby"></span>&nbsp;StandBy&nbsp; -->
<!--             		<span class="proc_desc standalone"></span>&nbsp;StandAlone&nbsp; -->
            		<span class="active">Active</span>&nbsp;
            		<span class="standby">StandBy</span>&nbsp;
            		<span class="standalone">StandAlone</span>&nbsp;
            		프로세스&nbsp;상태&nbsp;:&nbsp;
            		<span class="proc_desc running"></span>&nbsp;Running&nbsp;
            		<span class="proc_desc userStop"></span>&nbsp;UserStop&nbsp;
            		<span class="proc_desc down"></span>&nbsp;Down&nbsp;
            	</div>
            	<div style="overflow-x: hidden;height: 94%;width: 100%; overflow-y: scroll;">
            		<table class="input_table" id="tblMain">
            			<colgroup>
            				<col width="20%" />
                            <col width="35%" />
                            <col width="15%" />
                            <col width="15%" />
                            <col width="15%" />
                        </colgroup>
                        <tbody class="resultData"></tbody>
					</table>
            	</div>
			</div>
			
			<div style="width:99%; height:18%; border:1px solid #d6d6d6; padding:10px 5px;">
				<div style="margin-bottom:10px;">▶ 현재 장애 목록</div>
				<div id="gridList" style="width: 100%; height: 105px;"></div>
			</div>
		</section>
	</div>
</body>

</html>