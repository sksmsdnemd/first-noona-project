<%@ page language="java" pageEncoding="UTF-8" contentType="text/html; charset=UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<!DOCTYPE html>
<html lang="ko">
<head>
<jsp:include page="/WEB-INF/jsp/include/common.jsp" flush="true" />

<%-- <script type="text/javascript" src="<c:url value="/scripts/ipronjs/ipron.js"/>"></script> --%>
<%-- <script type="text/javascript" src="<c:url value="/scripts/bluebird/bluebird.min.js"/>"></script> --%>

<script type="text/javascript" charset="UTF-8">
	var loginInfo 	= JSON.parse(sessionStorage.getItem("loginInfo"));
	var tenantId  	= loginInfo.SVCCOMMONID.rows.tenantId;
	var dataArray 	= new Array();
	var param		= null;
	
	
	$(document).ready(function() {
		fnInitCtrl();
		fnInitGrid();
		fnSearchListCnt();
		
		
		// 새로고침 방지
		$(document).keydown(function(e) {
			var key = (e) ? e.keyCode : event.keyCode;
			var t = document.activeElement;
		
			if (key == 8 || key == 116 || key == 17 || key == 82) {
				if(key == 8) {
					if(t.tagName != "INPUT" && t.tagName != "TEXTAREA") {
						if(e) {
							e.preventDefault();
						} else {
							event.keyCode = 0;
							event.returnValue = false;
						}
					}
				} else {
					if(e) {
						e.preventDefault();
					} else {
						event.keyCode = 0;
						event.returnValue = false;
					}
				}
			}
		});
		
		// parent page에서 새로고침 방지
		$(parent.document).keydown(function(e) {
			var key = (e) ? e.keyCode : event.keyCode;
			var t = document.activeElement;
		
			if (key == 8 || key == 116 || key == 17 || key == 82) {
				if(key == 8) {
					if(t.tagName != "INPUT" && t.tagName != "TEXTAREA") {
						if(e) {
							e.preventDefault();
						} else {
							event.keyCode = 0;
							event.returnValue = false;
						}
					}
				} else {
					if(e) {
						e.preventDefault();
					} else {
						event.keyCode = 0;
						event.returnValue = false;
					}
				}
			}
		});
	});
	
	function fnInitCtrl() {
		argoCbCreate("s_FindTenantId", "comboBoxCode", "getTenantList", {}, {"selectIndex":0, "text":'선택하세요!', "value": ''});
		$("#s_FindTenantId").val(tenantId).attr("selected", "selected");
		
		// selectbox change
		$("#s_FindTenantId").change(function() { fnSearchListCnt(); });
		$("#s_SearchCount").change(function() { fnSearchListCnt(); });
		
		// btn click
		$("#btnCallTestAll").click(function() { fnCallTest("ALL"); });
		$("#btnCallTest").click(function() { fnCallTest("SEL"); });
		$("#btnSearch").click(function() { //조회
			workPage = "1";
			fnSearchListCnt();
		});
	}
	
	function fnInitGrid() {
		$('#gridList').w2grid({
	        name: 'grid',
	        show: {
	            lineNumbers: true,
	            footer: true,
	            selectColumn: true
	        },
	        columns: [   { field: 'recid', 				caption: 'recid', 	size: '0%',		attr: 'align=center' }
           				,{ field: 'dnNo', 				caption: '내선', 		size: '6%', 	attr: 'align=center' }
	            		,{ field: 'phoneIp', 	    	caption: '전화기IP',  	size: '13%', 	attr: 'align=center' }
			           	,{ field: 'userId', 			caption: '상담사ID',	size: '9%', 	attr: 'align=center' }
			           	,{ field: 'userName', 			caption: '상담사명', 	size: '9%', 	attr: 'align=center' }
			           	,{ field: 'dnStatus', 			caption: '상태', 		size: '0%', 	attr: 'align=center' }
			           	,{ field: 'dnStatusName', 		caption: '통화상태', 	size: '8%', 	attr: 'align=center' }
			           	,{ field: 'agentStatusName', 	caption: '로그인상태',	size: '8%', 	attr: 'align=center' }
			           	,{ field: 'systemId', 			caption: '시스템ID', 	size: '0%', 	attr: 'align=center' }
			           	,{ field: 'systemName',			caption: '시스템명', 	size: '13%', 	attr: 'align=center' }
			           	,{ field: 'processId', 			caption: '프로세스ID', 	size: '0%', 	attr: 'align=center' }
			           	,{ field: 'processName', 		caption: '프로세스명', 	size: '10%', 	attr: 'align=center' }
			           	,{ field: 'useFlag', 			caption: '사용여부', 	size: '0%', 	attr: 'align=center' }
			           	,{ field: 'useFlagName',		caption: '사용여부', 	size: '7%', 	attr: 'align=center' }
	        ],
	        records: dataArray
	    });
		w2ui['grid'].hideColumn('recid', 'dnStatus', 'systemId', 'processId', 'useFlag');
	}
	
	function fnSearchListCnt() {
		
		argoJsonSearchOne('callTest', 'getDnListCnt', 's_', {}, function(data, textStatus, jqXHR) {
			try {
				if (data.isOk()) {
					var totalData = data.getRows()['cnt'];
					var searchCnt = argoGetValue('s_SearchCount');
// 					paging(totalData, "1");
					paging(totalData, "1", searchCnt);
					$("#totCount").html(totalData);
					
					if(totalData == 0) {
						argoAlert('조회 결과가 없습니다.');
					}
					
					w2ui.grid.lock('조회중', true);
				}
			} catch (e) {
				console.log(e);
			}
		});
	}
	
	function fnSearchList(startRow, endRow) {
		argoJsonSearchList('callTest', 'getDnList', 's_', {"iSPageNo":startRow, "iEPageNo":endRow}, function(data, textStatus, jqXHR) {		
			try{
				if(data.isOk()) {
					w2ui.grid.clear();
					if (data.getRows() != "") { 
						dataArray = [];
						
						$.each(data.getRows(), function(index, row) {
							gridObject = {	  "recid" 			: index
											, "dnNo" 			: row.dnNo
											, "phoneIp" 	   	: row.phoneIp
											, "userId" 			: row.userId
											, "userName" 		: row.userName
											, "custTel" 		: row.custTel
											, "dnStatus" 		: row.dnStatus
											, "dnStatusName"	: row.dnStatusName
											, "agentStatusName" : row.agentStatusName
											, "systemId" 		: row.systemId
											, "systemName" 		: row.systemName
											, "processId" 		: row.processId
											, "processName" 	: row.processName
											, "useFlag"			: row.useFlag
											, "useFlagName" 	: row.useFlagName
										};
										
							dataArray.push(gridObject);
							
						});
						w2ui['grid'].add(dataArray);
					}
					
				}
			} catch(e) {
				console.log(e);			
			}
			
// 			workLog = '[TenantId:' + tenantId + ' | UserId:' + userId
// 			+ ' | GrantId:' + grantId + '] 조회';
// 			argoJsonUpdate("actionLog", "setActionLogInsert", "ip_", {
// 				tenantId : tenantId,
// 				userId : userId,
// 				actionClass : "action_class",
// 				actionCode : "W",
// 				workIp : workIp,
// 				workMenu : workMenu,
// 				workLog : workLog
// 			});
		});
	}
	
	function fnCallTest(type) {
		if($("#s_FindAppName").val() == "") {
			argoAlert('IPRON AppName을 입력하세요.');
			return;
		}
		
		if($("#s_FindProtocol").val() == "") {
			argoAlert('IPRON 연계 Protocol을 선택하세요.');
			return;
		}
		
		if($("#s_FindIpAddr1").val() == "") {
			argoAlert('IPRON 연계 IP를 입력하세요.');
			return;
		}
		
// 		if($("#s_FindIpAddr1").val() != "" && $("#s_FindIpAddr2").val() == "") {
// 			$("#s_FindIpAddr2").val($("#s_FindIpAddr1").val());
// 		}
		
		if($("#s_FindPort").val() == "") {
			argoAlert('IPRON 연계 Port를 입력하세요.');
			return;
		}
		
		if($("#s_FindAgentId").val() == "") {
			argoAlert('IPRON 로그인 ID를 입력하세요.');
			return;
		}
		
		if($("#s_FindAgentPw").val() == "") {
			argoAlert('IPRON 로그인 PW를 입력하세요.');
			return;
		}
		
		if($("#s_FindDestDN").val() == "") {
			argoAlert('Dest Dn을 입력하세요.');
			return;
		}
		
		var arrChecked = w2ui['grid'].getSelection();
		var arrDn = new Array();

		if("ALL" == type) {
			argoJsonSearchList('callTest', 'getDnListAll', 's_', {}, function(data, textStatus, jqXHR) {
				try{
					if(data.isOk()) {
						if (data.getRows() != "") {
							$.each(data.getRows(), function(index, row) {
								arrDn[index] = row.dnNo;
							});
						} else {
							argoAlert('테스트할 내선번호가 없습니다.');
							return;
						}
					}
				} catch(e) {
					console.log(e);			
				}
			});
		} else {
			if(arrChecked.length > 0) {
				$.each(arrChecked, function( index, value ) {
					arrDn[index] = w2ui['grid'].getCellValue(value, 1);
				});
			} else {
				argoAlert('내선번호를 선택하세요.');
				return;
			}
		}
		
		gPopupOptions = {	 arrDn:arrDn
						   , selTenant:$("#s_FindTenantId").val()
						   , appName:$("#s_FindAppName").val()
						   , protocol:$("#s_FindProtocol").val()
						   , ipAddr1:$("#s_FindIpAddr1").val()
// 						   , ipAddr2:$("#s_FindIpAddr2").val()
						   , ipAddr2:$("#s_FindIpAddr1").val()
						   , port:$("#s_FindPort").val()
						   , agentId:$("#s_FindAgentId").val()
						   , agentPw:$("#s_FindAgentPw").val()
						   , destDn:$("#s_FindDestDN").val()
						} ;
		argoPopupWindow('Call Test 현황', 'CallTestPopupResultF.do', '800', '530');
		$(".btn_popClose").off();	// 팝업 닫기 버튼의 모든 이벤트 제거
		$(".btn_popClose").attr("onClick", "javascript:fn_popClose(); return;");
		
		// 팝업 오픈시 메뉴 클릭 및 로고클릭 메뉴 이동 제한
		parent.$("#wrap").find("a").bind("mousedown", function(e) {
			var onClickEvent = $(e.target).closest('a').attr('onclick');
			var onClickId = $(e.target).closest('a').attr('id');
			var aTagHref = $(e.target).closest('a').attr('href');
			
			param = { id:onClickId, event:onClickEvent, href:aTagHref };
			
			if(onClickEvent) {
				parent.$('[id="'+onClickId+'"]').removeAttr('onclick');
				argoAlert("warning", "Call Test 창이 열려 있는 상태에서는 메뉴 이동이 불가능 합니다.", "", "setATagEvent('onclick');");
			} else {
				$(e.target).closest('a').attr('href', '#');
				$(e.target).closest('a').attr('id', 'aTagTarget');
				argoAlert("warning", "Call Test 창이 열려 있는 상태에서는 메뉴 이동이 불가능 합니다.", "", "setATagEvent('href');");
			}
		});

	}
	
	function fn_popClose() {
		if(document.getElementsByName("pop0")[0].contentWindow.ipron.IsConnected()) {
			argoAlert('Call Test 중에는 창을 닫을 수 없습니다.');
			return;
		} else {
			parent.$("#wrap").find("a").unbind("mousedown");			
			document.getElementsByName("pop0")[0].contentWindow.argoPopupClose();
		}
	}
	    
    function setATagEvent(type) {
		if(type == "onclick") {
	    	parent.$('[id="'+param.id+'"]').attr('onClick', param.event);
		} else {
	    	parent.$("#aTagTarget").attr('href', param.href);
	    	parent.$("#aTagTarget").removeAttr('id');
		}
    	param = null;
    }
</script>

</head>
<body>
	<div class="sub_wrap">
        <div class="location">
        	<span class="location_home">HOME</span><span class="step">운용관리</span><span class="step">콜테스트</span><strong class="step">내선번호관리</strong>
        </div>
        
        <section class="sub_contents">
			<div class="search_area" id="searchPanel" style="height: 42px;">
				<div class="row" id="div_tenant">
					<ul class="search_terms">
						<li>
							<strong class="title ml20">태넌트</strong> 
							<select	id="s_FindTenantId" name="s_FindTenantId" style="width: 140px" class="list_box"></select>
						</li>
						<li>
							<strong class="title ml20">내선</strong>
							<input type="text" id="s_FindDnNo" name="s_FindDnNo" style="width: 120px" class="clickSearch" />
						</li>
					</ul>
				</div>
			</div>
			<div class="search_area" id="searchPanel" style="height: 75px;">
				<div class="row" id="div_server">
					<ul class="search_terms">
						<li>
							<strong class="title ml20">AppName</strong>
							<input type="text" id="s_FindAppName" name="s_FindAppName" value="Call Test" style="width: 140px" class="clickSearch" />
						</li>
						<li>
							<strong class="title ml20">Protocol</strong>
							<select id="s_FindProtocol" name="s_FindProtocol" style="width: 120px;" class="list_box">
								<option value="http">http</option>
								<option value="https">https</option>
							</select>
						</li>
						<li>
							<strong class="title ml20">IpAddr1</strong>
							<input type="text" id="s_FindIpAddr1" name="s_FindIpAddr1" style="width: 120px" class="clickSearch" />
						</li>
<!-- 						<li> -->
<!-- 							<strong class="title ml20">IpAddr2</strong> -->
<!-- 							<input type="text" id="s_FindIpAddr2" name="s_FindIpAddr2" style="width: 120px" class="clickSearch" /> -->
<!-- 						</li> -->
						<li>
							<strong class="title ml20">Port</strong>
							<input type="text" id="s_FindPort" name="s_FindPort" style="width: 100px" class="clickSearch" />
						</li>
					</ul>
				</div>
				<div class="row" id="div_agent">
					<ul class="search_terms">
						<li>
							<strong class="title ml20">AgentId</strong>
							<input type="text" id="s_FindAgentId" name="s_FindAgentId" style="width: 140px" class="clickSearch" />
						</li>
						<li>
							<strong class="title ml20">AgentPW</strong>
							<input type="text" id="s_FindAgentPw" name="s_FindAgentPw" style="width: 120px" class="clickSearch" />
						</li>
						<li>
							<strong class="title ml20">Dest DN</strong>
							<input type="text" id="s_FindDestDN" name="s_FindDestDN" style="width: 120px" class="clickSearch" />
						</li>
					</ul>
				</div>
			</div>
			
			<div class="btns_top">
				<div class="sub_l">
	            	<strong style="width: 25px">[ 전체 ]</strong>	: <span id="totCount"></span>
	            	<select id="s_SearchCount" name="s_SearchCount" style="width: 50px" class="list_box">
						<option value="15">15</option>
						<option value="30">30</option>
						<option value="50">50</option>
						<option value="100">100</option>
						<option value="500">500</option>
					</select>
                </div>
                <button type="button" id="btnSearch" class="btn_m search">조회</button>
                <button type="button" id="btnCallTestAll" class="btn_m confirm">콜테스트(ALL)</button>
                <button type="button" id="btnCallTest" class="btn_m confirm">콜테스트</button>
                <button type="button" id="btnReset" class="btn_m">초기화</button>
            </div>
            
            <div class="h136">
            	<div class="btn_topArea fix_h25"></div>
	            <div class="grid_area h25 pt0">
	            	<div id="gridList" style="width: 100%; height: 415px;"></div>
	                <div class="list_paging" id="paging">
                		<ul class="paging">
                 			<li><a href="#" id='' class="on"></a>1</li>
                 		</ul>
                	</div>	            	
	            </div>
	        </div>
        </section>
    </div>
</body>

</html>