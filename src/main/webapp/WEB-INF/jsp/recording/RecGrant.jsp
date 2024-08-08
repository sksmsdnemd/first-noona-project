<%@ page language="java" pageEncoding="UTF-8" contentType="text/html; charset=UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ page import="java.util.*"%>
<%@ page import="java.text.SimpleDateFormat"%>
<!DOCTYPE html>
<html lang="ko">
<head>
<jsp:include page="/WEB-INF/jsp/include/common.jsp" flush="true" />
<link rel="stylesheet" href="<c:url value="/css/w2ui-1.5.rc1.css"/>" type="text/css" />
<link rel="stylesheet" href="<c:url value="/css/w2ui-1.5.rc1.min.css"/>" type="text/css" />
<link rel="stylesheet" href="<c:url value="/css/veloce.common.css"/>" type="text/css" />
<script type="text/javascript" src="<c:url value="/scripts/jquery/jquery-1.11.3.min.js"/>"></script>
<script type="text/javascript" src="<c:url value="/scripts/argojs/argo.popWindow.js"/>"></script>
<script type="text/javascript" src="<c:url value="/scripts/argojs/w2ui-1.5.rc1.js"/>"></script>
<script type="text/javascript" src="<c:url value="/scripts/argojs/w2ui-1.5.rc1.min.js"/>"></script>
<script type="text/javascript" src="<c:url value="/scripts/argojs/argo.alert.js"/>"></script>
<script type="text/javascript" src="<c:url value="/scripts/jquery/jquery-ui.js?ver=2017011301"/>"></script>
<script type="text/javascript" src="<c:url value="/scripts/argojs/argo.timeSelect.js"/>"></script>
<%
String strCallId 	= request.getParameter("callId");
String strRecKey 	= request.getParameter("recKey");
String userId		= request.getParameter("userId");
String agentId		= request.getParameter("agentId");
SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd"); 
String strDate = sdf.format(new Date());
%>


<script type="text/javascript">
	var userId			= "<%=userId%>";
	var agentId			= "<%=agentId%>";
	var arrayGroupList;
	var arrayAgentList;
	$(document).ready(function(e) 
	{
		argoSetDatePicker();
		jData =[{"codeNm":"당일", "code":"T_0"}] ;
		argoSetDateTerm('start_dateTerm', {"targetObj":"start_date", "selectValue":"T_0"}, jData);
		$("#start_dateTerm").hide();
		argoSetDateTerm('grant_dateTerm', {"targetObj":"grant_date", "selectValue":"T_0"}, jData);
		$("#grant_dateTerm").hide();
		
		var loginInfo = JSON.parse(sessionStorage.getItem("loginInfo"));
		var insId = loginInfo.SVCCOMMONID.rows.userId;
		argoCbCreate("grant_Tenant", "comboBoxCode", "getTenantList", {}, {
			"selectIndex" : 0,
			"text" : '선택하세요!',
			"value" : ''
		});
		
		$("#grant_Tenant").change(function(e)
		{
			argoCbCreate("grant_Group", "comboBoxCode", "getGroupDepthList", {findTenantId:$('#grant_Tenant option:selected').val()}, {
				"selectIndex" : 0,
				"text" : '선택하세요!',
				"value" : ''
			});
			
			fnSearchGroupList();
		});
		
		
		$('#grant_Tenant').val("jbcc");
		$("#grant_Tenant").change();
		
		$("#grant_date_From").change(function(e)
		{
			var strToday = "<%=strDate%>";
			var setEndDay = $("#grant_date_From").val();
			var strTodayDate = new Date("<%=strDate%>");
			var setEndDayDate = new Date($("#grant_date_From").val());
					
			if(strTodayDate>setEndDayDate)
			{
				argoAlert("만료일은 과거로 설정하실 수 없습니다.");
				$("#grant_date_From").val(strToday);
				return;
			} 
		});
		
		$("#start_date_From").change(function(e)
		{
			var strToday = "<%=strDate%>";
			var setEndDay = $("#start_date_From").val();
			var strTodayDate = new Date("<%=strDate%>");
			var setEndDayDate = new Date($("#start_date_From").val());
			
			if(strTodayDate>setEndDayDate)
			{
				argoAlert("시작일은은 과거로 설정하실 수 없습니다.");
				$("#start_date_From").val(strToday);
				return;
			} 
		});
		
		$("#grantBtnSavePop").click(function(e)
		{
			var reason = $("#grant_reason").val();
			reason = VLC_StringProc_NVL(reason,"none");		
			if(reason=="none")
			{
				argoAlert("사유를 입력해주세요.");
				return;
			}
			else
			{
				var arrChecked = w2ui['agent_list'].getSelection();
				if(arrChecked.length <= 0)
				{
					argoAlert("상담사을 선택해주세요.");
					return;
				}
				else
				{
				    var selRow = w2ui['agent_list'].get(arrChecked[0]);
					var tenantId	= VLC_StringProc_NVL($("#grant_Tenant").val(),"");
// 					var userId		= w2ui['agent_list'].getCellValue(arrChecked[0], 1);
					var recKey		= $('#grant_RecKey').val();
					var callId		= $('#grant_CallId').val();
					console.log(recKey);
					console.log("selRow:", selRow);
					console.log("selRow.tenantId:", selRow.tenantId);
					//recKey = callId;
					argoJsonSearchList('recordFile', 'getRecGrant', 's_', {"tenantId":selRow.tenantId, "userId":selRow.userId,"recKey":recKey}, function (data, textStatus, jqXHR)
					{
						try{
							console.log(recKey);
							if(data.isOk()){
								if (data.getRows() != "")
								{
									console.log(recKey);
									argoAlert("이미 청취권한이 있는 상담사입니다.");
								}
								else
								{
									console.log(recKey);
									var loginInfo  = JSON.parse(sessionStorage.getItem("loginInfo"));
									var agentId    = loginInfo.SVCCOMMONID.rows.agentId;
									
									var startDate	= $('#start_date_From').val();
									var endDate		= $('#grant_date_From').val();
									var reason		= $('#grant_reason').val();
									var dFLAG 		= $('#grant_download').val();
									//alert(dFLAG);
									var param		= {"tenantId":selRow.tenantId, "userId":selRow.userId, "recKey":recKey, "startDate":startDate, "endDate":endDate, "insId":agentId, "reason":reason,"downloadFlag":dFLAG};
									var result		= argoJsonUpdate("recInfo", "registerGrandInfo", "__", param);
									if(result.isOk()) 
									{
										//argoAlert('warning', '성공적으로 등록 되었습니다.','', 'argoPopupClose();') ;
										argoAlert('warning', '성공적으로 등록 되었습니다.','', 'argoPopupClose();') ;
									}
								}
							}
						} catch(e) {
							console.log(e);			
						}
					});
				}
			}
		});
		
		$('#btnGroupSearch').click(function(e)
		{
			w2ui['group_list'].searchReset();
			w2ui['agent_list'].searchReset();
			if (w2ui['group_list'].records.length <= 0)
			{
				argoAlert('warning', '테넌트를 먼저 선택하셔야 합니다.') ;
				return;
			}
			
			var ip_GroupName	= document.getElementById("ip_GroupName");
			if (ip_GroupName.value == "")
			{
				argoAlert('warning', '검색하고자 하는 그룹명을 입력하셔야 합니다.') ;
				return;
			}
			
			w2ui['group_list'].search('groupName', ip_GroupName.value);
		});
		
		$('#btnUserSearch').click(function(e)
		{
			//ip_UserName
			var ip_UserName	= document.getElementById("ip_UserName");
			if (ip_UserName.value == "")
			{
				argoAlert('warning', '검색하고자 하는 사용자명을 입력하셔야 합니다.') ;
				return;
			}

// 			var findTenantId = $('#grant_Tenant option:selected').val();
			var findTenantId = $('#grant_Tenant').val() || "";
			console.log("#findTenantId:",findTenantId);
			if (w2ui['agent_list'].records.length <= 0)
			{
				argoJsonSearchList('comboBoxCode', 'getUserListDetail', 's_', {findTenantId:findTenantId, findUserName:ip_UserName.value}, fnSearchUserListDetail);
			}
			else
			{	
				w2ui['agent_list'].search('userName', ip_UserName.value);
				//console.log(w2ui['agent_list'].total);
				//.search('userName', ip_UserName.value));
				var length = w2ui['agent_list'].total;
				//console.log(length);
				if (length <= 0)
					argoJsonSearchList('comboBoxCode', 'getUserListDetail', 's_', {findTenantId:findTenantId, findUserName:ip_UserName.value}, fnSearchUserListDetail);
			}
		});
		
		fnInitGrid();
		
	});
	
	function fnInitGrid()
	{
		$('#groupList').w2grid(
		{
			name:'group_list',
			show:{
				selectColumn: true
			},
			onSelect: function(event)
			{
				var record	= this.get(event.recid);
				if (record.recid >= 0)
				{
					var groupId	= w2ui['group_list'].getCellValue(event.recid, 1);  
					fnUserListByGroup(groupId);
				}
			},
			multiSelect : false,
			columns: [
				{field:'recid', 			caption: 'recid', size: '0%', sortable: true, attr: 'align=center' },
				{field:'groupId', 			caption: '그룹ID', size: '20%', sortable: true, attr: 'align=center' },
				{field:'groupNameTree', 	caption: '그룹명', size: '70%', sortable: true, attr: 'align=left'   },
				{field:'groupName', 		caption: 'groupName', size: '0%', sortable: true, attr: 'align=left'   }
			],
			records: arrayGroupList
		});
		
		
		$('#agentList').w2grid(
		{
			name:'agent_list',
			show:{
				selectColumn: true
			},
			multiSelect : false,
			onSelect: function(event)
			{
				var record	= this.get(event.recid);
				if (record.recid >= 0)
				{
					var groupId	= w2ui['agent_list'].getCellValue(event.recid, 3);  
					fnSearchGroupList(groupId);
				}
			},
			columns: [
				{field:'recid', 			caption: 'recid', size: '0%', sortable: true, attr: 'align=center' },
				{field:'userId', 			caption: '사용자ID', size: '30%', sortable: true, attr: 'align=center' },
				{field:'userName', 			caption: '사용자명', size: '30%', sortable: true, attr: 'align=center'   },
				{field:'groupId', 			caption: 'groupId', size: '0px', sortable: true, attr: 'align=center'   },
				{field:'groupName', 		caption: '그룹명', size: '30%', sortable: true, attr: 'align=center'   },
				{field:'tenantId', 		    caption: 'tenantId', size: '0%', sortable: true, attr: 'align=center'   },
			],
			records: arrayAgentList
		});
		
		w2ui['group_list'].hideColumn('recid', 'groupName');
		w2ui['agent_list'].hideColumn('recid', 'groupId', 'tenantId');
	}
	
	function fnSearchGroupList(groupId)
	{
		var param;
		if (groupId != null && groupId != undefined && groupId != "")
			param	= {findTenantId:$('#grant_Tenant option:selected').val(), findGroupId:groupId};
		else
			param	= {findTenantId:$('#grant_Tenant option:selected').val()};
		argoJsonSearchList('Group', 'getGroupList', 's_', param, function (data, textStatus, jqXHR)
		{
			try
			{
				if(data.isOk())
				{
					w2ui['group_list'].searchReset();
					w2ui['group_list'].clear();
					if (data.getRows() != "")
					{
						arrayGroupList     = new Array();
						var subMove   = "";
						var subAdd    = "";
						var groupName = "";
						
						$.each(data.getRows(), function( index, row ) 
						{
							subMove = "";
							if (index > 1) 
							{
								subMove = subMove + ' <button type="button" id="sub" class="btn_m grid" onclick="javascript:subChangePos(' + index + ',-1);"><img src="../images/ico_arr_top.gif">위로</button>';
							}
							
							if (index > 0 && index < (data.getProcCnt()-1)) 
							{
								subMove = subMove + ' <button type="button" id="sub" class="btn_m grid" onclick="javascript:subChangePos(' + index + ',1);">아래로<img src="../images/ico_arr_down.gif"></button>';
							}
											
							subAdd = ' <button type="button" id="sub" class="btn_m grid" onclick="javascript:subAdd(' + index + ');">서브추가</button>';
							
							var blankSpan = "";
							
							for(var i=1;i<row.groupLevel;i++){
								blankSpan += '<span class="w2ui-show-children w2ui-icon-empty"></span>';
							}
							
							if (row.depthLen > 1) 
							{
								groupName ='<pre>' + row.head + '<img src="../images/minusbottom.gif"><img src="../images/folder.gif">' + row.groupName + '</pre>' ;
							} 
							else 
							{
								groupName = row.groupName;
							}
							
							gObject2 = {  "recid" 			: index
									 	, "groupId"			: row.groupId
									 	, "groupNameTree"	: blankSpan+groupName
									 	, "groupName"		: row.groupName
										};
										
							arrayGroupList.push(gObject2);
							
						});
						w2ui['group_list'].add(arrayGroupList);
					}
					else
					{
						argoAlert('조회 결과가 없습니다.');
					}
				}
				//w2ui['groupList'].select(pos);
			} 
			catch(e) 
			{
				console.log(e);			
			}
		});
	}
	
	function fnUserListByGroup(groupId)
	{
		//comboBoxCode.getUserListDetail
		argoJsonSearchList('comboBoxCode', 'getUserListDetail', 's_', {findTenantId:$('#grant_Tenant option:selected').val(), findGroupId:groupId}, fnSearchUserListDetail);
	}
	
	function fnSearchUserListDetail (data, textStatus, jqXHR)
	{
		try
		{
			if(data.isOk())
			{
				w2ui['agent_list'].clear();
				if (data.getRows() != "")
				{
					arrayAgentList     = new Array();
					var subMove   = "";
					var subAdd    = "";
					var groupName = "";
					
					$.each(data.getRows(), function( index, row ) 
					{
						gObject2 = {  "recid" 			: index
								 	, "userId"			: row.userId
				    				, "userName"		: row.userName
				    				, "groupId"			: row.groupId
				    				, "groupName"		: row.groupName
				    				, "tenantId"        : row.tenantId
				   					};
									
						arrayAgentList.push(gObject2);
						
					});
					w2ui['agent_list'].add(arrayAgentList);
				}
				else
				{
					argoAlert('조회 결과가 없습니다.');
				}
			}
			//w2ui['groupList'].select(pos);
		} 
		catch(e) 
		{
			console.log(e);			
		}
	}
</script>
</head>
<body>
	<div class="sub_wrap pop">
        <section class="pop_contents">            
            <div class="pop_cont pt5">
            	<div class="btn_topArea">
                	<span class="btn_r">
                       <button type="button" class="btn_m confirm" id="grantBtnSavePop" name="grantBtnSavePop">저장</button>
                    </span>               
                </div>
                <div class="input_area">
                	<table class="veloce_input_table" style="margin-bottom: 25px;">
                    	<colgroup>
                        	<col width="158">
                            <col width="">
                        </colgroup>
                        <tbody>
                        	<tr>
                            	<th colspan="1" style="padding: 4px 10px;line-height: 17px;border: 1px solid #d3d3d3;">테넌트</th>
                                <td colspan="3"  style="padding: 4px 10px;line-height: 17px;border: 1px solid #d3d3d3;">
                                	<select id="grant_Tenant" name="grant_Tenant" style="width:145px;">
                                    </select>                                   
                                </td>
                            </tr>
                        	<tr>
                            	<th colspan="1" style="padding: 4px 10px;line-height: 17px;border: 1px solid #d3d3d3;">그룹</th>
                                <td colspan="3"  style="height:250px;padding: 4px 10px;line-height: 17px;border: 1px solid #d3d3d3;">
                                	<input type="text" id="ip_GroupName" name="ip_GroupName" style="width:485px;" class="mr10" />
                                  	<button type="button" id="btnGroupSearch" class="btn_m">검색</button>
                                	<div id="groupList" style="float:left;width:100%;height:215px;margin-top:5px;" >
                               	  	</div>                              
                                </td>
                            </tr>
                            <tr>
                            	<th colspan="1" style="padding: 4px 10px;line-height: 17px;border: 1px solid #d3d3d3;">상담사</th>
                                <td colspan="3"  style="height:195px;padding: 4px 10px;line-height: 17px;border: 1px solid #d3d3d3;">
                                  	<input type="text" id="ip_UserName" name="ip_UserName" style="width:485px;" class="mr10" />
                                  	<button type="button" id="btnUserSearch" class="btn_m">검색</button>
                               	  	<div id="agentList" style="float:left;width:100%;height:160px;margin-top:5px;" >
                               	  	</div>                            
                                </td>
                            </tr>
                            <tr>
                            	<th colspan="1" style="padding: 4px 10px;line-height: 17px;border: 1px solid #d3d3d3;">시작일<span class="point"></span></th>
                                <td colspan="3"  style="padding: 4px 10px;line-height: 17px;border: 1px solid #d3d3d3;">
		                            <span class="select_date"><input type="text" class="datepicker onlyDate" id="start_date_From" name="start_date_From"></span>
		                            <select id="start_dateTerm" name="start_dateTerm" style="width:70px;" class="mr5"></select>
		                           </td>
                            </tr>
                            <tr>
                            	<th style="padding: 4px 10px;line-height: 17px;border: 1px solid #d3d3d3;">만료일<span class="point"></span></th>
                                <td style="padding: 4px 10px;line-height: 17px;border: 1px solid #d3d3d3;">
		                            <span class="select_date"><input type="text" class="datepicker onlyDate" id="grant_date_From" name="grant_date_From"></span>
		                            <select id="grant_dateTerm" name="grant_dateTerm" style="width:70px;" class="mr5"></select>
		                           </td>
		                        <th style="padding: 4px 10px;line-height: 17px;border: 1px solid #d3d3d3;">다운로드 가능여부</th>
                                <td style="padding: 4px 10px;line-height: 17px;border: 1px solid #d3d3d3;">		
                               	<select id="grant_download" name="grant_download" style="width:70px;" class="mr5">
                               		<option value="Y">예</option>
                               		<option value="N">아니오</option>
                               	</select>
                                </td>   
                            </tr>
                            <tr>
                            	<th colspan="1" style="padding: 4px 10px;line-height: 17px;border: 1px solid #d3d3d3;">콜아이디</th>
                                <td colspan="3"  style="padding: 4px 10px;line-height: 17px;border: 1px solid #d3d3d3;">		
                                <%=strCallId%>
                                <input type="hidden" id="grant_CallId" value="<%=strCallId%>">
                                <input type="hidden" id="grant_RecKey" value="<%=strRecKey%>">	
                                </td>
                            </tr>                         
                            <tr>
                            	<th colspan="1" style="padding: 4px 10px;line-height: 17px;border: 1px solid #d3d3d3;">사유입력</th>
                                <td colspan="3"  style="padding: 4px 10px;line-height: 17px;border: 1px solid #d3d3d3;">
                                	<textarea id="grant_reason" name="grant_reason" rows="4" style="width:100%;" class="mr10" maxlength="200"></textarea>
                                </td>
                            </tr>
                        </tbody>
                    </table>
                </div>           
            </div>            
        </section>
    </div>
</body>
</html>
