(function(f){if(typeof exports==="object"&&typeof module!=="undefined"){module.exports=f()}else if(typeof define==="function"&&define.amd){define([],f)}else{var g;if(typeof window!=="undefined"){g=window}else if(typeof global!=="undefined"){g=global}else if(typeof self!=="undefined"){g=self}else{g=this}g.WavPlayer = f()}})(function(){var define,module,exports;return (function(){function r(e,n,t){function o(i,f){if(!n[i]){if(!e[i]){var c="function"==typeof require&&require;if(!f&&c)return c(i,!0);if(u)return u(i,!0);var a=new Error("Cannot find module '"+i+"'");throw a.code="MODULE_NOT_FOUND",a}var p=n[i]={exports:{}};e[i][0].call(p.exports,function(r){var n=e[i][1][r];return o(n||r)},p,p.exports,r,e,n,t)}return n[i].exports}for(var u="function"==typeof require&&require,i=0;i<t.length;i++)o(t[i]);return o}return r})()({1:[function(require,module,exports){
"use strict";

Object.defineProperty(exports, "__esModule", {
    value: true
});

var _wavify = require("./wavify");

var _wavify2 = _interopRequireDefault(_wavify);

var _concat = require("./concat");

var _concat2 = _interopRequireDefault(_concat);



function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { default: obj }; }

var pad = function pad(buffer) {
    var currentSample = new Float32Array(1);

    buffer.copyFromChannel(currentSample, 0, 0);

    var wasPositive = currentSample[0] > 0;

    for (var i = 0; i < buffer.length; i += 1) {
        buffer.copyFromChannel(currentSample, 0, i);

        if (wasPositive && currentSample[0] < 0 || !wasPositive && currentSample[0] > 0) {
            break;
        }

        currentSample[0] = 0;
        buffer.copyToChannel(currentSample, 0, i);
    }

    buffer.copyFromChannel(currentSample, 0, buffer.length - 1);

    wasPositive = currentSample[0] > 0;

    for (var _i = buffer.length - 1; _i > 0; _i -= 1) {
        buffer.copyFromChannel(currentSample, 0, _i);

        if (wasPositive && currentSample[0] < 0 || !wasPositive && currentSample[0] > 0) {
            break;
        }

        currentSample[0] = 0;
        buffer.copyToChannel(currentSample, 0, _i);
    }

    return buffer;
};

var WavPlayer = function WavPlayer() {
    var context = void 0;

    var hasCanceled_ = false;

    var _play = function _play(url) {
        var nextTime = 0;
        var audioStack = [];

        hasCanceled_ = false;

        context = new AudioContext();

        var scheduleBuffersTimeoutId = null;

        var scheduleBuffers = function scheduleBuffers() {
            if (hasCanceled_) {
                scheduleBuffersTimeoutId = null;

                return;
            }

            while (audioStack.length > 0 && audioStack[0].buffer !== undefined && nextTime < context.currentTime + 2) {
                var currentTime = context.currentTime;

                var source = context.createBufferSource();

                var segment = audioStack.shift();

                source.buffer = pad(segment.buffer);
                source.connect(context.destination);

                if (nextTime == 0) {
                    nextTime = currentTime + 0.7; /// add 700ms latency to work well across systems - tune this if you like
                }

                var duration = source.buffer.duration;
                var offset = 0;

                if (currentTime > nextTime) {
                    offset = currentTime - nextTime;
                    nextTime = currentTime;
                    duration = duration;
                }
				//if (currentTime > nextTime) {
                //    offset = currentTime - nextTime;
                //    nextTime = currentTime;
                //    duration = duration - offset;
                //}
				//console.log('***********************************************');
				//console.log('offset = ' + offset);
				//console.log('currentTime = ' + currentTime);
				//console.log('nextTime = ' + nextTime);
				//console.log('duration = ' + duration);
				//console.log('***********************************************');
                source.start(nextTime, offset);
                source.stop(nextTime + duration);
                nextTime += duration; // Make the next buffer wait the length of the last buffer before being played

//                $("#twice").val(nextTime);
                tmpNextTime = nextTime;
            }

            scheduleBuffersTimeoutId = setTimeout(function () {
                return scheduleBuffers();
            }, 10);
        };

        return fetch(url).then(function (response) {
            setTimeout(function () {
                var reader = response.body.getReader();

                // This variable holds a possibly dangling byte.
                var rest = null;

                var isFirstBuffer = true;
                var numberOfChannels = void 0,
                    sampleRate = void 0;

                var read = function read() {
                    return reader.read().then(function (_ref) {
                        var value = _ref.value,
                            done = _ref.done;

                        if (hasCanceled_) {
                            reader.cancel();

                            return;
                        }
                        if (value && value.buffer) {
                            var buffer = void 0,
                                segment = void 0;

                            if (rest !== null) {
                                buffer = (0, _concat2.default)(rest, value.buffer);
                            } else {
                                buffer = value.buffer;
                            }

                            // Make sure that the first buffer is lager then 44 bytes.
                            if (isFirstBuffer && buffer.byteLength <= 12288) {
                                rest = buffer;
                                read();

                                return;
                            }

                            // If the header has arrived try to derive the numberOfChannels and the
                            // sampleRate of the incoming file.
                            if (isFirstBuffer) {
                                isFirstBuffer = false;

                                var dataView = new DataView(buffer);

                                numberOfChannels = dataView.getUint16(22, true);
                                sampleRate = dataView.getUint32(24, true);

                                buffer = buffer.slice(44);
                            }

                            if (buffer.byteLength % 2 !== 0) {
                                rest = buffer.slice(-2, -1);
                                buffer = buffer.slice(0, -1);
                            } else {
                                rest = null;
                            }

                            segment = {};

                            audioStack.push(segment);

                            context.decodeAudioData((0, _wavify2.default)(buffer, numberOfChannels, sampleRate)).then(function (audioBuffer) {
                                segment.buffer = audioBuffer;

                                if (scheduleBuffersTimeoutId === null) {
                                    scheduleBuffers();
                                }
                            });
                        }

                        if (done) {
                            return;
                        }

                        // continue reading
                        read();
                    });
                };

                // start reading
                read();
            }, 1000);
        });
    };

    return {
        play: function play(url) {
            return _play(url);
        },
        stop: function stop() {
            hasCanceled_ = true;
            if (context) {
                context.close();
            }
        }
    };
};

exports.default = WavPlayer;

},{"./concat":2,"./wavify":4}],2:[function(require,module,exports){
"use strict";

Object.defineProperty(exports, "__esModule", {
  value: true
});
// Concat two ArrayBuffers
var concat = function concat(buffer1, buffer2) {
  var tmp = new Uint8Array(buffer1.byteLength + buffer2.byteLength);

  tmp.set(new Uint8Array(buffer1), 0);
  tmp.set(new Uint8Array(buffer2), buffer1.byteLength);

  return tmp.buffer;
};

exports.default = concat;

},{}],3:[function(require,module,exports){
"use strict";

Object.defineProperty(exports, "__esModule", {
  value: true
});

var _WavPlayer = require("./WavPlayer");

var _WavPlayer2 = _interopRequireDefault(_WavPlayer);

function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { default: obj }; }

exports.default = _WavPlayer2.default;

module.exports = _WavPlayer2.default;

},{"./WavPlayer":1}],4:[function(require,module,exports){
"use strict";

Object.defineProperty(exports, "__esModule", {
    value: true
});

var _concat = require("./concat");

var _concat2 = _interopRequireDefault(_concat);

function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { default: obj }; }

// Write a proper WAVE header for the given buffer.
var wavify = function wavify(data, numberOfChannels, sampleRate) {
    var header = new ArrayBuffer(44);

    var d = new DataView(header);

    d.setUint8(0, "R".charCodeAt(0));
    d.setUint8(1, "I".charCodeAt(0));
    d.setUint8(2, "F".charCodeAt(0));
    d.setUint8(3, "F".charCodeAt(0));

    d.setUint32(4, data.byteLength / 2 + 44, true);

    d.setUint8(8, "W".charCodeAt(0));
    d.setUint8(9, "A".charCodeAt(0));
    d.setUint8(10, "V".charCodeAt(0));
    d.setUint8(11, "E".charCodeAt(0));
    d.setUint8(12, "f".charCodeAt(0));
    d.setUint8(13, "m".charCodeAt(0));
    d.setUint8(14, "t".charCodeAt(0));
    d.setUint8(15, " ".charCodeAt(0));

    d.setUint32(16, 16, true);
    d.setUint16(20, 1, true);
    d.setUint16(22, numberOfChannels, true);
    d.setUint32(24, sampleRate, true);
    d.setUint32(28, sampleRate * 1 * 2);
    d.setUint16(32, numberOfChannels * 2);
    d.setUint16(34, 16, true);

    d.setUint8(36, "d".charCodeAt(0));
    d.setUint8(37, "a".charCodeAt(0));
    d.setUint8(38, "t".charCodeAt(0));
    d.setUint8(39, "a".charCodeAt(0));
    d.setUint32(40, data.byteLength, true);

    return (0, _concat2.default)(header, data);
};

exports.default = wavify;

},{"./concat":2}]},{},[3])(3)
});

//# sourceMappingURL=data:application/json;charset=utf-8;base64,eyJ2ZXJzaW9uIjozLCJzb3VyY2VzIjpbIm5vZGVfbW9kdWxlcy9icm93c2VyLXBhY2svX3ByZWx1ZGUuanMiLCJzcmMvV2F2UGxheWVyLmpzIiwic3JjL2NvbmNhdC5qcyIsInNyYy9pbmRleC5qcyIsInNyYy93YXZpZnkuanMiXSwibmFtZXMiOltdLCJtYXBwaW5ncyI6IkFBQUE7Ozs7Ozs7QUNBQTs7OztBQUNBOzs7Ozs7QUFFQSxJQUFNLE1BQU0sU0FBTixHQUFNLFNBQVU7QUFDbEIsUUFBTSxnQkFBZ0IsSUFBSSxZQUFKLENBQWlCLENBQWpCLENBQXRCOztBQUVBLFdBQU8sZUFBUCxDQUF1QixhQUF2QixFQUFzQyxDQUF0QyxFQUF5QyxDQUF6Qzs7QUFFQSxRQUFJLGNBQWMsY0FBYyxDQUFkLElBQW1CLENBQXJDOztBQUVBLFNBQUssSUFBSSxJQUFJLENBQWIsRUFBZ0IsSUFBSSxPQUFPLE1BQTNCLEVBQW1DLEtBQUssQ0FBeEMsRUFBMkM7QUFDdkMsZUFBTyxlQUFQLENBQXVCLGFBQXZCLEVBQXNDLENBQXRDLEVBQXlDLENBQXpDOztBQUVBLFlBQUssZUFBZSxjQUFjLENBQWQsSUFBbUIsQ0FBbkMsSUFBMEMsQ0FBQyxXQUFELElBQWdCLGNBQWMsQ0FBZCxJQUFtQixDQUFqRixFQUFxRjtBQUNqRjtBQUNIOztBQUVELHNCQUFjLENBQWQsSUFBbUIsQ0FBbkI7QUFDQSxlQUFPLGFBQVAsQ0FBcUIsYUFBckIsRUFBb0MsQ0FBcEMsRUFBdUMsQ0FBdkM7QUFDSDs7QUFFRCxXQUFPLGVBQVAsQ0FBdUIsYUFBdkIsRUFBc0MsQ0FBdEMsRUFBeUMsT0FBTyxNQUFQLEdBQWdCLENBQXpEOztBQUVBLGtCQUFjLGNBQWMsQ0FBZCxJQUFtQixDQUFqQzs7QUFFQSxTQUFLLElBQUksS0FBSSxPQUFPLE1BQVAsR0FBZ0IsQ0FBN0IsRUFBZ0MsS0FBSSxDQUFwQyxFQUF1QyxNQUFLLENBQTVDLEVBQStDO0FBQzNDLGVBQU8sZUFBUCxDQUF1QixhQUF2QixFQUFzQyxDQUF0QyxFQUF5QyxFQUF6Qzs7QUFFQSxZ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ZjtBQUNBLE1BQUUsUUFBRixDQUFXLEVBQVgsRUFBZSxJQUFJLFVBQUosQ0FBZSxDQUFmLENBQWY7QUFDQSxNQUFFLFFBQUYsQ0FBVyxFQUFYLEVBQWUsSUFBSSxVQUFKLENBQWUsQ0FBZixDQUFmO0FBQ0EsTUFBRSxTQUFGLENBQVksRUFBWixFQUFnQixLQUFLLFVBQXJCLEVBQWlDLElBQWpDOztBQUVBLFdBQU8sc0JBQU8sTUFBUCxFQUFlLElBQWYsQ0FBUDtBQUNILENBcENEOztrQkFzQ2UsTSIsImZpbGUiOiJnZW5lcmF0ZWQuanMiLCJzb3VyY2VSb290IjoiIiwic291cmNlc0NvbnRlbnQiOlsiKGZ1bmN0aW9uKCl7ZnVuY3Rpb24gcihlLG4sdCl7ZnVuY3Rpb24gbyhpLGYpe2lmKCFuW2ldKXtpZighZVtpXSl7dmFyIGM9XCJmdW5jdGlvblwiPT10eXBlb2YgcmVxdWlyZSYmcmVxdWlyZTtpZighZiYmYylyZXR1cm4gYyhpLCEwKTtpZih1KXJldHVybiB1KGksITApO3ZhciBhPW5ldyBFcnJvcihcIkNhbm5vdCBmaW5kIG1vZHVsZSAnXCIraStcIidcIik7dGhyb3cgYS5jb2RlPVwiTU9EVUxFX05PVF9GT1VORFwiLGF9dmFyIHA9bltpXT17ZXhwb3J0czp7fX07ZVtpXVswXS5jYWxsKHAuZXhwb3J0cyxmdW5jdGlvbihyKXt2YXIgbj1lW2ldWzFdW3JdO3JldHVybiBvKG58fHIpfSxwLHAuZXhwb3J0cyxyLGUsbix0KX1yZXR1cm4gbltpXS5leHBvcnRzfWZvcih2YXIgdT1cImZ1bmN0aW9uXCI9PXR5cGVvZiByZXF1aXJlJiZyZXF1aXJlLGk9MDtpPHQubGVuZ3RoO2krKylvKHRbaV0pO3JldHVybiBvfXJldHVybiByfSkoKSIsImltcG9ydCB3YXZpZnkgZnJvbSBcIi4vd2F2aWZ5XCI7XG5pbXBvcnQgY29uY2F0IGZyb20gXCIuL2NvbmNhdFwiO1xuXG5jb25zdCBwYWQgPSBidWZmZXIgPT4ge1xuICAgIGNvbnN0IGN1cnJlbnRTYW1wbGUgPSBuZXcgRmxvYXQzMkFycmF5KDEpO1xuXG4gICAgYnVmZmVyLmNvcHlGcm9tQ2hhbm5lbChjdXJyZW50U2FtcGxlLCAwLCAwKTtcblxuICAgIGxldCB3YXNQb3NpdGl2ZSA9IGN1cnJlbnRTYW1wbGVbMF0gPiAwO1xuXG4gICAgZm9yIChsZXQgaSA9IDA7IGkgPCBidWZmZXIubGVuZ3RoOyBpICs9IDEpIHtcbiAgICAgICAgYnVmZmVyLmNvcHlGcm9tQ2hhbm5lbChjdXJyZW50U2FtcGxlLCAwLCBpKTtcblxuICAgICAgICBpZiAoKHdhc1Bvc2l0aXZlICYmIGN1cnJlbnRTYW1wbGVbMF0gPCAwKSB8fCAoIXdhc1Bvc2l0aXZlICYmIGN1cnJlbnRTYW1wbGVbMF0gPiAwKSkge1xuICAgICAgICAgICAgYnJlYWs7XG4gICAgICAgIH1cblxuICAgICAgICBjdXJyZW50U2FtcGxlWzBdID0gMDtcbiAgICAgICAgYnVmZmVyLmNvcHlUb0NoYW5uZWwoY3VycmVudFNhbXBsZSwgMCwgaSk7XG4gICAgfVxuXG4gICAgYnVmZmVyLmNvcHlGcm9tQ2hhbm5lbChjdXJyZW50U2FtcGxlLCAwLCBidWZmZXIubGVuZ3RoIC0gMSk7XG5cbiAgICB3YXNQb3NpdGl2ZSA9IGN1cnJlbnRTYW1wbGVbMF0gPiAwO1xuXG4gICAgZm9yIChsZXQgaSA9IGJ1ZmZlci5sZW5ndGggLSAxOyBpID4gMDsgaSAtPSAxKSB7XG4gICAgICAgIGJ1ZmZlci5jb3B5RnJvbUNoYW5uZWwoY3VycmVudFNhbXBsZSwgMCwgaSk7XG5cbiAgICAgICAgaWYgKCh3YXNQb3NpdGl2ZSAmJiBjdXJyZW50U2FtcGxlWzBdIDwgMCkgfHwgKCF3YXNQb3NpdGl2ZSAmJiBjdXJyZW50U2FtcGxlWzBdID4gMCkpIHtcbiAgICAgICAgICAgIGJyZWFrO1xuICAgICAgICB9XG5cbiAgICAgICAgY3VycmVudFNhbXBsZVswXSA9IDA7XG4gICAgICAgIGJ1ZmZlci5jb3B5VG9DaGFubmVsKGN1cnJlbnRTYW1wbGUsIDAsIGkpO1xuICAgIH1cblxuICAgIHJldHVybiBidWZmZXI7XG59O1xuXG5jb25zdCBXYXZQbGF5ZXIgPSAoKSA9PiB7XG4gICAgbGV0IGNvbnRleHQ7XG5cbiAgICBsZXQgaGFzQ2FuY2VsZWRfID0gZmFsc2U7XG5cbiAgICBjb25zdCBwbGF5ID0gdXJsID0+IHtcbiAgICAgICAgbGV0IG5leHRUaW1lID0gMDtcblxuICAgICAgICBjb25zdCBhdWRpb1N0YWNrID0gW107XG5cbiAgICAgICAgaGFzQ2FuY2VsZWRfID0gZmFsc2U7XG5cbiAgICAgICAgY29udGV4dCA9IG5ldyBBdWRpb0NvbnRleHQoKTtcblxuICAgICAgICBsZXQgc2NoZWR1bGVCdWZmZXJzVGltZW91dElkID0gbnVsbDtcblxuICAgICAgICBjb25zdCBzY2hlZHVsZUJ1ZmZlcnMgPSAoKSA9PiB7XG4gICAgICAgICAgICBpZiAoaGFzQ2FuY2VsZWRfKSB7XG4gICAgICAgICAgICAgICAgc2NoZWR1bGVCdWZmZXJzVGltZW91dElkID0gbnVsbDtcblxuICAgICAgICAgICAgICAgIHJldHVybjtcbiAgICAgICAgICAgIH1cblxuICAgICAgICAgICAgd2hpbGUgKFxuICAgICAgICAgICAgICAgIGF1ZGlvU3RhY2subGVuZ3RoID4gMCAmJlxuICAgICAgICAgICAgICAgIGF1ZGlvU3RhY2tbMF0uYnVmZmVyICE9PSB1bmRlZmluZWQgJiZcbiAgICAgICAgICAgICAgICBuZXh0VGltZSA8IGNvbnRleHQuY3VycmVudFRpbWUgKyAyXG4gICAgICAgICAgICApIHtcbiAgICAgICAgICAgICAgICBjb25zdCBjdXJyZW50VGltZSA9IGNvbnRleHQuY3VycmVudFRpbWU7XG5cbiAgICAgICAgICAgICAgICBjb25zdCBzb3VyY2UgPSBjb250ZXh0LmNyZWF0ZUJ1ZmZlclNvdXJjZSgpO1xuXG4gICAgICAgICAgICAgICAgY29uc3Qgc2VnbWVudCA9IGF1ZGlvU3RhY2suc2hpZnQoKTtcblxuICAgICAgICAgICAgICAgIHNvdXJjZS5idWZmZXIgPSBwYWQoc2VnbWVudC5idWZmZXIpO1xuICAgICAgICAgICAgICAgIHNvdXJjZS5jb25uZWN0KGNvbnRleHQuZGVzdGluYXRpb24pO1xuXG4gICAgICAgICAgICAgICAgaWYgKG5leHRUaW1lID09IDApIHtcbiAgICAgICAgICAgICAgICAgICAgbmV4dFRpbWUgPSBjdXJyZW50VGltZSArIDE7IC8vLyBhZGQgNzAwbXMgbGF0ZW5jeSB0byB3b3JrIHdlbGwgYWNyb3NzIHN5c3RlbXMgLSB0dW5lIHRoaXMgaWYgeW91IGxpa2VcbiAgICAgICAgICAgICAgICB9XG5cbiAgICAgICAgICAgICAgICBsZXQgZHVyYXRpb24gPSBzb3VyY2UuYnVmZmVyLmR1cmF0aW9uO1xuICAgICAgICAgICAgICAgIGxldCBvZmZzZXQgPSAwO1xuXG4gICAgICAgICAgICAgICAgaWYgKGN1cnJlbnRUaW1lID4gbmV4dFRpbWUpIHtcbiAgICAgICAgICAgICAgICAgICAgLy9vZmZzZXQgPSBjdXJyZW50VGltZSAtIG5leHRUaW1lO1xuICAgICAgICAgICAgICAgICAgICBuZXh0VGltZSA9IGN1cnJlbnRUaW1lO1xuICAgICAgICAgICAgICAgICAgICBkdXJhdGlvbiA9IGR1cmF0aW9uOy8vIC0gb2Zmc2V0O1xuICAgICAgICAgICAgICAgIH1cblxuICAgICAgICAgICAgICAgIHNvdXJjZS5zdGFydChuZXh0VGltZSwgb2Zmc2V0KTtcbiAgICAgICAgICAgICAgICBzb3VyY2Uuc3RvcChuZXh0VGltZSArIGR1cmF0aW9uKTtcblxuICAgICAgICAgICAgICAgIG5leHRUaW1lICs9IGR1cmF0aW9uOyAvLyBNYWtlIHRoZSBuZXh0IGJ1ZmZlciB3YWl0IHRoZSBsZW5ndGggb2YgdGhlIGxhc3QgYnVmZmVyIGJlZm9yZSBiZWluZyBwbGF5ZWRcbiAgICAgICAgICAgIH1cblxuICAgICAgICAgICAgc2NoZWR1bGVCdWZmZXJzVGltZW91dElkID0gc2V0VGltZW91dCgoKSA9PiBzY2hlZHVsZUJ1ZmZlcnMoKSwgMTAwKTtcbiAgICAgICAgfTtcblxuICAgICAgICByZXR1cm4gZmV0Y2godXJsKS50aGVuKHJlc3BvbnNlID0+IHtcbiAgICAgICAgICAgIHNldFRpbWVvdXQoZnVuY3Rpb24oKSB7XG4gICAgICAgICAgICAgICAgY29uc29sZS5sb2coJ1N0YXJ0ISEhISEhISEhISEhIScpO1xuICAgICAgICAgICAgICAgIGNvbnN0IHJlYWRlciA9IHJlc3BvbnNlLmJvZHkuZ2V0UmVhZGVyKCk7XG5cbiAgICAgICAgICAgICAgICAvLyBUaGlzIHZhcmlhYmxlIGhvbGRzIGEgcG9zc2libHkgZGFuZ2xpbmcgYnl0ZS5cbiAgICAgICAgICAgICAgICB2YXIgcmVzdCA9IG51bGw7XG5cbiAgICAgICAgICAgICAgICBsZXQgaXNGaXJzdEJ1ZmZlciA9IHRydWU7XG4gICAgICAgICAgICAgICAgbGV0IG51bWJlck9mQ2hhbm5lbHMsIHNhbXBsZVJhdGU7XG5cbiAgICAgICAgICAgICAgICBjb25zdCByZWFkID0gKCkgPT5cbiAgICAgICAgICAgICAgICAgICAgcmVhZGVyLnJlYWQoKS50aGVuKCh7IHZhbHVlLCBkb25lIH0pID0+IHtcbiAgICAgICAgICAgICAgICAgICAgICAgIGlmIChoYXNDYW5jZWxlZF8pIHtcbiAgICAgICAgICAgICAgICAgICAgICAgICAgICByZWFkZXIuY2FuY2VsKCk7XG5cbiAgICAgICAgICAgICAgICAgICAgICAgICAgICByZXR1cm47XG4gICAgICAgICAgICAgICAgICAgICAgICB9XG4gICAgICAgICAgICAgICAgICAgICAgICBpZiAodmFsdWUgJiYgdmFsdWUuYnVmZmVyKSB7XG4gICAgICAgICAgICAgICAgICAgICAgICAgICAgbGV0IGJ1ZmZlciwgc2VnbWVudDtcblxuICAgICAgICAgICAgICAgICAgICAgICAgICAgIGlmIChyZXN0ICE9PSBudWxsKSB7XG4gICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIGJ1ZmZlciA9IGNvbmNhdChyZXN0LCB2YWx1ZS5idWZmZXIpO1xuICAgICAgICAgICAgICAgICAgICAgICAgICAgIH0gZWxzZSB7XG4gICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIGJ1ZmZlciA9IHZhbHVlLmJ1ZmZlcjtcbiAgICAgICAgICAgICAgICAgICAgICAgICAgICB9XG5cbiAgICAgICAgICAgICAgICAgICAgICAgICAgICAvLyBNYWtlIHN1cmUgdGhhdCB0aGUgZmlyc3QgYnVmZmVyIGlzIGxhZ2VyIHRoZW4gNDQgYnl0ZXMuXG4gICAgICAgICAgICAgICAgICAgICAgICAgICAgaWYgKGlzRmlyc3RCdWZmZXIgJiYgYnVmZmVyLmJ5dGVMZW5ndGggPD0gNDQpIHtcbiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgcmVzdCA9IGJ1ZmZlcjtcblxuICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICByZWFkKCk7XG5cbiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgcmV0dXJuO1xuICAgICAgICAgICAgICAgICAgICAgICAgICAgIH1cblxuICAgICAgICAgICAgICAgICAgICAgICAgICAgIC8vIElmIHRoZSBoZWFkZXIgaGFzIGFycml2ZWQgdHJ5IHRvIGRlcml2ZSB0aGUgbnVtYmVyT2ZDaGFubmVscyBhbmQgdGhlXG4gICAgICAgICAgICAgICAgICAgICAgICAgICAgLy8gc2FtcGxlUmF0ZSBvZiB0aGUgaW5jb21pbmcgZmlsZS5cbiAgICAgICAgICAgICAgICAgICAgICAgICAgICBpZiAoaXNGaXJzdEJ1ZmZlcikge1xuICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICBpc0ZpcnN0QnVmZmVyID0gZmFsc2U7XG5cbiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgY29uc3QgZGF0YVZpZXcgPSBuZXcgRGF0YVZpZXcoYnVmZmVyKTtcblxuICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICBudW1iZXJPZkNoYW5uZWxzID0gZGF0YVZpZXcuZ2V0VWludDE2KDIyLCB0cnVlKTtcbiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgc2FtcGxlUmF0ZSA9IGRhdGFWaWV3LmdldFVpbnQzMigyNCwgdHJ1ZSk7XG5cbiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgYnVmZmVyID0gYnVmZmVyLnNsaWNlKDQ0KTtcbiAgICAgICAgICAgICAgICAgICAgICAgICAgICB9XG5cbiAgICAgICAgICAgICAgICAgICAgICAgICAgICBpZiAoYnVmZmVyLmJ5dGVMZW5ndGggJSAyICE9PSAwKSB7XG4gICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIHJlc3QgPSBidWZmZXIuc2xpY2UoLTIsIC0xKTtcbiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgYnVmZmVyID0gYnVmZmVyLnNsaWNlKDAsIC0xKTtcbiAgICAgICAgICAgICAgICAgICAgICAgICAgICB9IGVsc2Uge1xuICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICByZXN0ID0gbnVsbDtcbiAgICAgICAgICAgICAgICAgICAgICAgICAgICB9XG5cbiAgICAgICAgICAgICAgICAgICAgICAgICAgICBzZWdtZW50ID0ge307XG5cbiAgICAgICAgICAgICAgICAgICAgICAgICAgICBhdWRpb1N0YWNrLnB1c2goc2VnbWVudCk7XG5cbiAgICAgICAgICAgICAgICAgICAgICAgICAgICBjb250ZXh0XG4gICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIC5kZWNvZGVBdWRpb0RhdGEod2F2aWZ5KGJ1ZmZlciwgbnVtYmVyT2ZDaGFubmVscywgc2FtcGxlUmF0ZSkpXG4gICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIC50aGVuKGF1ZGlvQnVmZmVyID0+IHtcbiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIHNlZ21lbnQuYnVmZmVyID0gYXVkaW9CdWZmZXI7XG5cbiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIGlmIChzY2hlZHVsZUJ1ZmZlcnNUaW1lb3V0SWQgPT09IG51bGwpIHtcbiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICBzY2hlZHVsZUJ1ZmZlcnMoKTtcbiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIH1cbiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgfSk7XG4gICAgICAgICAgICAgICAgICAgICAgICB9XG5cbiAgICAgICAgICAgICAgICAgICAgICAgIGlmIChkb25lKSB7XG4gICAgICAgICAgICAgICAgICAgICAgICAgICAgcmV0dXJuO1xuICAgICAgICAgICAgICAgICAgICAgICAgfVxuXG4gICAgICAgICAgICAgICAgICAgICAgICAvLyBjb250aW51ZSByZWFkaW5nXG4gICAgICAgICAgICAgICAgICAgICAgICByZWFkKCk7XG4gICAgICAgICAgICAgICAgICAgIH0pO1xuXG4gICAgICAgICAgICAgICAgLy8gc3RhcnQgcmVhZGluZ1xuICAgICAgICAgICAgICAgIHJlYWQoKTsgICAgICAgIFxuXG5cbiAgICAgICAgICAgICAgfSwgMzAwMCk7XG4gICAgICAgICAgICBcbiAgICAgICAgfSk7XG4gICAgfTtcblxuICAgIHJldHVybiB7XG4gICAgICAgIHBsYXk6IHVybCA9PiBwbGF5KHVybCksXG4gICAgICAgIHN0b3A6ICgpID0+IHtcbiAgICAgICAgICAgIGhhc0NhbmNlbGVkXyA9IHRydWU7XG4gICAgICAgICAgICBpZiAoY29udGV4dCkge1xuICAgICAgICAgICAgICAgIGNvbnRleHQuY2xvc2UoKTtcbiAgICAgICAgICAgIH1cbiAgICAgICAgfVxuICAgIH07XG59O1xuXG5leHBvcnQgZGVmYXVsdCBXYXZQbGF5ZXI7XG4iLCIvLyBDb25jYXQgdHdvIEFycmF5QnVmZmVyc1xuY29uc3QgY29uY2F0ID0gKGJ1ZmZlcjEsIGJ1ZmZlcjIpID0+IHtcbiAgY29uc3QgdG1wID0gbmV3IFVpbnQ4QXJyYXkoYnVmZmVyMS5ieXRlTGVuZ3RoICsgYnVmZmVyMi5ieXRlTGVuZ3RoKTtcblxuICB0bXAuc2V0KG5ldyBVaW50OEFycmF5KGJ1ZmZlcjEpLCAwKTtcbiAgdG1wLnNldChuZXcgVWludDhBcnJheShidWZmZXIyKSwgYnVmZmVyMS5ieXRlTGVuZ3RoKTtcblxuICByZXR1cm4gdG1wLmJ1ZmZlcjtcbn07XG5cbmV4cG9ydCBkZWZhdWx0IGNvbmNhdDtcbiIsImltcG9ydCBXYXZQbGF5ZXIgZnJvbSBcIi4vV2F2UGxheWVyXCI7XG5cbmV4cG9ydCBkZWZhdWx0IFdhdlBsYXllcjtcbm1vZHVsZS5leHBvcnRzID0gV2F2UGxheWVyO1xuIiwiaW1wb3J0IGNvbmNhdCBmcm9tIFwiLi9jb25jYXRcIjtcblxuLy8gV3JpdGUgYSBwcm9wZXIgV0FWRSBoZWFkZXIgZm9yIHRoZSBnaXZlbiBidWZmZXIuXG5jb25zdCB3YXZpZnkgPSAoZGF0YSwgbnVtYmVyT2ZDaGFubmVscywgc2FtcGxlUmF0ZSkgPT4ge1xuICAgIGNvbnN0IGhlYWRlciA9IG5ldyBBcnJheUJ1ZmZlcig0NCk7XG5cbiAgICB2YXIgZCA9IG5ldyBEYXRhVmlldyhoZWFkZXIpO1xuXG4gICAgZC5zZXRVaW50OCgwLCBcIlJcIi5jaGFyQ29kZUF0KDApKTtcbiAgICBkLnNldFVpbnQ4KDEsIFwiSVwiLmNoYXJDb2RlQXQoMCkpO1xuICAgIGQuc2V0VWludDgoMiwgXCJGXCIuY2hhckNvZGVBdCgwKSk7XG4gICAgZC5zZXRVaW50OCgzLCBcIkZcIi5jaGFyQ29kZUF0KDApKTtcblxuICAgIGQuc2V0VWludDMyKDQsIGRhdGEuYnl0ZUxlbmd0aCAvIDIgKyA0NCwgdHJ1ZSk7XG5cbiAgICBkLnNldFVpbnQ4KDgsIFwiV1wiLmNoYXJDb2RlQXQoMCkpO1xuICAgIGQuc2V0VWludDgoOSwgXCJBXCIuY2hhckNvZGVBdCgwKSk7XG4gICAgZC5zZXRVaW50OCgxMCwgXCJWXCIuY2hhckNvZGVBdCgwKSk7XG4gICAgZC5zZXRVaW50OCgxMSwgXCJFXCIuY2hhckNvZGVBdCgwKSk7XG4gICAgZC5zZXRVaW50OCgxMiwgXCJmXCIuY2hhckNvZGVBdCgwKSk7XG4gICAgZC5zZXRVaW50OCgxMywgXCJtXCIuY2hhckNvZGVBdCgwKSk7XG4gICAgZC5zZXRVaW50OCgxNCwgXCJ0XCIuY2hhckNvZGVBdCgwKSk7XG4gICAgZC5zZXRVaW50OCgxNSwgXCIgXCIuY2hhckNvZGVBdCgwKSk7XG5cbiAgICBkLnNldFVpbnQzMigxNiwgMTYsIHRydWUpO1xuICAgIGQuc2V0VWludDE2KDIwLCAxLCB0cnVlKTtcbiAgICBkLnNldFVpbnQxNigyMiwgbnVtYmVyT2ZDaGFubmVscywgdHJ1ZSk7XG4gICAgZC5zZXRVaW50MzIoMjQsIHNhbXBsZVJhdGUsIHRydWUpO1xuICAgIGQuc2V0VWludDMyKDI4LCBzYW1wbGVSYXRlICogMSAqIDIpO1xuICAgIGQuc2V0VWludDE2KDMyLCBudW1iZXJPZkNoYW5uZWxzICogMik7XG4gICAgZC5zZXRVaW50MTYoMzQsIDE2LCB0cnVlKTtcblxuICAgIGQuc2V0VWludDgoMzYsIFwiZFwiLmNoYXJDb2RlQXQoMCkpO1xuICAgIGQuc2V0VWludDgoMzcsIFwiYVwiLmNoYXJDb2RlQXQoMCkpO1xuICAgIGQuc2V0VWludDgoMzgsIFwidFwiLmNoYXJDb2RlQXQoMCkpO1xuICAgIGQuc2V0VWludDgoMzksIFwiYVwiLmNoYXJDb2RlQXQoMCkpO1xuICAgIGQuc2V0VWludDMyKDQwLCBkYXRhLmJ5dGVMZW5ndGgsIHRydWUpO1xuXG4gICAgcmV0dXJuIGNvbmNhdChoZWFkZXIsIGRhdGEpO1xufTtcblxuZXhwb3J0IGRlZmF1bHQgd2F2aWZ5O1xuIl19
