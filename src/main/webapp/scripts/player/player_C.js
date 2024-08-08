var isClick			= false;
// var playCallback = null;
var audio			= null;
var playObject		= null;
	
var sttPlayer	= function()
{
	var seekT, seekLoc;
	var _sArea, _seekBar, _tProgress, _tTime, _sHover, _insTime;
	
	this.play_pause = function(callback)
	{
		if(audio.paused)
		{
			if (!callback())
				return;
			
			try
			{
				
				
				var promise	= audio.play();
				if (promise !== undefined)
				{
					promise.catch (error => 
					{
						$('#playPause img').prop('src','../images/player/play.png');
						$('#playPause img').css('margin-left','7px');
						$('#playPause i').attr('class','fa fa-play');
						argoAlert("청취파일을 받지 못했거나 잘못되어 실행하는데 실패하였습니다.");
						return;						
					});
				}
				var newDnno = w2ui['grid'].records[w2ui['grid'].getSelection()[0]].recurl;
				newDnno = newDnno.split("/");
				newDnno = newDnno[newDnno.length-1].split(".mp3")[0];
				var newrecTime = w2ui['grid'].records[w2ui['grid'].getSelection()[0]].recTime;
				
				$("#rtVEL").text(newrecTime);
				$("#dnVEL").text(newDnno);
				$('#playPause img').prop('src','../images/player/pause.png');
				$('#playPause img').css('margin-left','4px');				
				$('#playPause i').attr('class','fa fa-pause');
	
				// 구간반복 Start
		 		audio.addEventListener("timeupdate", function() {
		 			if($("#repeat_btn").attr("name") && $("#gstime").val() != "" && $("#getime").val() != "") {
			 			var ssc = (parseInt( $("#gstime").val().split(":")[0] ) * 60) + (parseInt( $("#gstime").val().split(":")[1] ));
			 			var esc = (parseInt( $("#getime").val().split(":")[0] ) * 60) + (parseInt( $("#getime").val().split(":")[1] ));
			 			
			 			if(esc <= audio.currentTime){
			 				audio.currentTime = ssc;
			 			}
		 			}
		 		}, false);
		 		// 구간반복 End
			}
			catch (ex)
			{
				console.log(ex);
				$('#playPause img').prop('src','../images/player/play.png');
				$('#playPause img').css('margin-left','7px');
				$('#playPause i').attr('class','fa fa-play');	
				argoAlert("청취파일을 받지 못했거나 잘못되어 실행하는데 실패하였습니다.");
				return;
			}
		}
		else
		{
			audio.pause();
			$('#playPause img').prop('src','../images/player/play.png');
			$('#playPause img').css('margin-left','7px');
			$('#playPause i').attr('class','fa fa-play');			
		}
		
		return;
	}
	
	this.play_back = function()
	{
		audio.currentTime	= audio.currentTime - 10;
	}
	
	this.play_quick = function()
	{
		audio.currentTime	= audio.currentTime + 10;
	}
	
	this.setSpeed = function(event)
	{
		audio.playbackRate	= event.data.speed;
	}
	
	this.showHover = function(event)
	{
		var seekBarPos 	= _seekBar.offset(); 
		var areaWidth	= _sArea.outerWidth();
		var curPos		= _seekBar.css('margin-left').replace('px', '');
		seekT 			= event.clientX - seekBarPos.left;
		var resultPos	= parseInt(curPos) + parseInt(seekT);
		// console.log('state : ' + resultPos + '=' + parseInt(curPos) + '+' +
		// parseInt(seekT));

		seekLoc 		= audio.duration * (resultPos / areaWidth);
		// console.log('loc : ' + seekLoc);
		
		_sHover.width(seekT);
		
		var cM = seekLoc / 60;
		
		var ctMinutes = Math.floor(cM);
		var ctSeconds = Math.floor(seekLoc - ctMinutes * 60);
		
		if( (ctMinutes < 0) || (ctSeconds < 0) )
			return;
		
		if(ctMinutes < 10)
			ctMinutes = '0'+ctMinutes;
		if(ctSeconds < 10)
			ctSeconds = '0'+ctSeconds;
		
		_insTime.text(ctMinutes+':'+ctSeconds).css({'left':resultPos,'margin-left':'10px'}).fadeIn(0);
		// insTime.text(ctMinutes+':'+ctSeconds);
	}
	
	this.hideHover = function()
	{
		_sHover.width(0);
		_insTime.text('00:00').css({'left':'0px','margin-left':'0px'}).fadeOut(0);		
	}
	
	this.areaCheck = function()
	{
		audio.currentTime = seekLoc;
		var curPos		= _seekBar.css('margin-left').replace('px', '');
		var resultPos	= (parseInt(curPos) + parseInt(seekT)) + 'px';
		_seekBar.css({'margin-left': resultPos});
		isClick	= true;
		playObject.hideHover();

		// 구간반복 선택 Start
		if($("#repeat_btn").attr("name")) {
			var cM = seekLoc / 60;
			
			var ctMinutes = Math.floor(cM);
			var ctSeconds = Math.floor(seekLoc - ctMinutes * 60);
			
			if( (ctMinutes < 0) || (ctSeconds < 0) ) { return; }
			
			if(ctMinutes < 10) { ctMinutes = '0'+ctMinutes; }
			if(ctSeconds < 10) { ctSeconds = '0'+ctSeconds; }
			
			if(clickCnt == 0) {
				$("#gstime").val(ctMinutes+":"+ctSeconds);
				clickCnt = 1;
				
				$("#progress-gspin").css("display", "block");
//				$("#progress-gspin").css("margin-left", (parseInt(resultPos)-5)+"px");
				$("#progress-gspin").css("margin-left", (parseInt(resultPos))+"px");
			} else if(clickCnt == 1) {
				
				$("#getime").val(ctMinutes+":"+ctSeconds);

				var clickSTime = $("#gstime").val();
				var clickETime = $("#getime").val();
				if(clickETime < clickSTime) {
					$("#gstime").val(clickETime);
					$("#getime").val(clickSTime);
				}

				clickCnt = 2;
				
				$("#progress-gepin").css("display", "block");
//				$("#progress-gepin").css("margin-left", (parseInt(resultPos)-5)+"px");
				$("#progress-gepin").css("margin-left", (parseInt(resultPos))+"px");
			}
		}
		// 구간반복 선택 End
	}
	
	
	this.updateCurrTime = function () {
		var curMinutes = Math.floor(audio.currentTime / 60);
		var curSeconds = Math.floor(audio.currentTime - curMinutes * 60);
		
		var durMinutes = Math.floor(audio.duration / 60);
		var durSeconds = Math.floor(audio.duration - durMinutes * 60);
		
		var playProgress = (audio.currentTime / audio.duration) * 100;
		// console.log('proc : ' + playProgress);
		
		if(curMinutes < 10)
			curMinutes = '0'+curMinutes;
		if(curSeconds < 10)
			curSeconds = '0'+curSeconds;
		
		if(durMinutes < 10)
			durMinutes = '0'+durMinutes;
		if(durSeconds < 10)
			durSeconds = '0'+durSeconds;
		
		_tProgress.text(curMinutes+':'+curSeconds);
		
		_tTime.text(durMinutes+':'+durSeconds);
		
		// seekBar.width(playProgress+'%');
		
		if (!isClick)
		{
			var areaWidth	= _sArea.outerWidth();
			var curSeekT	= (areaWidth / 100) * playProgress;
			// console.log('cur seek : ' + curSeekT);
			_seekBar.css({'margin-left': curSeekT + 'px'});
		}

		isClick	= false;
		// alert("다음?");
		if( playProgress == 100 )
		{
			$('#playPause i').attr('class','fa fa-play');
			// seekBar.width(0);
			_seekBar.css({'margin-left': 0});
			_tProgress.text('00:00');
		}
	}
	
	this.stop_play = function()
	{
		audio.pause();
	}
	
	this.initPlayer = function(sArea, seekBar, tProgress, tTime, sHover, insTime)
	{
		// var _sArea, _seekBar, _tProgress, _tTime, _sHover, _insTime;
		_sArea		= sArea;
		_seekBar	= seekBar,
		_tTime		= tTime;
		_tProgress	= tProgress;
		_sHover		= sHover,
		_insTime	= insTime;
		
		playObject		= this;
		// console.log(playObject);
		// playCallback = callback;
		
		try
		{
			audio 			= new Audio();
			// audio.src = source;
			audio.loop 		= false;
		}
		catch (ex)
		{
			console.log(ex.getMessage());
		}
		
		$(audio).on('timeupdate',this.updateCurrTime);		
	}
}