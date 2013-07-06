(function () {
	"use strict";

	var instanceCounter = 0;

	function extend(destination, source) {
		for (var property in source) {
			if (typeof destination[property] === 'undefined') {
				destination[property] = source[property];
			}
		}

		return destination;
	};

	function FancyVid(elem, options) {
		if (!options) options = {};

		this.element = elem;
		this.videoTag = null;
		this.options = extend(options, {
			swfPath: 'flash/FancyVid.swf'
		});

		this._handlers = { load: [] };

		this._init();
	}

	FancyVid.prototype._init = function () {
		var code = 'FancyVid_Instance_' + (instanceCounter++);
		window[code] = function () {
			delete window[code];

			this.videoTag = flash;
			this._loaded();
		}.bind(this);

		var flash = document.createElement('embed');
		flash.id = code;
		flash.name = code;
		flash.type = 'application/x-shockwave-flash';
		flash.allowScriptAccess = 'always';
		flash.src = this.options.swfPath + '?onload=' + code;
		flash.className = 'fancyVid-player';

		this.element.appendChild(flash);
	};

	FancyVid.prototype._loaded = function () {
		this.isLoaded = true;
		this._emit('load');
	};

	FancyVid.prototype.on = function (evt, cb) {
		if (this._handlers[evt]) {
			this._handlers[evt][this._handlers[evt].length] = cb;

			if (evt === 'load' && this.isLoaded) {
				cb();
			}
		} else {
			throw new Error('Unknown event type');
		}
	};

	FancyVid.prototype._emit = function (evt) {
		for (var i = 0; i < this._handlers[evt].length; ++i) {
			this._handlers[evt][i]();
		}
	};

	FancyVid.prototype.play = function (src) {
		if (this.videoTag.tagName === 'EMBED') { // flash
			var link = document.createElement('a');
			link.href = src;
			this.videoTag.playVideo(link.href);
		} else { // video

		}
	};

	self.FancyVid = FancyVid;
})();