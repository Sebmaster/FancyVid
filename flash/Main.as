package {
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.NetStatusEvent;
	import flash.events.SecurityErrorEvent;
	import flash.external.ExternalInterface;
	import flash.media.Video;
	import flash.net.LocalConnection;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	import flash.system.Security;
	
	public class Main extends Sprite {
		
		private var stream : NetStream;
		private var vid : Video = new Video();
		
		public function Main() : void {
			if (stage)
				init();
			else
				addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e : Event=null) : void {
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			Security.allowDomain("*");
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			
			vid.width = stage.stageWidth;
			vid.height = stage.stageHeight;
			vid.smoothing = true;
			
			stage.addEventListener(Event.RESIZE, stageResize);
			stage.addChild(vid);
			
			if (ExternalInterface.available) {
				ExternalInterface.marshallExceptions = true;
				ExternalInterface.addCallback("playVideo", play);
				ExternalInterface.addCallback("pauseVideo", pause);
				
				callJS("load");
			}
		}
		
		private function callJS(eventName : String, args : Array=undefined) : void {
			ExternalInterface.call(root.loaderInfo.parameters.callback, root.loaderInfo.parameters.id, eventName, args);
		}
		
		private function stageResize(e : Event) : void {
			vid.width = stage.stageWidth;
			vid.height = stage.stageHeight;
		}
		
		private function play(url : String) : void {
			var conn : NetConnection = new NetConnection();
			conn.connect(null);
			
			stream = new NetStream(conn);
			
			stream.addEventListener(NetStatusEvent.NET_STATUS, function(evt : NetStatusEvent) : void {
				if (evt.info.level == 'error') {
					callJS('error');
				}
			});
			
			vid.attachNetStream(stream);
			
			stream.play(url);
			callJS('playing');
		}
		
		private function pause() : void {
			stream.pause();
		}
	}
}