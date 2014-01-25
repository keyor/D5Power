package com.d5power.graphics
{
	import com.d5power.D5Game;
	import com.d5power.controller.Actions;
	import com.d5power.net.D5StepLoader;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.GradientType;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.utils.ByteArray;
	import flash.utils.getTimer;
	
	public class Swf2p5 implements ISwfDisplayer
	{
		private var _lib:Array;
		private var _list:Vector.<BitmapData>;
		private var _xml:XML;
		private var _time:int = 0;
		private var _bmd:Bitmap;
		private var _frame:int = 0;
		private var _shadow:Shape;
		private var _direction:uint;
		private var _playFrame:uint;
		private var _loop:Boolean=true;
		private var _totalFrame:uint;
		private var _openShadow:Boolean;
		
		private var _swfPath:String;
		
		/**
		 * 阴影缩放系数，请根据实际项目情况修改
		 */ 
		protected var _shadowScale:Number = 0.05;
		
		private var _onResReady:Function;
		
		public function Swf2p5(openShadow:Boolean=false)
		{
			_bmd = new Bitmap();
			_shadow = new Shape();
			_openShadow = openShadow;
			super();
		}
		
		public function set onReady(f:Function):void
		{
			_onResReady = f;
		}
		
		public function get swfDir():String
		{
			var index:int = _swfPath.lastIndexOf('/');
			return index==-1 ? '' : _swfPath.substr(0,index);
		}
		
		public function get maxFrame():uint
		{
			return _list.length;
		}
		
		public function get nowFrame():uint
		{
			return _playFrame;
		}
		
		public function get swfPath():String
		{
			return _swfPath;
		}
		
		public function dispose():void
		{
			_onResReady = null;
			_bmd.bitmapData=null;
			_list = null;
			_xml = null;
		}
		
		public function get monitor():Bitmap
		{
			return _bmd;
		}
		
		public function get shadow():Shape
		{
			return _shadow;
		}
		
		public function set direction(v:int):void
		{
			if(v<0) v = 4-v; // 在SWF2P5素材中，镜像数据是保存在数组末尾的。因此通过4-V刚好获得各方向的反向数据。相关处理请参考SWFBitmap2P5D.as
			
			if(_lib==null)
			{
				_direction = v;
				return;
			}
			if(_direction==v) return;
			
			
			_direction = v;
			_list = _lib[_direction];
		}
		
		public function get renderDirection():int
		{
			return _direction;
		}
		
		public function set loop(b:Boolean):void
		{
			_loop = b;
		}
		
		public function set action(v:int):void
		{
			
		}
		
		public function get playFrame():uint
		{
			return _playFrame;
		}
		
		public function get totalFrame():uint
		{
			return _totalFrame;
		}
		
		public function changeSWF(file:String,inPool:Boolean=true):void
		{
			_swfPath = file;
			if(_bmd)
			{
				_bmd.bitmapData = null;
				
				_lib = null;
				_list = null;
				_xml = null;
			}
			
			if(_shadow)
			{
				_shadow.graphics.clear();
			}
			
			_frame = 0;
			D5StepLoader.me.addLoad(D5Game.me.projPath+file,setSWF,inPool,D5StepLoader.TYPE_SWF);
		}
		
		public function setSWF(data:Object):void
		{
			_lib = data.list;
			_list = _lib[_direction];
			_xml = data.xml;
			_totalFrame = int(_xml.@Frame)-1;
			
			initPlay();
			
			if(_onResReady!=null)
			{
				_onResReady();
				_onResReady = null;
			}
		}
		
		public function render():void
		{
			if(_xml==null || (!_loop && _playFrame==int(_xml.@Frame)-1)) return;

			var cost_time:Number = (getTimer() - _time) / int(_xml.@Time);
			
			if (_frame != cost_time)
			{
				_playFrame = int(cost_time % _list.length);
				_frame = cost_time;
				_bmd.bitmapData = _list[_playFrame];
			}
		}
		
		/**
		 * 初始化播放器
		 */ 
		private function initPlay():void
		{
			if (_list==null || _list.length == 0) return;
			
			var px:int;
			var py:int;
			
			_time = getTimer();
			
			if(_bmd==null) _bmd = new Bitmap(null, "auto", true);

			
			_bmd.bitmapData = _list[0];
			_bmd.x = int(_xml.@X) + px;
			_bmd.y = int(_xml.@Y) + py;
			
			
			if(_openShadow)
			{
				if(_shadow==null) _shadow = new Shape();
				var matr:Matrix = new Matrix();
				matr.createGradientBox(50, 30,0,-25,-15);
				_shadow.graphics.beginGradientFill(GradientType.RADIAL,[0,0],[1,0],[0,255],matr);
				_shadow.graphics.drawEllipse(-25, -15, 50, 30);
				_shadow.x = px;
				_shadow.y = py;
				_shadow.scaleX = Number(_xml.@shadowX) * _shadowScale;
				_shadow.scaleY = Number(_xml.@shadowY) * _shadowScale;
			}
		}
		
	}
}