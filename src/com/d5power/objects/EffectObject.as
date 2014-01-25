package com.d5power.objects
{
	import com.d5power.D5Camera;
	import com.d5power.D5Game;
	import com.d5power.map.WorldMap;
	import com.d5power.net.D5StepLoader;
	import com.d5power.utils.CharEffectImplement;
	import com.d5power.utils.NoEventSprite;
	
	import flash.display.Bitmap;
	import flash.display.BlendMode;
	import flash.geom.Point;
	import flash.utils.getTimer;
	
	public class EffectObject extends NoEventSprite implements IGO
	{
		private static const _pool:Array = new Array();
		private static const _passwd:String='D5PowerCharacterPlayer*)&*sl2^&&32q34';
		private static const PLAY_SPEED:uint = 120;
		
		// 特效相关
		private var _sonDeep:uint;
		private var _sonSpeed:Number;
		private var _sonAngle:Number;
		private var _sonFrame:int=-1;
		
		/**
		 * 是否产生过子对象
		 */ 
		private var _makeSon:Boolean;
		private var _rotation:Number=0;
		private var _rotationSpeed:Number=0;
		private var _moveAngle:Number=0;
		private var _moveSpeed:Number=0;
		private var _playSpeed:uint;
		private var _actionMode:uint;
		private var _runMode:uint;
		private var _moveDistnce:uint;
		private var _zoom:Number=1;
		private var _mirror:uint;
		private var _blend:uint;
		private var _lowLv:uint;
		
		private var _data:Object;
		private var _bmd:Bitmap;
		private var _reslist:Array;
		private var _totalframe:uint = 0;
		private var _time:uint;
		private var _frametime:uint;
		private var _playFrame:uint;
		private var _deleteing:Boolean;
		private var _inScreen:Boolean;
		private var _pos:Point;
		
		override public function toString():String
		{
			return "name:"+this.name+
				" makeSon:"+_makeSon+
				" playFrame:"+_playFrame+
				" deleteing:"+_deleteing+
				" inScreen:"+_inScreen+
				" pos:"+_pos;
		}
		
		public static function clearPool():void
		{
			if(_pool==null) return;
			while(_pool.length)
			{
				(_pool.shift() as EffectObject);
			}
			trace("资源池数量"+_pool.length);
		}
		
		public static function getInstance():EffectObject
		{
			if(_pool.length>0)
				return _pool.shift();
			else
				return new EffectObject(_passwd);
		}
		
		private static function back2Pool(obj:EffectObject):void
		{
			trace("资源池数量："+_pool.length);
			if(_pool.indexOf(obj)==-1) _pool.push(obj);
		}
		
		public function EffectObject(passwd:String)
		{
			if(_passwd!=passwd)
			{
				error();
			}
			_bmd = new Bitmap();
			_pos = new Point();
		}
		
		public function set deleteing(v:Boolean):void
		{
			_deleteing = v;
		}
		
		public function get zOrder():int
		{
			return 0;
		}
		
		public function get _POS():Point
		{
			return _pos;
		}
		
		public function get deleteing():Boolean
		{
			return _deleteing;
		}
		
		public function get inScreen():Boolean
		{
			return _inScreen;
		}
		
		public function set inScreen(v:Boolean):void
		{
			_inScreen = v;
			_inScreen ? D5Game.me.scene.$insertEffect(this,_lowLv==1) : D5Game.me.scene.$removeObject(this);
		}
		
		public function get moveSpeed():Number
		{
			return _moveSpeed;
		}
		
		public function get moveDistance():uint
		{
			return _moveDistnce;
		}
		
		public function setPos(px:Number,py:Number):void
		{
			_pos.x = px;
			_pos.y = py;
			runPos();
			if(D5Camera.cameraView.contains(px,py)) inScreen=true;
		}
		
		public function runPos():void
		{
			var target:Point = WorldMap.me.getScreenPostion(_pos.x,_pos.y);
			x = Number(target.x.toFixed(1));
			y = Number(target.y.toFixed(1));
		}
		
		public function setup(data:Object):void
		{
			_data = data;
			_reslist = data.list;
			_time = getTimer();
			_totalframe = data.totalFrame;
			_bmd.bitmapData = _reslist[0];
			_bmd.x = -(_bmd.width>>1);
			_bmd.y = -(_bmd.height>>1);
			addChild(_bmd);
			updateBitmapRending()
		}
		
		private function updateBitmapRending():void
		{
			_bmd.rotation = _rotation;
			
			var mirrorx:int=1;
			var mirrory:int=1;
			
			if(_mirror==1)
			{
				mirrory = 1;
				mirrorx = -1;
			}else if(_mirror==2){
				mirrory = -1;
				mirrorx = 1;
			}
			
			_bmd.scaleX = _zoom*mirrorx;
			_bmd.scaleY = _zoom*mirrory;
			
			blendMode = _blend==0 ? BlendMode.NORMAL : BlendMode.ADD;
		}
		
		public function updateSonCopy(deep:uint,angle:Number):void
		{
			_moveAngle+=angle*deep;
			_sonAngle+=angle*deep;
		}
		
		public function updateSetting(v:CharEffectImplement,dir:uint,zeroX:int,zeroY:int):void
		{
			_sonFrame = v.sonFrame;
			if(_sonFrame==-1) _sonFrame = 0;
			_sonDeep = v.sonFrameDeep;
			_sonSpeed = v.sonSpeed;
			_sonAngle = Global.PI_180*v.getSonAngle(dir);
			_rotation = v.getRotation(dir);
			
			_rotationSpeed = v.rotationSpeed;
			_moveAngle = Global.PI_180*v.getMoveAngle(dir);
			_moveSpeed = v.moveSpeed;
			_playSpeed = v.playSpeed==0 ? PLAY_SPEED : v.playSpeed;
			_actionMode = v.actionMode;
			_runMode = v.runMode;
			_zoom = v.zoom;
			if(_zoom==0) _zoom = 1;
			_moveDistnce = v.moveDistance;
			_blend = v.blendSwitch;
			_lowLv = v.lowLv;

			var pos:Array = v.getDirectionPos(dir);
			if(pos!=null)
			{
				zeroX += int(pos[0]);
				zeroY += int(pos[1]);
			}
			
			setPos(zeroX,zeroY);
			D5StepLoader.me.addLoad(v.res,setup,true,D5StepLoader.TYPE_SWF);
		}
		
		public function dispose():void
		{
			_sonDeep = 0;
			_sonSpeed = 0;
			_sonAngle = 0;
			_sonFrame = -1;
			_makeSon = false;
			_rotation = 0;
			_rotationSpeed = 0;
			_moveAngle = 0;
			_moveSpeed = 0;
			_playSpeed = PLAY_SPEED;
			_actionMode = 0;
			_runMode = 0;
			_zoom = 1;
			_mirror = 0;
			_moveDistnce = 0;
			_blend = 0;
			_lowLv = 0;
			_totalframe = 0;
			_deleteing = false;
			
			_bmd.rotation = 0;
			_bmd.scaleX = _bmd.scaleY = 1;
			_bmd.bitmapData.dispose();
			_bmd.bitmapData=null;
			
			if(parent) parent.removeChild(this);
			
			back2Pool(this);
			blendMode = BlendMode.NORMAL;
		}
		
		private function error():void
		{
			throw new Error("[EffectObject] 无法通过构造函数构建，请通过getInstance方法从对象池中获取");
		}
		
		private function updateRendingStatus():void
		{
			_bmd.rotation = _rotation;
			
			var mirrorx:int=1;
			var mirrory:int=1;
			
			if(_mirror==1)
			{
				mirrory = 1;
				mirrorx = -1;
			}else if(_mirror==2){
				mirrory = -1;
				mirrorx = 1;
			}
			
			_bmd.scaleX = _zoom*mirrorx;
			_bmd.scaleY = _zoom*mirrory;
			
			blendMode = _blend==0 ? BlendMode.NORMAL : BlendMode.ADD;
		}
		
		/**
		 * @param	allPro	是否克隆全部属性
		 */ 
		public function clone(allPro:Boolean=false):EffectObject
		{
			var p:EffectObject = getInstance();
			p.setPos(_pos.x,_pos.y);
			
			if(allPro)
			{
				p._sonFrame = _sonFrame;
				p._sonDeep = _sonDeep;
				p._sonAngle = _sonAngle;
				p._sonSpeed = _sonSpeed;
				p._rotation = _rotation;
				p._rotationSpeed = _rotationSpeed;
				p._moveAngle = _moveAngle;
				p._moveSpeed = _moveSpeed;
				p._playSpeed = _playSpeed;
				p._actionMode = _actionMode;
				p._runMode = _runMode;
				p._zoom = _zoom;
				p._mirror = _mirror;
				p._moveDistnce = _moveDistnce;
				p._blend = _blend;
				p._lowLv = _lowLv;
				p._makeSon = false;
			}
			
			p.setup(_data);
			return p;
		}
		
		
		
		public function renderMe():void
		{
			if(!stage)
			{
				deleteing = true;
			}
			if(!_reslist || _deleteing) return;
			var cost_time:Number = (getTimer() - _time) / _playSpeed;
			if (_frametime != cost_time)
			{
				_frametime = cost_time;
				_playFrame = int(cost_time % _totalframe);
				_bmd.bitmapData = _reslist[_playFrame];
				
				if(_rotationSpeed!=0)
				{
					rotation+=_rotationSpeed;
				}
				
				if(_moveSpeed!=0)
				{
					_bmd.x+=Math.cos(_moveAngle)*_moveSpeed;
					_bmd.y+=Math.sin(_moveAngle)*_moveSpeed;
					if(_bmd.x>stage.stageWidth || _bmd.y>stage.stageHeight)
					{
						dispose();
					}
				}
				
				if(_playFrame==_sonFrame && !_makeSon && _sonDeep>0)
				{
					_makeSon = true;
					var obj:EffectObject = clone(true);
					obj._sonDeep = --_sonDeep;
					obj.setPos(_pos.x+_sonSpeed*Math.cos(_sonAngle),_pos.y+_sonSpeed*Math.sin(_sonAngle));
					D5Game.me.scene.addObject(obj);
				}
				
				if(_playFrame==_totalframe-1  && _totalframe>1)
				{
					deleteing=true;
				}
			}
		}
	}
}