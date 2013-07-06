(function () {
	"use strict";

	var callbacks = [];

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

		this.instanceId = callbacks.length;
		callbacks[callbacks.length] = {};

		this.element = elem;
		this.videoTag = null;
		this.options = extend(options, {
			swfPath: 'flash/FancyVid.swf'
		});

		this._handlers = { load: [], error: [] };
	}

	FancyVid._flashCallback = function (id, event, args) {
		if (callbacks[id][event]) {
			callbacks[id][event].apply(null, args);
		}
	};

	FancyVid.prototype._initFlash = function (loadCb, errorCb) {
		var that = this;

		var flash = document.createElement('embed');
		flash.id = flash.name = 'FancyVid_' + this.instanceId;
		flash.type = 'application/x-shockwave-flash';
		flash.src = this.options.swfPath;
		flash.className = 'fancyVid-player';

		attr = document.createAttribute('allowScriptAccess');
		attr.nodeValue = 'always';
		flash.setAttributeNode(attr);

		callbacks[this.instanceId].load = loadCb.bind(this, flash);
		callbacks[this.instanceId].error = function () {
			that.element.removeChild(flash);

			errorCb.bind(that)();
		};

		var attr = document.createAttribute('flashVars');
		attr.nodeValue = 'callback=FancyVid._flashCallback&id=' + this.instanceId;
		flash.setAttributeNode(attr);

		this.element.appendChild(flash);
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

	FancyVid.prototype.play = function (src, type) {
		if (!(src instanceof Array)) {
			src = [src];
		}

		var thisSource = src.shift();
		var nowSrc = thisSource.src ? thisSource.src : thisSource;
		var nowType = thisSource.type ? thisSource.type : type;

		if (nowType === 'video/x-flv' || nowType === 'video/flash') {
			var link = document.createElement('a');
			link.href = nowSrc;

			this._initFlash(function (elem) {
				elem.loadVideo(link.href);
				callbacks[this.instanceId].ready = elem.playVideo.bind(elem);
			}, function (data) {
				if (src.length) {
					this.play(src, type);
				} else {
					this._emit('error', data);
				}
			});
		} else {

		}
	};

	self.FancyVid = FancyVid;
})();