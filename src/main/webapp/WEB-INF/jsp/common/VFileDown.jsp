<%@ page language="java" pageEncoding="UTF-8" contentType="text/html; charset=UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html lang="ko">
<head>
<title>VELOCE-DOWNLOAD</title>
<meta charset="UTF-8">
<meta http-equiv="X-UA-Compatible" content="IE=Edge,chrome=1">
<meta name="author" content="ARGO" />
<meta name="description" content="ARGO" />
<meta name="keywords" content="ARGO" />

<jsp:include page="/WEB-INF/jsp/include/common.jsp" flush="true" /> 
<link rel="stylesheet" href="<c:url value="/css/argo.main.css?ver=20170103"/>" type="text/css" />
<link rel="stylesheet" href="<c:url value="/css/w2ui-1.5.rc1.css"/>" type="text/css" />
<link rel="stylesheet" href="<c:url value="/css/w2ui-1.5.rc1.min.css"/>" type="text/css" />
<script type="text/javascript" src="<c:url value="/scripts/jquery/jquery-1.11.3.min.js"/>"></script>
<script type="text/javascript" src="<c:url value="/scripts/argojs/w2ui-1.5.rc1.js"/>"></script>
<script type="text/javascript" src="<c:url value="/scripts/argojs/w2ui-1.5.rc1.min.js"/>"></script>
<script type="text/javascript" src="<c:url value="/scripts/jquery/jquery.scrollbar.min.js"/>"></script>
<script type="text/javascript" src="<c:url value="/scripts/argojs/argo.alert.js"/>"></script> 

<script>

	$(document).ready(function() {
	});
	
</script>

</head>
<body>
	<div class="sub_wrap pop">
        <section class="sub_contents" style="width:810px">
			<div class="search_area row2">
				<div class="row">
					<ul class="search_terms">
						<li>&nbsp;</li>
					</ul>
				</div>
				<div class="row">
					<ul class="search_terms">
						<li><strong>VELOCE 파일다운로드</strong>
						</li>
					</ul>
				</div>
			</div>
            <div class="h136">
	            <div class="input_area">
	            	<table class="input_table">
	            		<colgroup>
							<col width="150px">
                            <col width="150px">
                           	<col width="200px">
                            <col width="300px">
						</colgroup>
						<tbody>
							<tr>
								<th rowspan="5"><strong>VELOCE Player</strong></th>
								<th rowspan="3"><strong>ActiveX사용</strong></th>
								<th><strong>재생기 Cab 파일</strong></th>
								<td><span><a href="/BT-VELOCE/data/PlayerATL.cab" >재생기 Cab 파일 다운로드</a></span></td>
							</tr>
							<tr>
								<th><strong>재생기 DLL 파일</strong></th>
								<td><span><a href="/BT-VELOCE/data/PlayerATL.zip" >재생기 DLL 파일 다운로드</a></span></td>
							</tr>
							<tr>
								<th><strong>ActiveX 삭제 프로그램</strong></th>
								<td><span><a href="/BT-VELOCE/data/player_unreg.zip" >ActiveX 삭제 프로그램  다운로드</a></span></td>
							</tr>
							<tr>
								<th><strong>ActiveX 미사용</strong></th>
								<th><strong>재생기 설치 프로그램</strong></th>
								<td><span><a href="/BT-VELOCE/data/VLCPlayer_NonActiveX.exe" >재생기 설치 프로그램 다운로드</a></span></td>
							</tr>
							<tr>
								<th><strong>코덱</strong></th>
								<th><strong>723코덱</strong></th>
								<td><span><a href="/BT-VELOCE/data/msg723.zip" >723코덱 다운로드</a></span></td>
							</tr>
							<tr>
								<th rowspan="2"><strong>VELOCE Manual</strong></th>
								<th><strong>사용자</strong></th>
								<th><strong>사용자 가이드</strong></th>
								<td><span><a href="/BT-VELOCE/data/VELOCE_MWU_User_Guide.pdf" >사용자 가이드 파일 다운로드</a></span></td>
							</tr>
							<tr>
								<th><strong>운영자</strong></th>
								<th><strong>운영자 가이드</strong></th>
								<td><span><!-- <a href="/BT-VELOCE/data/VELOCE_MWU_User_Guide.pdf" >운영자 가이드 파일 다운로드</a> --></span></td>
							</tr>
						</tbody>	
					</table>		
				</div>
	        </div>
        </section>
    </div>
</body>

</html>							