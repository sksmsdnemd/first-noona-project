<%@ page language="java" pageEncoding="UTF-8"
	contentType="text/html; charset=UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html lang="ko">
<head>
<jsp:include page="/WEB-INF/jsp/include/common.jsp" flush="true" />
<script type="text/javascript"
	src="<c:url value="/scripts/jquery/jquery-1.11.3.min.js"/>"></script>
<script type="text/javascript"
	src="<c:url value="/scripts/jquery/jquery-ui.js?ver=2017011301"/>"></script>
<script type="text/javascript"
	src="<c:url value="/scripts/argojs/argo.alert.js?ver=2017011301"/>"></script>
<style type="text/css">
.memo {
	line-height: 22px
}



</style>
<script>
	var loginInfo;
	var userId;
	var tenantId;
	var workIp;
	var workMenu;
	var workLog;
	var workIp;
	var sPopupOptions;

	var pTenantId = "";
	var pDnNo = "";
	var pUserId = "";
	var pGroupId = "";
	var pCustName = "";
	var pCustTel = "";
	var pCustNo = "";
	var pFindField = "";
	var pFindFieldText = "";
	var pCallKind = "";
	var pCustEtc9 = "";
	var pCallId = "";
	var pTranTel = "";
	var pFrmRecDate = "";
	var pFrmRecTm = "";
	var pToRecDate = "";
	var pToRecTm = "";
	var pFrmCallTm = "";
	var pToFrmCallTm = "";
	var pSoliKind = "";
	var pChkListeningYn = "";
	var pChkDownloadYn = "";

	$(function() {
		sPopupOptions = parent.gPopupOptions || {};
		sPopupOptions.get = function(key, value) {
			return this[key] === undefined ? value : this[key];
		};

		pTenantId 		= argoNullConvert(sPopupOptions.pTenantId);
		pDnNo 			= argoNullConvert(sPopupOptions.pDnNo);
		pUserId 		= argoNullConvert(sPopupOptions.pUserId);
		pGroupId 		= argoNullConvert(sPopupOptions.pGroupId);
		pCustName 		= argoNullConvert(sPopupOptions.pCustName);
		pCustTel 		= argoNullConvert(sPopupOptions.pCustTel);
		pCustNo 		= argoNullConvert(sPopupOptions.pCustNo);
		pFindField 		= argoNullConvert(sPopupOptions.pFindField);
		pFindFieldText 	= argoNullConvert(sPopupOptions.pFindFieldText);
		pCallKind 		= argoNullConvert(sPopupOptions.pCallKind);
		pCustEtc9 		= argoNullConvert(sPopupOptions.pCustEtc9);
		pCallId 		= argoNullConvert(sPopupOptions.pCallId);
		pTranTel 		= argoNullConvert(sPopupOptions.pTranTel);
		pFrmRecDate 	= argoNullConvert(sPopupOptions.pFrmRecDate);
		pFrmRecTm 		= argoNullConvert(sPopupOptions.pFrmRecTm);
		pToRecDate 		= argoNullConvert(sPopupOptions.pToRecDate);
		pToRecTm 		= argoNullConvert(sPopupOptions.pToRecTm);
		pFrmCallTm 		= argoNullConvert(sPopupOptions.pFrmCallTm);
		pToCallTm 		= argoNullConvert(sPopupOptions.pToCallTm);
		pSoliKind 		= argoNullConvert(sPopupOptions.pSoliKind);
		pChkListeningYn = argoNullConvert(sPopupOptions.pChkListeningYn);
		pChkDownloadYn 	= argoNullConvert(sPopupOptions.pChkDownloadYn);
		pCallbackFunctionNm = argoNullConvert(sPopupOptions.pCallbackFunctionNm);
		fnInitCtrl();
	});

	function fnInitCtrl() {
		argoCbCreate("#ip_ReasonCode", "ARGOCOMMON", "getBaseCodeList", {sort_cd : 'REC_SEARCH_REASON_CD'}, {});
		argoSetValue("#ip_ReasonCode", "00000");
		$("#btnSave").click(function() {
			fnSave();
		});
		
		$("#btnClose").click(function() {
			argoPopupClose();
		});
		
		$("#ip_Memo").focus();
	}

	function fnSave() {
		
		/* .pop_box{
			min-height:130px;
			top:60%;
			border:1px solid;
		}

		.pop_b{
			display: none;
		}


		.pop_box .pop_t .pop_message{
			padding-left: 0px;
		}

		.pop_alim.warning .pop_box .pop_t{
			background:none;
		} */
		
		//$(".pop_box").css("min-");
		
		if ($("#ip_ReasonCode").val() == "") {
			argoAlert("조회사유를 선택해 주세요.");
			return;
		}
		
		if($("#ip_ReasonCode").val() == "00000" && $.trim($("#ip_Memo").val()) == ""){
			argoAlert("메모를 입력해 주세요.");
			return;	
		}
		
		/* if($("#ip_ReasonCode").val() != "00000" && $("#ip_Memo").val() != ""){
			argoAlert("메모는 기타사유일 경우에만 입력 가능합니다.");
			return;	
		} */
		
		//argoConfirm("<span style='font-size:12pt;'>통화내역 조회사유를<br>등록하시겠습니까?</span><br><br><span style='font-size:9pt;'>조회사유 등록을 완료하면 통화내역이 조회됩니다.</span>", function() {
		var multiService = new argoMultiService(fnCallbackSave);
		var param = {
			pTenantId : pTenantId,
			pDnNo : pDnNo,
			pUserId : pUserId,
			pGroupId : pGroupId,
			pCustName : pCustName,
			pCustTel : pCustTel,
			pCustNo : pCustNo,
			pFindField : pFindField,
			pFindFieldText : pFindFieldText,
			pCallKind : pCallKind,
			pCustEtc9 : pCustEtc9,
			pCallId : pCallId,
			pTranTel : pTranTel,
			pFrmRecDate : pFrmRecDate,
			pFrmRecTm : pFrmRecTm,
			pToRecDate : pToRecDate,
			pToRecTm : pToRecTm,
			pFrmCallTm : pFrmCallTm,
			pToCallTm : pToCallTm,
			pSoliKind : pSoliKind,
			pChkListeningYn : pChkListeningYn,
			pChkDownloadYn : pChkDownloadYn,
			pReasonCode : argoGetValue("ip_ReasonCode"),
			pMemo : argoGetValue("ip_Memo")
		}
		multiService.argoInsert("recSearch", "SP_REC_SEARCH_REASON_SAVE","__", param);
		multiService.action();
		
		
		
		//});
	}

	function fnCallbackSave(Resultdata, textStatus, jqXHR) {
		try {
			if (Resultdata.isOk()) {
				//argoAlert('통화내역 조회사유를 성공적으로 저장 하였습니다.');
				
				//parent.pCallbackFunctionNm;
				//console.log("자식창 : " + pCallbackFunctionNm);
				//parent.fnSearchListCnt();
				//argoPopupClose();
				
				//setTimeout(function() {
				//	  console.log("안녕하세요!");
				//}, 2000); // 2000 밀리초 (2초) 후에 함수가 실행됩니다.
				
				
				//argoAlert('warning', '통화내역 조회사유를 성공적으로 저장 하였습니다.<br><br>통화내역을 조회합니다.','', 'fnProgressViewSearch(function(){parent.fnSearchListCnt();});');
				//argoAlert('warning', '통화내역 조회사유를 성공적으로 저장 하였습니다.<br><br>통화내역을 조회합니다.','', 'fnProgressViewSearch(function(){parent.fnSearchListCnt();});');
				
				/* .pop_box{
					min-height:130px;
					top:60%;
					border:1px solid;
				}
		
				.pop_b{
					display: none;
				}
		
		
				.pop_box .pop_t .pop_message{
					padding-left: 0px;
				}
		
				.pop_alim.warning .pop_box .pop_t{
					background:none;
				} */
				
				
				
				argoAlert("통화내역 조회사유를 성공적으로 저장 하였습니다.<br><br>통화내역 조회 중입니다...");
				$(".pop_box").css({
					"min-height":"130px",
					"top":"60%",
					"border":"1px solid"
				});
				
				$(".pop_b").css({
					"display":"none"
				});
				
				$(".pop_box .pop_t .pop_message").css({
					"padding-left":"0px"
				});
				
				$(".pop_alim.warning .pop_box .pop_t").css({
					"background":"none"
				});
				fnProgressViewSearch(function(){parent.fnSearchListCnt();});
				
				//argoAlert('warning', '통화내역 조회사유를 성공적으로 저장 하였습니다.','', 'parent.'+pCallbackFunctionNm+' argoPopupClose();');
				//argoAlert('warning', '통화내역 조회사유를 성공적으로 저장 하였습니다.','', 'argoPopupClose(); parent.'+pCallbackFunctionNm);
				//argoAlert('warning', '통화내역 조회사유를 성공적으로 저장 하였습니다.','', 'parent.LoadingWithMask(); ' + 'parent.'+pCallbackFunctionNm);
				//argoAlert('warning', '통화내역 조회사유를 성공적으로 저장 하였습니다.','', 'LoadingWithMask(); ' + 'parent.'+pCallbackFunctionNm);
				//fnSearchList02(argoNullConvert(w2ui.grid.getCellValue(w2ui.grid.getSelection()[0],1)));
			}
		} catch (e) {
			console.log(e);
		}
	}
	
	
	function fnProgressViewSearch(callback) {
		// 화면에 로딩 마스크를 표시하는 코드
		// 이 함수 내에서 비동기 작업이 수행됩니다.
		parent.LoadingWithMask();
		
		// 비동기 작업 완료 후, fnSearchListCnt 함수 호출
		setTimeout(function() {
				// 비동기 작업 완료 후에 fnSearchListCnt 함수 호출
				//parent.fnSearchListCnt();
				callback();
				setTimeout(function() {
					// 비동기 작업 완료 후에 fnSearchListCnt 함수 호출
					//parent.fnSearchListCnt();
					argoPopupClose();
			}, 0);
		}, 0); // 대기 시간을 0으로 설정
	}
	
	
	
</script>
</head>
<body>
	<div class="sub_wrap pop hAuto">
		<section class="pop_contents">
			<div class="pop_cont">
				<div class="btn_topArea">
					<span class="btn_r">
						<button type="button" class="btn_sm save" id="btnSave" name="btnSave" data-grant="W">저장</button>
						<button type="button" id="btnClose" class="btn_sm delete">닫기</button>
					</span>
				</div>
				<div class="input_area">
					<table class="input_table">
						<colgroup>
							<col width="120">
							<col width="">
						</colgroup>
						<tbody>
							<!-- <tr>
								<td>조회조건</td>
								<td><textarea id="ip_SearchCondition" name="ip_SearchCondition" style="height: 270px;" readonly="readonly"></textarea></td>
							</tr> -->

							<tr>
								<td>
									<span style="font-size: 17px; color: #e80101;">*</span>조회사유
								</td>
								<td>
									<select id="ip_ReasonCode" name="ip_ReasonCode" disabled style="background-color: #ffffff; width: 190px; border: 0.5px solid #eaeaea;"></select>
								</td>
							<tr>
								<td><span style="font-size: 17px; color: #e80101;">*</span>메모</td>
								<td><textarea id="ip_Memo" name="ip_Memo" style="border: 0.5px solid #eaeaea; height: 130px;" placeholder="마스킹해제 사유를 입력하세요."></textarea></td>
							</tr>
						</tbody>
					</table>
				</div>
			</div>
		</section>
	</div>
</body>

</html>
