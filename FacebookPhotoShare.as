package sharing
{
	import com.facebook.graph.FacebookMobile;
	
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.TouchEvent;
	import flash.geom.Rectangle;
	import flash.media.SoundMixer;
	import flash.media.SoundTransform;
	import flash.media.StageWebView;
	import flash.system.System;
	import flash.text.TextField;
	import flash.utils.ByteArray;
	
	import events.GameEvent;
	
	import tools.Tools;
	
	public class FacebookPhotoShare extends Sprite
	{
		private var webView:StageWebView;
		private var countErr:int = 0;
		private var message:TextField;
		private var bitmap:Bitmap;
		private var messageFB:String;
		
		[Event(name="facebookOver", type="events.GameEvent")]
		[Event(name="facebookCancel", type="events.GameEvent")]
		public function FacebookPhotoShare(bitmap:Bitmap, message:String)
		{
			this.bitmap = bitmap;
			this.messageFB = message;
			addEventListener(Event.ADDED_TO_STAGE, onAdded);
		}
		
		private function onAdded(e:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, onAdded);
			addEventListener(Event.REMOVED_FROM_STAGE, onRemove);
			
			SoundMixer.soundTransform = new SoundTransform(0.15);
			
			var spr:Sprite = new Sprite();
			spr.graphics.beginFill(0xFFFFFF);
			spr.graphics.drawRect(0, 0, stage.stageWidth, stage.stageHeight);
			spr.graphics.endFill();
			addChild(spr);
			
			message = Tools.generateTextFieldEmbed(18, "loading...", 0x000000);
			addChild(message);
			message.x = (stage.stageWidth - message.width)/2;
			message.y = (stage.stageHeight - message.height)/2;
			
/*			closeWebView = new MenuButton("", "back");
			addChild(closeWebView);
			closeWebView.x = 10;
			closeWebView.y = 10;
			closeWebView.addEventListener(TouchEvent.TOUCH_TAP, onCloseWebView);
*/			
			onOLFacebook();
		}
		
		
		/**
		 * Функция закрытия экрана FB
		 */
		public function onCloseWebView(e:TouchEvent):void
		{
			if(webView)
				webView.dispose();
			dispatchEvent(new GameEvent("facebookCancel"));
		}
		
		/**
		 * Функция запуска авторизации пользователя в FB
		 */
		public function onOLFacebook():void
		{
			//if(Prefs.prefsXML.players.player.(@last == "true")[0].@facebook == "false")
			FacebookMobile.init("App ID/API Key", onLoginFacebook, "App secret key");
		}
		
		private function successFeedSecond(success:Object, failed:Object):void
		{			
			if(success)
			{
				trace("4");
				//Prefs.prefsXML.players.player.(@last == "true")[0].@facebook = "true";
				FacebookMobile.logout(dispatchLogout);	
			}
			else
			{
				FacebookMobile.logout();	
				dispatchEvent(new GameEvent("facebookCancel"));
			}
		}
		
		private function dispatchLogout(success:Object):void
		{
			dispatchEvent(new GameEvent("facebookOver"));
		}
		
		private function onLoginFacebook(success:Object, failed:Object):void
		{
			if(failed && failed.type != "ioError")
			{
				if(countErr < 1)
					connect();
			}
			else if(success)
			{
				var byteArray:ByteArray = new ByteArray();
				bitmap.bitmapData.encode(new Rectangle(0,0,stage.stageWidth,stage.stageHeight), new flash.display.JPEGEncoderOptions(), byteArray); 
				var params:Object = new Object();
				params.message = messageFB;
				params.image = byteArray;
				params.fileName = "image.jpg";
				FacebookMobile.api("me/photos", successFeedSecond, params, "post");
				trace("1");
			}
			else
			{
				message.text = "check Internet connection...";
				message.width = message.textWidth;
				message.x = (stage.stageWidth - message.width)/2;
				onCloseWebView(null);
			}
		}
		
		private function onLoginSuccessFacebook(success:Object, failed:Object):void
		{
			if(success)
			{
				var byteArray:ByteArray = new ByteArray();
				bitmap.bitmapData.encode(new Rectangle(0,0,stage.stageWidth,stage.stageHeight), new flash.display.JPEGEncoderOptions(), byteArray); 
				var params:Object = new Object();
				params.message = messageFB;
				params.image = byteArray;
				params.fileName = "image.jpg";
				FacebookMobile.api("me/photos", successFeedSecond, params, "post");
				trace("1");
			}
			else
			{
				trace("2");
				FacebookMobile.logout();	
				dispatchEvent(new GameEvent("facebookCancel"));
			}
		}
		
		
		private function connect():void
		{
			countErr++;
			webView = new StageWebView();
			webView.stage = this.stage;
			webView.viewPort = new Rectangle(0, 0, stage.stageWidth, stage.stageHeight);
			var permission:Array = ['publish_stream'];
			FacebookMobile.login(onLoginSuccessFacebook, stage, permission, webView);
		}
		
		private function onRemove(e:Event):void
		{
			SoundMixer.soundTransform = new SoundTransform(1);
			removeEventListener(Event.REMOVED_FROM_STAGE, onRemove);
			removeChildren();
			System.pauseForGCIfCollectionImminent(0.0);
		}
	}
}