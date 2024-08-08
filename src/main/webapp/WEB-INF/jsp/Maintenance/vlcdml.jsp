<%@ page language="java" pageEncoding="UTF-8" contentType="text/html; charset=UTF-8"%>
<%@ page language="java" import="java.sql.*"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml" lang="ko">
	<head>
		<jsp:include page="/WEB-INF/jsp/include/common.jsp" flush="true" />
		<link rel="stylesheet" type="text/css" href="http://w2ui.com/src/w2ui-1.4.min.css" />
		<script type="text/javascript" src="http://w2ui.com/src/w2ui-1.4.min.js"></script>
	</head>
	<body>
		<div id="layout" style="width: 100%; height: 100%;"></div>
	
		<!-- DML 영역 -->
		<div id="div_dml" style="display: none;">
			
			<textarea style="width: 90%; height: 90%; font-size:15px; font-weight:bold; " id="dmlText" placeholder="쿼리를 입력하세요. (SELECT, INSERT, UPDATE, DELETE) 한번에 한개의 구문만 사용 가능합니다."></textarea>
			<button type="button" id="btnSearch" class="btn_m search" style="height: 90%; vertical-align: top;">조회</button>
			<button type="button" id="btnReset" class="btn_m" style="height: 90%; vertical-align: top;">초기화</button>
		</div>
	
		<!-- Table List 영역 -->
		<div id="div_table" style="display: none;">
			<div id="tableListArea"></div>
		</div>
	
		<!-- Data 영역 -->
		<div id="div_data" style="display: none;">
			<div class="sub_l">
				<strong style="width: 25px">[ 전체 ]</strong> : <span id="totCount"></span>
				<select id="s_SearchCount" name="s_SearchCount" style="width: 50px" class="list_box">
					<option value="15">15</option>
					<option value="20">20</option>
					<option value="30">30</option>
					<option value="40">40</option>
					<option value="50">50</option>
				</select>
			</div>
			<div class="h136">
				<div class="btn_topArea fix_h25"></div>
				<span id="tableNameArea"></span>
				<div class="grid_area h25 pt0">
					<div id="gridList" style="width: 100%; height: 650px;"></div>
					<div class="list_paging" id="paging">
						<ul class="paging">
							<li><a href="#" id='' class="on"></a>1</li>
						</ul>
					</div>
				</div>
			</div>
		</div>
	</body>
</html>
<script type="text/javascript">
	var columnList;
	var selTableName = "";
	var dmlText = "";
	var viewType = "";
	var dmlAt = true;
	var userId 	 = '<spring:eval expression="@code['Globals.ARGO.RDB.Account']"/>';
	
	$(function() {
		fnGridSetting();
		fnSetTableList();

		$("#btnSearch").click(function() { //조회
			workPage = "1";
			viewType = "D";
			dmlText = $("#dmlText").val().replace(/;/g, "");

			fnQueryDiv();

			if (dmlAt) {
				fnSearchListCnt();
			} else {
				fnExecuteDml();
			}
		});

		$("#btnReset").click(function() { //조회
			$("#dmlText").val("");
		});
		$("#btnback").click(function() { //조회
			window.location.replace(gGlobal.ROOT_PATH + '/common/DbInfoConfigF.do');
		});
	});

	function fnQueryDiv() {

		var upperCase = dmlText.toUpperCase();
		// UPDATE, DELETE, INSERT
		if (upperCase.indexOf('UPDATE') != -1 || upperCase.indexOf('DELETE') != -1 || upperCase.indexOf('INSERT') != -1) {
			dmlAt = false;
		} else {
			dmlAt = true;
		}
	}

	
	//INSERT, UPDATE, DELETE 쿼리 실행
	function fnExecuteDml() {

		var Resultdata2 = argoJsonUpdate("mt", "setDML", "", {
			text : dmlText
		});

		if (Resultdata2.isOk()) {
			argoAlert("단일쿼리 실행완료");
		} else {
			argoAlert("단일쿼리 실행실패");
			return;
		}

	}

	//Grid 정보 세팅
	function fnGridSetting() {
		var pstyle = 'border: 1px solid #dfdfdf; padding: 5px;';
		$('#layout').w2layout({
			name : 'layout',
			panels : [ {
				type : 'top',
				size : 150,
				resizable : true,
				style : pstyle,
				content : $("#div_dml").html(),
				title : 'DML <button type="button" id="btnback" class="btn_m" style="height: 90%; vertical-align: top;">이전화면으로 돌아가기</button>'
			}, {
				type : 'left',
				size : 300,
				resizable : true,
				style : pstyle,
				content : $("#div_table").html(),
			}, {
				type : 'main',
				style : pstyle + 'border-top: 0px;',
				content : $("#div_data").html(),
				title : 'Data'
			} ]
		});

		$('#tableListArea').w2grid({
			name : 'grid1',
			columns : [ {
				field 	: 'recid',
				caption : 'recid',
				hidden 	: true
			}, {
				field 	: 'tableName',
				caption : 'Table List',
				size 	: '100%'
			}, ],
			onDblClick : function(event) {
				if (event.recid >= 0) {
					viewType = "C";
					w2ui['grid'].clear();
					fnSelectTbList(event.recid);
				}
			},
		});

		w2ui['layout'].content('left', w2ui['grid1']);

		$('#gridList').w2grid({
			name : 'grid',
			selectType : 'cell'
		});

	}

	// tableList 세팅
	function fnSetTableList() {
		
		argoJsonSearchList( 'mt', 'getTBList', '', { owner : userId }, function(data, textStatus, jqXHR) {
			try {
				if (data.isOk()) {
					if (data.getRows() != "") {
						dataArray = [];
						$.each(data.getRows(), function(index, row) {
							gridObject = {
								"recid" : index,
								"tableName" : row.tableName,
							};
							dataArray.push(gridObject);
						});
						//alert("test");
						w2ui['grid1'].add(dataArray);
						$('#tableListArea').show();
					} else {
						argoAlert('warning', "조회결과가 없습니다.", '', 'window.open("", "_self", "");window.close();');
						return;
					}
				}
			} catch (e) {
	
				console.log(e);
			}
		});
	}

	// 테이블 명 클릭 event
	function fnSelectTbList(recid) {

		selTableName = w2ui['grid1'].getCellValue(recid, 1);
		fnSearchListCnt();
	}

	
	function fnClearColumn() {
		var columnArray = w2ui['grid'].columns.length;
		if (columnArray > 0) {
			for (var i = 0; i < columnArray; i++) {
				if (w2ui['grid'].columns[0].field != undefined) {
					w2ui['grid'].removeColumn(w2ui['grid'].columns[0].field);
				}
			}
		}
	}

	
	
	// Paging 처리를 위해 COUNT 수 뽑음
	function fnSearchListCnt() {

		var methodName = "getRowListCnt";
		var params = {
			"tableName" : selTableName
		};
		// DML 작성으로 조회할 경우
		if (viewType == "D") {
			methodName = "getDmlCnt";
			params = {
				text : dmlText
			};
		}
		
		w2ui['grid'].addColumn({
			field : "recid",
			caption : "recid",
			size : '120px',
		});

		argoJsonSearchOne('mt', methodName, '', params, function(data, textStatus, jqXHR) {
			try {
				if (data.isOk()) {
					var totalData = data.getRows()['cnt'];
					var searchCnt = argoGetValue('s_SearchCount');
					paging(totalData, "1", searchCnt);

					$("#totCount").html(totalData);

					if (totalData == 0) {
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

		w2ui['grid'].clear();
		fnClearColumn();

		var methodName = "getRowList";
		var params = {
			"iSPageNo" : startRow,
			"iEPageNo" : endRow,
			"tableName" : selTableName
		};

		// DML 작성으로 조회할 경우
		if (viewType == "D") {
			methodName = "getDmlList";
			params = {
				text : dmlText,
				"iSPageNo" : startRow,
				"iEPageNo" : endRow
			};
		}

		argoJsonSearchList('mt', methodName, '', params, function(data, textStatus, jqXHR) {
			try {
				if (data.isOk()) {
					if (data.getRows() != "") {
						$.each(data.getRows(), function(index, row) {

							if (index == 0) {
								for (key in row) {
									if (key != "rownum1" && key != "rownum2" && key !="temp") {
										w2ui['grid'].addColumn({
											field : key,
											caption : key,
											size : '120px'
										});
									}
								}
							}
							row['recid'] = index;
							w2ui['grid'].add(row);
						});


						$('#gridList').show();
					}
				}
			} catch (e) {
				console.log(e);
				return;
			}
		});

		w2ui.grid.unlock();
	}
</script>
