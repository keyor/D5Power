package com.d5power
{
	import com.d5power.core.BaseScene;
	import com.d5power.events.ChangeMapEvent;
	import com.d5power.events.D5IOErrorEvent;
	import com.d5power.map.WorldMap;
	import com.d5power.net.MutiLoader;
	import com.d5power.ns.NSCamera;
	import com.d5power.ns.NSD5Power;
	import com.d5power.objects.BuildingObject;
	import com.d5power.objects.EffectObject;
	import com.d5power.objects.GameObject;
	import com.d5power.objects.NCharacterObject;
	import com.d5power.objects.RoadPoint;
	
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.display3D.Context3D;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.system.ApplicationDomain;
	import flash.utils.ByteArray;
	import flash.utils.Timer;
	
	use namespace NSCamera;
	use namespace NSD5Power;
	
	public class D5Game extends Sprite
	{		
		private var loader:URLLoader;
		
		/**
		 * 缩放模式
		 * @see ZOOM_NO
		 * @see ZOOM_X
		 * @see ZOOM_Y
		 * @see ZOOM_FULL
		 */ 
		public static var ZOOM_MODE:uint = 0;
		
		/**
		 * 缩放模式 - 不缩放，原比例居中
		 */ 
		public static const ZOOM_NO:uint = 0;
		
		/**
		 * 缩放模式 - 按X比例缩放，缩放后居中
		 */
		public static const ZOOM_X:uint = 1;
		
		/**
		 * 缩放模式 - 按Y比例缩放,缩放后居中
		 */
		public static const ZOOM_Y:uint = 2;
		
		/**
		 * 全屏拉伸
		 */ 
		public static const ZOOM_FULL:uint = 3;
		
		/**
		 * 智能缩放，自动选择一个比较合适的比例进行等比缩放，可能有部分内容超出边界
		 */ 
		public static const ZOOM_EQU:uint = 4;
		
		/**
		 * 内容遮罩
		 */ 
		private var _masker:Shape;
		
		/**
		 * Stage3D对象
		 */ 
		private var _gpuContext0:Context3D;
		
		/**
		 * 是否开启硬件加速
		 */ 
		private var _gpuMode:Boolean;
		/**
		 * 是否尝试使用GPU加速
		 */ 
		private var _gpuTry:Boolean;
		
		/**
		 * 切换地图时的识别码
		 */ 
		protected var _id:uint;
		
		/**
		 * 主游戏场景
		 */ 
		protected var _scene:BaseScene;
		
		protected var _camera:D5Camera;
		
		protected var _config:String;
		
		protected var _stg:Stage;
		
		protected var _loadData:Array=[];
		
		protected var _mtLoader:MutiLoader;
		
		protected var _data:XML;
		
		/**
		 * 角色出现的起始位置X
		 */ 
		protected var _startX:uint=500;
		
		/**
		 * 角色出现的起始位置Y
		 */ 
		protected var _startY:uint=500;
		
		/**
		 * 游戏默认起始地图
		 * 如果为0，则读取项目配置文件中设置的起始地图
		 */ 
		protected var _startMap:uint = 0;
		
		protected var _nextStep:Function;
		
		protected var _readyBack:Function;
		
		private static var _me:D5Game;
		
		/**
		 * 项目路径，仅供编辑器使用
		 */  
		protected static var _projPath:String='';
		
		public static function get me():D5Game
		{
			return _me;
		}
		
		/**
		 * @param	mapid	地图ID
		 * @param	config	配置文件地址。地图ID与文件地址提供1个即可。
		 * @param	openGPU	是否开启GPU加速
		 * @param	onReady 当地图准备完成后的反馈函数
		 */ 
		public function D5Game(mapid:uint=0,config:String='',openGPU:uint=0,onReady:Function=null)
		{
			if(_me) error();
			
			_me = this;
			_readyBack = onReady;
			
			setconfig(mapid,config);
			
			super();
			
			_startMap = mapid;
			_gpuTry = openGPU!=0;
			
			addEventListener(Event.ADDED_TO_STAGE,install);
			
		}
		
		public function get startX():uint
		{
			return _startX;
		}
		
		public function get startY():uint
		{
			return _startY;
		}
		
		
		public function set onReady(fun:Function):void
		{
			_readyBack = fun;
		}
		
		/**
		 * @param	mapid		要切换到的地图ID
		 * @param	px			初始角色坐标X
		 * @param	py			初始角色坐标Y
		 * @param	autoSetup	是否自安装，如果设置为true，则需要覆写D5Game的setupMySelf方法进行自行配置。如果设置为false，则进行引擎标准的地图加载过程
		 * @param	sameMap		同地图不切换开关，设置为true，如果为相同地图，则不进行切换
		 */ 
		public function changeMap(mapid:uint,px:uint,py:uint,autoSetup:Boolean=false,sameMap:Boolean=true):void
		{
			var event:ChangeMapEvent = new ChangeMapEvent(mapid,px,py,autoSetup,sameMap);
			setconfig(mapid);
			onChangeMap(event);
		}
		
		public function get projPath():String
		{
			return _projPath;
		}
		
		public function get gpuMode():Boolean
		{
			return _gpuMode;
		}
		
		/**
		 * 更新配置地址
		 */ 
		protected function setconfig(mapid:uint,config:String=''):void
		{
			_config = config=='' ? _projPath+'asset/tiles/'+mapid+'/mapconf.d5' : config;
		}
		
		protected function install(e:Event):void
		{
			_stg = stage;
			
			setGlobalSize();
			
			_stg.align = StageAlign.TOP_LEFT;
			_stg.scaleMode = StageScaleMode.NO_SCALE;
			
			removeEventListener(Event.ADDED_TO_STAGE,install);
			
			if(_gpuTry)
			{
				// 尝试请求Stage3D
				stage.stage3Ds[0].addEventListener(Event.CONTEXT3D_CREATE, onCreateStage3D);
				stage.stage3Ds[0].requestContext3D();
			}else{
				installStart();
			}
			
		}
		
		protected function setGlobalSize(w:uint=0,h:uint=0):void
		{
			if(w==0) w=Global.MAPSIZE.x;
			if(h==0) h=Global.MAPSIZE.y;
			
			Global.W = w<_stg.stageWidth ? w : _stg.stageWidth;
			Global.H = h<_stg.stageHeight ? h : _stg.stageHeight;
			
			if(_masker==null)
			{
				_masker = new Shape();
				addChild(_masker);
				
			}else{
				_masker.graphics.clear();
			}
			
			_masker.graphics.beginFill(0xff0000);
			_masker.graphics.drawRect(0,0,Global.W,Global.H);
			_masker.graphics.endFill();
			mask = _masker;
			
			if(camera)camera.update();
			
			switch(ZOOM_MODE)
			{
				case ZOOM_NO:
					x = int((_stg.stageWidth-Global.W)>>1);
					y = int((_stg.stageHeight-Global.H)>>1);
					break;
				case ZOOM_X:
					scaleX = scaleY = _stg.stageWidth/Global.W;
					y = int((_stg.stageHeight-Global.H*scaleX)>>1);
					break;
				case ZOOM_Y:
					scaleX = scaleY = _stg.stageHeight/Global.H;
					x = int((_stg.stageWidth-Global.W*scaleX)>>1);
					break;
				case ZOOM_FULL:
					scaleX = _stg.stageWidth/Global.W;
					scaleY = _stg.stageHeight/Global.H;
					x = int((_stg.stageWidth-Global.W*scaleX)>>1);
					y = int((_stg.stageHeight-Global.H*scaleY)>>1);
					break;
			}
		}
		
		/**
		 * 传送至特定地图
		 */ 
		public function changeScene(mapid:uint,tox:uint = 500,toy:uint=500):void
		{
			stop();
			_scene.changeScene(mapid,tox,toy);
		}
		
		
		public function get camera():D5Camera
		{
			return _camera;
		}
		
		public function get scene():BaseScene
		{
			return _scene;
		}
		
		public function clear():void
		{
			stop();
			EffectObject.clearPool();
			var timer:Timer = new Timer(500);
			timer.addEventListener(TimerEvent.TIMER,autoUnsetup);
			timer.start();
		}
		
		protected function installStart():void
		{
			var onD5GameConfig:Function = function(e:Event):void
			{
				loader.removeEventListener(Event.COMPLETE,onD5GameConfig);
				loader.removeEventListener(IOErrorEvent.IO_ERROR,onD5GameError);
				
				var xml:XML = new XML(loader.data);
				
				if(_startMap==0)
				{
					_startMap = xml.@startMap;
					_startX = xml.@startX;
					_startY = xml.@startY;
					
				}
				
				if(int(xml.@startMission) && Global.userdata.startMission==0)
				{
					Global.userdata.startMission = int(xml.@startMission);
				}
					
				var dirConfigPlayer:Array = String(xml.direction.@player).split(',');
				var dirConfigNpc:Array =  String(xml.direction.@npc).split(',');
				
				GameObject.DEFAULT_DIRECTION.Down = dirConfigPlayer[4];
				GameObject.DEFAULT_DIRECTION.LeftDown = dirConfigPlayer[3];
				GameObject.DEFAULT_DIRECTION.Left = dirConfigPlayer[2];
				GameObject.DEFAULT_DIRECTION.LeftUp = dirConfigPlayer[1];
				GameObject.DEFAULT_DIRECTION.Up = dirConfigPlayer[0];
				GameObject.DEFAULT_DIRECTION.RightUp = -dirConfigPlayer[1];
				GameObject.DEFAULT_DIRECTION.Right = -dirConfigPlayer[2];
				GameObject.DEFAULT_DIRECTION.RightDown = -dirConfigPlayer[3];
				
				onD5GameDone();
			}
				
				
			var onD5GameError:Function = function(e:IOErrorEvent):void
			{
				loader.removeEventListener(Event.COMPLETE,onD5GameConfig);
				loader.removeEventListener(IOErrorEvent.IO_ERROR,onD5GameError);
				
				onD5GameDone();
			}
			
			var onD5GameDone:Function = function():void
			{
				if(_startMap>0)
				{
					setconfig(_startMap);
					_startMap = 0;
				}
				
				if(_config!='')
				{
					loadConfig();
				}else{
					setupMySelf();
				}
				
				addEventListener(Event.DEACTIVATE,onDeactivete);
				_stg.addEventListener(ChangeMapEvent.CHANGE,onChangeMap);
				_stg.addEventListener(Event.RESIZE,onResize);
			}
			
			// 尝试加载引擎标准配置文件
			var d5rpgConfig:String = _projPath+'d5game.d5';
			var loader:URLLoader = new URLLoader();
			loader.addEventListener(Event.COMPLETE,onD5GameConfig);
			loader.addEventListener(IOErrorEvent.IO_ERROR,onD5GameError);
			loader.load(new URLRequest(d5rpgConfig));
			
		}
		
		protected function onCreateStage3D(e:Event):void
		{
			_gpuContext0 = stage.stage3Ds[0].context3D;
			_gpuMode = true;
		}
		
		
		
		/**
		 * 加载配置文件
		 */ 
		protected function loadConfig():void
		{
			loader = new URLLoader();
			loader.dataFormat = URLLoaderDataFormat.BINARY;
			loader.load(new URLRequest(_config));
			loader.addEventListener(IOErrorEvent.IO_ERROR,onConfigIO);
			loader.addEventListener(Event.COMPLETE,parseData);
			
		}
		
		protected function onChangeMap(e:ChangeMapEvent):void
		{
			if(e.isAutoSetup)
			{
				if(e.sameMapNotChange && _id==e.toMap) return; // 同地图不切换
				clear();
				setconfig(e.toMap);
				_id = e.toMap;
				_nextStep = setupMySelf;
			}else{
				
				if(e.sameMapNotChange && _config=='map'+e.toMap) return; // 同地图不切换
				
				setconfig(e.toMap);
				_id = e.toMap;
				_nextStep =  loadConfig;
				
				clear();
			}
			
			_data = null;
			_startX = e.toX;
			_startY = e.toY;
		}
		
		/**
		 * 当FP失去焦点时候的处理函数
		 */ 
		protected function onDeactivete(e:Event):void
		{
			
		}
		
		protected function onConfigIO(e:IOErrorEvent):void
		{
			trace("[D5Game]Can not found map config file.");
			dispatchEvent(new D5IOErrorEvent(D5IOErrorEvent.CONF_ERROR,D5IOErrorEvent._MAP));
		}
		
		/**
		 * 创建游戏场景
		 */ 
		protected function buildScene():void
		{
			if(_scene==null) _scene = new BaseScene(_stg,this);
		}
		
		/**
		 * 解析配置文件
		 */ 
		protected function parseData(e:Event):void
		{
			loader.removeEventListener(Event.COMPLETE,parseData);
			var by:ByteArray = loader.data as ByteArray;
			by.uncompress();
			var configXML:String = by.readUTFBytes(by.bytesAvailable);
			setup(configXML);
		}
		
		protected function setupMySelf():void
		{
			throw new Error("[D5Game]看到这个错误，是因为您选择了自己初始化D5RPG，但又没有覆写setupMySelf方法。当前的操作识别码为"+_id);
		}
		
		/**
		 * 根据配置文件进行场景的数据初始化
		 */ 
		protected function setup(s:String):void
		{
			_data = new XML(s);
			
			Global.TILE_SIZE.x = _data.tileX;
			Global.TILE_SIZE.y = _data.tileY;
			Global.MAPSIZE.x = _data.mapW;
			Global.MAPSIZE.y = _data.mapH;
			
			
			setGlobalSize(int(_data.mapW),int(_data.mapH));
			
			var loadArr:Array = [];
			var libArr:Array = [];
			
			if(Global.characterLib==null && Global.LIBNAME!='')
			{
				loadArr.push(Global.LIBNAME);
				libArr.push('characterLib');
			}
			
			buildScene();
			
			if(WorldMap.me) WorldMap.me.removeEventListener(Event.COMPLETE,init);
			_camera = new D5Camera(_scene);
			_camera.lookAt(_startX,_startY);
			
			_scene.setupMap(_data.id,_data.hasTile,_data.tileFormat);
			
			if(_data.loopbg!='') WorldMap.me.loopBG = _data.loopbg;
			
			if(loadArr.length>0)
			{
				configMLoader(loadArr,libArr);
			}else{
				start();
			}
		}
		
		protected function configMLoader(loadArr:Array,libArr:Array):void
		{
			// 自动加载资源库
			_mtLoader = new MutiLoader(_loadData);
			_mtLoader.addEventListener(Event.COMPLETE,onLoadComplate);
			addChild(_mtLoader);
			_mtLoader.load(loadArr,libArr);
			
		}
		
		/**
		 * 资源库加载完成后进行素材处理
		 */ 
		protected function onLoadComplate(e:Event):void
		{
			_mtLoader.clear();
			_mtLoader.removeEventListener(Event.COMPLETE,onLoadComplate);
			
			if(_mtLoader.libList==null)
			{
				if(_loadData.length==1)
				{
					Global.mapLib = _loadData[1] as ApplicationDomain;
				}else{
					Global.characterLib = _loadData[0] as ApplicationDomain;
					Global.mapLib = _loadData[1] as ApplicationDomain;
				}
			}else{
				for(var i:uint = 0;i<_mtLoader.libList.length;i++)
				{
					Global[_mtLoader.libList[i]] = _loadData[i];
				}
			}
			
			removeChild(_mtLoader);
			_mtLoader=null;
			start();
		}
		
		/**
		 * 开始运行
		 */ 
		protected function start():void
		{
			if(WorldMap.me.smallMap==null)
			{
				WorldMap.me.addEventListener(Event.COMPLETE,init);
			}else{
				init();
			}
		}
		
		protected function init(e:Event=null):void
		{
			if(e!=null) WorldMap.me.removeEventListener(Event.COMPLETE,init);
			
			buildObjects();
			buildPlayer();
			
			play();
			
			Global.GC();
			
			if(_scene.Player)
			{
				_scene.Player.setPos(_startX,_startY);
				_scene.Player.controler.setupListener();
			}else{
				_camera.lookAt(_startX,_startY);
			}
			
			if(_readyBack!=null)
			{
				_readyBack();
				_readyBack = null;
			}
			
			
			//if(stage.stageWidth>Global.MAPSIZE.x) x = int((stage.stageWidth-Global.MAPSIZE.x)>>1);
			
		}
		
		protected function buildPlayer():void
		{
			
		}
		
		/**
		 * 根据配置文件构建场景所有游戏对象
		 */ 
		protected function buildObjects():void
		{
			
			if(_data!=null)
			{
				if(_data.music!=null) Global.bgMusic.play(_data.music);
				
				for each(var npclist:XML in _data.npc.obj)
				{
					var obj:NCharacterObject = _scene.createNPC(npclist.res,WorldMap.me.mapid+"_"+npclist.res,npclist.name,new Point(npclist.posx,npclist.posy));
					obj.uid = int(npclist.uid);
					obj.$say = npclist.@say;
					obj.loadMission();
				}
				
				for each(var buildList:XML in _data.build.obj)
				{
					if(buildList.res=='') continue;
					var bld:BuildingObject = _scene.createBuilding(WorldMap.LIB_DIR+'map/map'+WorldMap.me.mapid+'/'+buildList.res,WorldMap.me.mapid+"_"+buildList.res,new Point(buildList.posx,buildList.posy));
					bld.zero=new Point(buildList.centerx,buildList.centery);
					bld.canBeAtk = buildList.canBeAtk=='true' ? true : false;
					bld.zOrderF = buildList.zorder;
				}
				
				for each(var roadList:XML in _data.roadpoint.obj)
				{
					if(!roadList.hasOwnProperty('res')) continue;
					var road:RoadPoint = _scene.createRoad(roadList.res,roadList.posx,roadList.posy);
					road.toMap = roadList.toMap;
					road.toX = roadList.toX;
					road.toY = roadList.toY;
					road.canBeAtk=false;
				}
			}
		}
		
		protected function autoUnsetup(e:Event):void
		{
			var timer:Timer = e.target as Timer;
			timer.stop();
			timer.removeEventListener(TimerEvent.TIMER,autoUnsetup);
			
			if(_scene)_scene.clear();
			_scene = null;
			
			if(_nextStep!=null) _nextStep();
			_nextStep=null;
		}
		
		/**
		 * 停止运行
		 */ 
		public function stop():void
		{
			removeEventListener(Event.ENTER_FRAME,render);
			removeEventListener(Event.DEACTIVATE,onDeactivete);
			if(_scene && _scene.Player!=null) _scene.Player.controler.unsetupListener();
		}
		
		public function play():void
		{
			if(hasEventListener(Event.ENTER_FRAME)) return;
			addEventListener(Event.ENTER_FRAME,render);
			if(_scene && _scene.Player!=null) _scene.Player.controler.setupListener();
		}
		
		/**
		 * 渲染
		 */ 
		protected function render(e:Event):void
		{
			if(_scene.isReady) _scene.render();
		}
		
		private function onResize(e:Event):void
		{
			if(_stg.stageWidth>0)
			{
				setGlobalSize();
				if(WorldMap.me) WorldMap.me.resize();
			}
		}
		
		private function error():void
		{
			throw new Error(this," can only build once.");
		}
	}
}