/**
 * D5Power Studio FPower 2D MMORPG Engine
 * 第五动力FPower 2D 多人在线角色扮演类网页游戏引擎
 * 
 * copyright [c] 2010 by D5Power.com Allrights Reserved.
 */ 
package com.d5power.core
{
	import com.d5power.D5Camera;
	import com.d5power.D5Game;
	import com.d5power.controller.Perception;
	import com.d5power.core.mission.EventData;
	import com.d5power.core.mission.MissionData;
	import com.d5power.core.particle.ParticleBox;
	import com.d5power.events.ChangeMapEvent;
	import com.d5power.graphics.Swf2d;
	import com.d5power.map.WorldMap;
	import com.d5power.ns.NSCamera;
	import com.d5power.ns.NSGraphics;
	import com.d5power.objects.BuildingObject;
	import com.d5power.objects.CharacterObject;
	import com.d5power.objects.EffectObject;
	import com.d5power.objects.GameObject;
	import com.d5power.objects.IGO;
	import com.d5power.objects.NCharacterObject;
	import com.d5power.objects.RoadPoint;
	
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.sampler.startSampling;
	import flash.utils.getTimer;
	
	
	use namespace NSCamera;
	use namespace NSGraphics;

	public class BaseScene
	{
		
		/**
		 * 感知器
		 */
		public var perc:Perception;
		
		/**
		 * 游戏内的显示对象
		 */
		protected var _objects:Array;
		
		/**
		 * 在屏幕中的游戏对象
		 */ 
		protected var _inScreen:Array;
		
		/**
		 * 地图
		 */ 
		protected var map:WorldMap;
		
		/**
		 * 双缓冲区
		 */ 
		//public var doubleBuffer:BitmapData;
		
		protected var _mapGround:Shape;
		
		/**
		 * 效果缓冲区，本缓冲区位于最上层
		 */ 
		//public var effectBuffer:BitmapData;		
		
		protected var _stage:Stage;
		
		protected var _isReady:Boolean=false;
		
		/**
		 * 主角
		 */ 
		protected static var player:CharacterObject;
		

		
		protected var _container:DisplayObjectContainer;
		
		protected var _layer_go:Sprite;
		protected var _layer_effect:Sprite;
		protected var _layer_effect_down:Sprite;

		/**
		 * 深度使用列表
		 */ 
		private static var _deepList:Vector.<uint>;
		
		/**
		 * 当前正在渲染的对象
		 */ 
		private var _nowRend:int;
		
		/**
		 * 当前舞台上的显示对象个数，用于排序
		 */ 
		private var _childMax:int;
		
		/**
		 * 当前正在计算的屏幕外控制器
		 */ 
		private var _nowRunOutSceneCtrl:uint;
		
		
		
		/**
		 * @param	stg			舞台
		 * @param	container	渲染容器，若为NULL则指定为舞台
		 */ 
		public function BaseScene(stg:Stage,container:DisplayObjectContainer)
		{
			if(_deepList!=null)
			{
				_deepList.splice(0,_deepList.length)
			}else{
				_deepList = new Vector.<uint>;
			}
			
			perc = new Perception(this);
			_stage=stg;
			_container = container;
			
			_objects = new Array();
			_inScreen = new Array();
			

			_layer_go = new Sprite;
			_layer_effect = new Sprite;
			_layer_effect_down = new Sprite;
	
			_container.addChild(_layer_effect_down);
			_container.addChild(_layer_go);
			_container.addChild(_layer_effect);
			
			
			buildBuffer();
		}
		
		/**
		 * 初始化地图
		 * @param	mapid		地图ID
		 * @param	hasTile		是否地砖地图（分块加载）
		 * @param	tileFormat	地砖格式
		 */ 
		public function setupMap(mapid:uint,hasTile:uint,tileFormat:String):void
		{
			map = new WorldMap(mapid);
			map.hasTile = hasTile;
			map.tileFormat = tileFormat;
			map.dbuffer = _mapGround;
			map.install();
			
			
			_container.addChild(_mapGround);
			_isReady = true;
		}
		
		
		/**
		 * 点击了有任务的NPC后的处理
		 * @param	obj		当前点击的NPC
		 */ 
		public function missionCallBack(obj:NCharacterObject):void
		{
			
		}
		
		/**
		 * 任务加载完成后触发
		 */ 
		public function missionLoaded():void
		{
			var obj:IGO;
			for(var i:int = 0,j:uint=_objects.length;i<j;i++)
			{
				obj = _objects[i];
				if(obj is NCharacterObject)
				{
					(obj as NCharacterObject).loadMission(); 
				}
			}
		}
		
		/**
		 * 创建NPC
		 * @param	s			位图资源名
		 * @param	resname		缓冲池资源名
		 * @param	name		NPC姓名
		 * @param	pos			目前所在位置
		 * @param	dirConfig	方向配置参数，若为NULL，则为静态1帧
		 */
		public function createNPC(s:String,resname:String,name:String='',pos:Point=null,dirConfig:Object=null):NCharacterObject
		{
			var displayer:Swf2d = new Swf2d();
			displayer.changeSWF('asset/mapRes/'+s,false);
			
			var npc:NCharacterObject = new NCharacterObject(null);
			npc.displayer = displayer;
			npc.setName(name);
			npc.direction = npc.directions.Stop;
			

			if(pos!=null)
			{
				npc.setPos(pos.x,pos.y);
				addObject(npc);
			}
			
			
			
			return npc;
		}
		/**
		 * 创建路点
		 * @param	s		资源路径
		 * @param	frame	路点素材帧数
		 * @param	pos		坐标
		 */ 
		public function createRoad(res:String,posx:uint=0,posy:uint=0):RoadPoint
		{
			var obj:RoadPoint = new RoadPoint();
			var swf2d:Swf2d = new Swf2d();
			swf2d.changeSWF('asset/mapRes/'+res);
			
			obj.displayer = swf2d;
			obj.setPos(posx,posy);
			
			addObject(obj);
			
			return obj;
		}
		
		/**
		 * 创建建筑
		 * @param	resList
		 * @param	pos		目前所在位置
		 */ 
		public function createBuilding(resource:String,resname:String,pos:Point=null):BuildingObject
		{
			var displayer:Swf2d = new Swf2d();
			displayer.changeSWF('asset/mapRes/'+resource);
			
			var house:BuildingObject = new BuildingObject(this);
			if(pos!=null)
			{
				house.setPos(pos.x,pos.y);
				
			}
			house.displayer = displayer;
			
			if(pos!=null) house.setPos(pos.x,pos.y);
			
			addObject(house);
			
			return house;
		}
		
		/**
		 * 创建玩家
		 * @param	s		位图资源
		 * @param	name	玩家姓名
		 * @param	pos		目前所在位置
		 * @param	ctrl	专用控制器，如果为空，则使用默认的角色控制器
		 */ 
		public function createPlayer(p:CharacterObject):void
		{
			if(player==null) player = p;
			
			// 更新感知器为当前场景的感知器。由于player为静态变量，因此当场景重建后，其感知器依然指向已不存在的旧感知器
			p.controler.perception = perc; 
			player.alphaCheck=true;
			player.reSetPos(D5Game.me.startX,D5Game.me.startY);
			D5Game.me.camera.focus(player);
			addObject(player);
			//pushRenderList(player);
		}
		
		/**
		 * 创建效果
		 * @param	b					要创建的效果
		 * @param	checkView			创建时是否检测视口，若为false，则无条件添加。否则，物品必须在视野范围内才会添加
		 * @param	userEffectBuffer	是否使用EFFECT缓存
		 */ 
		public function createEffect(b:GameObject,useEffectBuffer:Boolean=false):void
		{			
			//b.render=useEffectBuffer ? render_effect : render_building;
			addObject(b);
		}
		
		/**
		 * 重新裁剪
		 * 更新目前屏幕内的游戏对象
		 * 
		 * @param	update		是否更新摄像头可视区域
		 */ 
		NSCamera function ReCut(update:Boolean=true):void
		{
			for each(var obj:IGO in _objects)
			{
				//if(obj==player) continue;
				obj.inScreen = D5Camera.cameraView.containsPoint(obj._POS);
			}
			D5Camera.$needReCut = false;
		}
		

		public function get Player():CharacterObject
		{
			return player;
		}
		
		/**
		 * 初始化缓冲区
		 */ 
		public function buildBuffer():void
		{
			//doubleBuffer = new BitmapData(Global.W,Global.H,false,0);
			//effectBuffer = new BitmapData(Global.W,Global.H,false,0);
			
			_mapGround = new Shape();
			//_mapGround.cacheAsBitmap=true;
		}

		
		/**
		 * 向场景中添加游戏对象
		 */ 
		public function addObject(o:IGO):void
		{
			var index:int = _objects.indexOf(o);
			if(index==-1)_objects.push(o);

			if(D5Camera.cameraView.containsPoint(o._POS))
			{
				o.inScreen = true;
			}else{
				o.inScreen = false;
			}
		}
		
		/**
		 * IGO接口调用专供，其他位置请勿使用
		 * 向场景中新增对象
		 */ 
		public function $insertObject(obj:IGO):void
		{
			_inScreen.push(obj);
			_layer_go.addChild(obj as DisplayObject);
		}
		/**
		 * IGO接口调用专供，其他位置请勿使用
		 * 从场景中移除对象
		 */ 
		public function $removeObject(obj:IGO):void
		{
			if((obj as DisplayObject).parent) (obj as DisplayObject).parent.removeChild(obj as DisplayObject);
		}
		
		/**
		 * IGO接口调用专供，其他位置请勿使用
		 * 向场景中新增特效对象
		 */ 
		public function $insertEffect(obj:IGO,lowLv:Boolean):void
		{
			lowLv ? _layer_effect_down.addChild(obj as DisplayObject) : _layer_effect.addChild(obj as DisplayObject);
		}
		
		/**
		 * 
		 */ 
		private function removeObject(index:uint):void
		{
			var data:Array = _objects.splice(index,1);
			
			data[0].dispose();
		}
		
		/**
		 * 获得特定的游戏对象
		 * @param	i	索引
		 */ 
		public function getObject(i:uint):IGO
		{
			if(i>ObjectsNumber)
				return null;
			else
				return _objects[i];	
		}
		
		/**
		 * 获得特定的角色对象
		 * 
		 * @param	i	索引
		 */ 
		public function getCharacter(i:uint):CharacterObject
		{
			if(i>ObjectsNumber)
				return null;
			else
				return _objects[i] as CharacterObject;
		}
		
		/**
		 * 得到所有游戏对象
		 */
		public function get objList():Array
		{
			return _objects;
		}
		
		/**
		 * 获得目前舞台中的
		 * 
		 */ 
		public function get ObjectsNumber():uint
		{
			return _objects.length;
		}
		
		/**
		 * 记忆工作区
		 */ 
		public function set stage(s:Stage):void
		{
			_stage=s;
		}
		
		/**
		 * 获取工作区
		 */ 
		public function get stage():Stage
		{
			return _stage;
		}

		/**
		 * 是否加载完成
		 */ 
		public function get isReady():Boolean
		{
			return _isReady;
		}
		
		/**
		 * 更换场景
		 * @param	id		目的场景ID
		 * @param	startx	起始坐标X
		 * @param	starty	起始坐标Y
		 */ 
		public function changeScene(id:uint,startx:uint,starty:uint):void
		{
			_stage.dispatchEvent(new ChangeMapEvent(id,startx,starty));
		}
		
		/**
		 * 渲染输出
		 * 
		 */ 
		public function render():void
		{
			updateTime();			
			draw();
		}
		
		protected function updateTime():void
		{
			Global.Timer = getTimer();
		}
		
		protected function draw():void
		{
			map.render();
			if(_objects.length==0) return;
			
			ParticleBox.me.render();
			
			// 每帧必须运行的位置计算
			for(var i:int = _objects.length-1;i>=0;i--)
			{
				_objects[i].deleteing ? removeObject(i) : _objects[i].runPos()
			}
			
			for(i=_inScreen.length-1;i>=0;i--)
			{
				if(_inScreen[0].deleteing || !_inScreen[0].inScreen) _inScreen.splice(i,1);
			}
			
			if(_nowRend==0)
			{
				_nowRend = _objects.length;
				_inScreen.sortOn("zOrder",Array.NUMERIC);

				var orderCount:uint = _inScreen.length;
				// 交换层次对象
				var child:DisplayObject;	// 场景对象
				var child_now:DisplayObject;
				while(orderCount--)
				{
					child_now = _inScreen[orderCount];
					if(orderCount<_layer_go.numChildren)
					{
						child = _layer_go.getChildAt(orderCount);
						if(child!=child_now && _layer_go.contains(child_now)) _layer_go.setChildIndex(child_now,orderCount);
					}
				}
				_container.setChildIndex(_mapGround,0);
				ReCut();
			}
			
			if(getTimer()-Global.Timer>D5Camera.RenderMaxTime) return;
			
			// 循环对象
			var target:IGO;
			while(_nowRend--)
			{
				target = _objects[_nowRend];
				target.renderMe();
				if(getTimer()-Global.Timer>D5Camera.RenderMaxTime) break;
			}
			if(_nowRend<0) _nowRend=0;

			
			
			D5Game.me.camera.update();
		}
		
		public function get container():DisplayObjectContainer
		{
			return _container;
		}
		
		public function clear():void
		{
			_objects.splice(0,_objects.length);
			
			while(_layer_effect.numChildren) _layer_effect.removeChildAt(0);
			while(_container.numChildren) _container.removeChildAt(0);
			
			_mapGround.graphics.clear();
			_mapGround = null;
			
			if(player) player.controler.unsetupListener();
			//doubleBuffer.dispose();
		}
	}
}