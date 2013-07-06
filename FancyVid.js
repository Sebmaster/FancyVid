(function () {
	"use strict";

	var instanceCounter = 0;

	function generateVariableName() {
		return 'FancyVid_Global_' + (instanceCounter++);
	}

	function extend(destination, source) {
		for (var property in source) {
			if (typeof destination[property] === 'undefined') {
				destination[property] = source[property];
			}
		}

		return destination;
	}

	function FancyVid(elem, options) {
		if (!options) options = {};

		this.element = elem;
		this.videoTag = null;
		this.options = extend(options, {
			swfPath: 'flash/FancyVid.swf'
		});

		this._handlers = { load: [], error: [] };

		this._init();
	}

	FancyVid.prototype._init = function () {
		var onLoad = generateVariableName();
		window[onLoad] = function () {
			delete window[onLoad];

			this.videoTag = flash;
			this._loaded();
		}.bind(this);

		var onError = generateVariableName();
		window[onError] = function (msg) {
			this._emit('error', msg);
		}.bind(this);

		var flash = document.createElement('embed');
		flash.id = flash.name = generateVariableName();
		flash.type = 'application/x-shockwave-flash';
		flash.allowScriptAccess = 'always';
		flash.src = this.options.swfPath + '?onload=' + onLoad + "onerror=" + onError;
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