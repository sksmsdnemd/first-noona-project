<%@ page language="java" pageEncoding="UTF-8" contentType="text/html; charset=UTF-8"%>

<%@ page import="java.util.Map" %>
<%@ page import="net.sf.json.JSONObject"%>
<%@ page import="egovframework.com.cmm.util.EgovUserDetailsHelper" %>

<!DOCTYPE html>
<html lang="ko">
<head>

<jsp:include page="/WEB-INF/jsp/include/common.jsp" flush="true" />

<%
    JSONObject jsonLoginInfo = JSONObject.fromObject((Map) EgovUserDetailsHelper.getAuthenticatedUser(request));
%>

<script type="text/javascript">
    $(document).ready(function(e) {
        var loginInfo = {SVCCOMMONID : {rows : <%=jsonLoginInfo%>}};
        //console.log("loginInfo", loginInfo);

        sessionStorage['loginInfo'] = JSON.stringify(loginInfo);	//HTML5 sessionStorage : IE8이하 에선 수행되지않음
        window.setTimeout(function() { window.location.replace(gGlobal.ROOT_PATH + "/common/VMainF.do"); }, 500);
    });

</script>
</head>
</html>
