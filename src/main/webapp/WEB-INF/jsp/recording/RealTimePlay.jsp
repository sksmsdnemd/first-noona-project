<%@ page language="java" pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<!doctype html>
<html>
<head>
    <jsp:include page="/WEB-INF/jsp/include/common.jsp" flush="true"/>
    <%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
    <link rel="stylesheet" href="../css/realPlayerSkin.css">
<body>
<div id="playerCover">
    <div class="vel-wave ready">
        <img src="../images/player/real_bg.png"/>
        <br/>
        <span id="playStatus"></span>
    </div>
    <div class="info">
        <ul class="play_info">
            <li> 내선번호<span id="agentDn"></span></li>
            <li class="btn_play">
                <button id="playPause" onclick="play(this)"><img src="../images/player/real_play.png"/></button>
            </li>
            <li> 상담사<span id="agentName" style="padding-left: 10px;"></span></li>
        </ul>
    </div>
    <div class="loading hidden">
        <div class="circle bounce1"></div>
        <div class="circle bounce2"></div>
        <div class="circle bounce3"></div>
        <div class="circle bounce4"></div>
        <div class="circle bounce5"></div>
        <div class="circle bounce6"></div>
        <p class="loading_txt">loading..</p>
    </div>


    <div class="vel-wave play hidden">
        <div class="visual vel-rect1"></div>
        <div class="visual vel-rect2"></div>
        <div class="visual vel-rect3"></div>
        <div class="visual vel-rect4"></div>
        <div class="visual vel-rect5"></div>
        <div class="visual vel-rect6"></div>
        <div class="visual vel-rect7"></div>
        <div class="visual vel-rect8"></div>
        <div class="visual vel-rect9"></div>
        <div class="visual vel-rect10"></div>
        <div class="visual vel-rect11"></div>
        <div class="visual vel-rect12"></div>
        <br/>
    </div>
</div>
</body>

</html>
<script type="text/javascript">
    $(function () {

        var loginInfo = JSON.parse(sessionStorage.getItem("loginInfo"));
        sPopupOptions = parent.gPopupOptions || {};
        sPopupOptions.get = function (key, value) {
            return this[key] === undefined ? value : this[key];
        };

        $("#agentDn").text(sPopupOptions.agentDn);
        $("#agentName").text(sPopupOptions.agentName + " ( " + sPopupOptions.agentId + " ) ");


    });

    var setTextInterval;

    function play(obj) {

        parent.rPlay();


        $('div .loading').removeClass("hidden");
        $('div .vel-wave.ready').addClass("hidden");
        $('div .vel-wave.play').addClass("hidden");
        parent.playStatus = "CW";

        setTextInterval = setInterval(function () {

            /* parant.playStatus
            *  W : 통화 대기 중
            *  C : 통화 중
            *  CW: 연결 대기 중*/

            if (parent.playStatus == "W") {
                /* 재생 전 상태 ( 통화 대기 중 )
                *  재생 준비 화면
                *  정지버튼 stop() ->플레이 버튼 play() */
                $(obj).attr("onclick", "play(this);");
                $(obj).html('<img src="../images/player/real_play.png"/>');
                $('div .vel-wave.ready').removeClass("hidden");
                $('div .vel-wave.play').addClass("hidden");
                $('div .loading').addClass("hidden");

            } else if (parent.playStatus == "C") {

                /* 통화 중일 때
                *  플레이 버튼 -> 정지버튼
                *  play() - > stop()
                *  로딩바 hide
                *  play 애니매이션 show
                *  준비 이미지 hide */

                $(obj).attr("onclick", "stop(this);");
                $(obj).html('<img src="../images/player/real_stop.png"/>');


                $('div .vel-wave.ready').addClass("hidden");
                $('div .vel-wave.play').removeClass("hidden");
                $('div .loading').addClass("hidden");
            } else {

                /* 연결대기중
                * 정지버튼 ( play 된 상태에서 통화가 중지된 상황 - 다음 콜 연결 대기)
                * 플레이 화면- 준비상태이나 버튼은 정지버튼이 표출
                * */

                $('div .loading').removeClass("hidden");
                $('div .vel-wave.ready').addClass("hidden");
                $('div .vel-wave.play').addClass("hidden");

            }
        }, 1000);



    }

    function stop(obj) {

        clearInterval(setTextInterval);
        parent.rStop();
        $('div .vel-wave.ready').removeClass("hidden");
        $('div .vel-wave.play').addClass("hidden");
        $('div .loading').addClass("hidden");
        $(obj).attr("onclick", "play(this);");
        $(obj).html('<img src="../images/player/real_play.png"/>');

    }


</script>