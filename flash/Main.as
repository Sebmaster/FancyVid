package {
	import fl.video.FLVPlayback;
	import fl.video.VideoEvent;
	import fl.video.VideoState;
	import fl.video.VideoError;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.external.ExternalInterface;
	
	public class Main extends Sprite {
		
		private var flvPlayback : FLVPlayback;
		
		public function Main() : void {
			if (stage)
				init();
			else
				addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e : Event=null) : void {
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			
			flvPlayback = new FLVPlayback();
			flvPlayback.width = stage.stageWidth;
			flvPlayback.height = stage.stageHeight;
			
			stage.addEventListener(Event.RESIZE, stageResize);
			stage.addChild(flvPlayback);
			
			flvPlayback.addEventListener(VideoEvent.STATE_CHANGE, failed);
			flvPlayback.addEventListener(VideoEvent.READY, ready);
			
			if (ExternalInterface.available) {
				ExternalInterface.marshallExceptions = true;
				ExternalInterface.addCallback("loadVideo", load);
				ExternalInterface.addCallback("playVideo", play);
				ExternalInterface.addCallback("pauseVideo", pause);
				
				callJS("load");
			}
		}
		
		private function callJS(eventName : String, args : Array = undefined) : void {
			ExternalInterface.call(root.loaderInfo.parameters.callback, root.loaderInfo.parameters.id, eventName, args);
		}
		
		private function stageResize(e : Event) : void {
			flvPlayback.width = stage.stageWidth;
			flvPlayback.height = stage.stageHeight;
		}
		
		private function failed(e : VideoEvent) : void {
			if (e.state == VideoState.CONNECTION_ERROR || e.state == VideoState.DISCONNECTED) {
				callJS('error');
			} else if (e.state == VideoState.PLAYING) {
				callJS('playing');
			}
		}
		
		private function ready(e : VideoEvent) : void {
			callJS('ready');
		}
		
		private function load(src : String) : void {
			flvPlayback.load(src);
		}
		
		private function play() : void {
			flvPlayback.play();
		}
		
		private function pause() : void {
			flvPlayback.pause();
		}
	}
}