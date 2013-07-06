package  
{
	import fl.video.FLVPlayback;
	import fl.video.VideoEvent;
	import fl.video.VideoState;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.external.ExternalInterface;
	
	public class Main extends Sprite {
		
		private var flvPlayback : FLVPlayback;
		
		private var errorCallbacks : Array;
		
		public function Main() : void {
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void {
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			
			flvPlayback = new FLVPlayback();
			flvPlayback.width = stage.stageWidth;
			flvPlayback.height = stage.stageHeight;
			
			stage.addEventListener(Event.RESIZE, stageResize);
			stage.addChild(flvPlayback);
			
			flvPlayback.addEventListener(VideoEvent.STATE_CHANGE, failed);
			
			if (ExternalInterface.available) {
				ExternalInterface.marshallExceptions = true;
				ExternalInterface.addCallback("playVideo", play);
				ExternalInterface.addCallback("pauseVideo", pause);
				ExternalInterface.addCallback("onError", addErrorCallback);
				
				ExternalInterface.call(root.loaderInfo.parameters.onload);
			}
		}
		
		private function stageResize(e : Event) : void {
			flvPlayback.width = stage.stageWidth;
			flvPlayback.height = stage.stageHeight;
		}
		
		private function addErrorCallback(fn : Function) : void {
			errorCallbacks.push(fn);
		}
		
		private function failed(e : VideoEvent) : void {
			if (e.state == VideoState.CONNECTION_ERROR || e.state == VideoState.DISCONNECTED) {
				ExternalInterface.call(root.loaderInfo.parameters.onerror);
				for (var i : int = 0; i < errorCallbacks.length; ++i) {
					errorCallbacks[i]();
				}
			}
		}
		
		private function play(src : String) : void {
			flvPlayback.play(src);
		}
		
		private function pause() : void {
			flvPlayback.pause();
		}
	}
}