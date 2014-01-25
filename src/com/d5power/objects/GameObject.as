/**
 * D5Power Studio FPower 2D MMORPG Engine
 * 第五动力FPower 2D 多人在线角色扮演类网页游戏引擎
 * 
 * copyright [c] 2010 by D5Power.com Allrights Reserved.
 */ 
package com.d5power.objects
{
	import com.d5power.D5Camera;
	import com.d5power.D5Game;
	import com.d5power.controller.BaseControler;
	import com.d5power.graphics.ISwfDisplayer;
	import com.d5power.map.WorldMap;
	import com.d5power.ns.NSCamera;
	import com.d5power.ns.NSEditor;
	import com.d5power.utils.NoEventSprite;
	
	import flash.geom.Point;

	use namespace NSCamera;

	/**
	 * 游戏对象基类
	 * 游戏中全部对象的根类
	 */ 
	public class GameObject extends NoEventSprite implements IGO
	{
		
		/**
		 * 默认方向配置
		 */ 
		public static var DEFAULT_DIRECTION:Direction=new Direction();
		
		/**
		 * 渲染是否更新,若为true则无需渲染,若为false则需要重新渲染
		 */ 
		public var RenderUpdated:Boolean=false;

		
		public var ID:uint=0;
		
		/**
		 * 移动速度
		 */ 
		public var speed:Number;
		
		/**
		 * 是否可被攻击
		 */ 
		public var canBeAtk:Boolean=false;

		/**
		 * 角色阵营
		 */ 
		public var camp:uint=0;
		
		/**
		 * 类型名，用于点击区分
		 */ 
		public var objectName:String;
		
		protected var _displayer:ISwfDisplayer;
		
		/**
		 * 深度排序
		 */ 
		protected var zorder:int = 0;

		/**
		 * 控制器,每个对象都可以拥有控制器。控制器是进行屏幕裁剪后对不在屏幕内
		 * 的对象进行处理的接口。
		 */ 
		protected var _controler:BaseControler;
		/**
		 * 对象定位
		 */ 
		protected var pos:Point;
		
		/**
		 * 排序调整
		 */ 
		protected var _zOrderF:int;
		
		protected var _action:int;
		
		protected var _direction:int;
		
		private var _resname:String;
		
		private var _deleteing:Boolean;
		private var _inScreen:Boolean;

		/**
		 * @param	ctrl	控制器
		 */ 
		public function GameObject(ctrl:BaseControler = null)
		{
			pos = new Point(0,0);
			speed = 1.4;
			changeController(ctrl);
		}
		
		public function set deleteing(v:Boolean):void
		{
			_deleteing = v;
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
			_inScreen ? D5Game.me.scene.$insertObject(this) : D5Game.me.scene.$removeObject(this);
		}
		
		/**
		 * 设置动作,若设置了displayer（Swf2d或Swf2p5），则会修改显示器的对应动作
		 */ 
		public function set action(u:int):void
		{
			_action = u;
			if(_displayer!=null) _displayer.action = u;
		}
		
		/**
		 * 获取当前动作
		 */ 
		public function get action():int
		{
			return _action;
		}
		

		/**
		 * 更换控制器
		 */ 
		public function changeController(ctrl:BaseControler):void
		{
			if(_controler!=null)
			{
				_controler.unsetupListener();
			}
			
			if(ctrl!=null)
			{
				_controler = ctrl;
				_controler.me=this;
				_controler.setupListener();
			}
			
		}
		/**
		 * 设置对象的坐标定位
		 * @param	p
		 */ 
		public function setPos(px:Number,py:Number):void
		{
			pos.x = px;
			pos.y = py;
			zorder = pos.y;
			
			if(D5Camera.cameraView.contains(px,py)) inScreen=true;
		}
		
		/**
		 * 将对象移动到某一点，并清除当前正在进行的路径
		 */ 
		public function reSetPos(px:Number,py:Number):void
		{
			setPos(px,py);
			if(controler!=null) controler.clearPath();
		}

		/**
		 * 获取对象的坐标定位
		 */ 
		public function get PosX():Number
		{
			return pos.x;
		}
		
		/**
		 * 获取对象的坐标定位
		 */ 
		public function get PosY():Number
		{
			return pos.y;
		}
		
		/**
		 * 本坐标仅可用来获取！！！
		 */ 
		public function get _POS():Point
		{
			return pos;
		}
		/**
		 * 深度排序浮动
		 */ 
		public function set zOrderF(val:int):void
		{
			_zOrderF = val;
		}
		/**
		 * 深度排序浮动
		 */
		public function get zOrderF():int
		{
			return _zOrderF;
		}
		
		/**
		 * 获取坐标的深度排序
		 */ 
		public function get zOrder():int
		{
			//return zorder;
			return pos.y+_zOrderF;
		}
		
		public function get controler():BaseControler
		{
			return _controler;
		}
		
		
		/**
		 * 渲染自己在屏幕上输出
		 */
		public function renderMe():void
		{			
			renderAction();
		}
		
		/**
		 * 计算坐标
		 */ 
		public function runPos():void
		{
			if(_controler) _controler.calcAction();
			
			var targetx:Number;
			var targety:Number;
			var maxX:uint = Global.MAPSIZE.x;
			var maxY:uint = Global.MAPSIZE.y;
			
			if(D5Game.me.camera.focusObject==this)
			{
				targetx = pos.x<(Global.W>>1) ? pos.x : (Global.W>>1);
				targety = pos.y<(Global.H>>1) ? pos.y : (Global.H>>1);
				
				targetx = pos.x>maxX-(Global.W>>1) ? pos.x-(maxX-Global.W) : targetx;
				targety = pos.y>maxY-(Global.H>>1) ? pos.y-(maxY-Global.H) : targety;
			}else{
				var target:Point = WorldMap.me.getScreenPostion(pos.x,pos.y);
				targetx = target.x;
				targety = target.y;
			}
			x = Number(targetx.toFixed(1));
			y = Number(targety.toFixed(1));
		}
		/**
		 * 获取当前渲染对象，目标应该为Swf2d或Swf2p5
		 */ 
		public function get displayer():ISwfDisplayer
		{
			return _displayer;
		}
		/**
		 * 设置渲染对象，目标应该为Swf2d或Swf2p5
		 */ 
		public function set displayer(v:ISwfDisplayer):void
		{
			if(numChildren>0) removeChildren(0,numChildren-1);
			
			_displayer = v;
			_displayer.onReady = build;
			
			addChild(_displayer.shadow);
			addChild(_displayer.monitor);
		}
		
		/**
		 * 获取当前角色方向
		 */ 
		public function get direction():int
		{
			return _direction;
		}
		/**
		 * 设置当前角色方向
		 */ 
		public function set direction(v:int):void
		{
			_direction = v;
			if(_displayer!=null) _displayer.direction = _direction;
		}
		/**
		 * 获取当前角色的方向配置信息
		 */ 
		public function get directions():Direction
		{
			return DEFAULT_DIRECTION;
		}
		
		
		/**
		 * 释放资源
		 */ 
		public function dispose():void
		{
			if(_controler) _controler.dispose();
			if(_displayer) _displayer.dispose();
			_deleteing = false;
			if(parent) parent.removeChild(this);
			Global.GC();
		}

		/**
		 * 编辑器专用，当前角色使用的资源名
		 */ 
		NSEditor function get resName():String
		{
			return _resname;
		}
		
		/**
		 * 编辑器专用，当前角色使用的资源名
		 */ 
		NSEditor function set resName(s:String):void
		{
			_resname = s;
		}
		
		
		/**
		 * 渲染动作
		 */ 
		protected function renderAction():void
		{
			if(_displayer is ISwfDisplayer) (_displayer as ISwfDisplayer).render();
		}
		
		/**
		 * 当素材准备好后调用的初始化函数
		 */ 
		protected function build():void
		{
			
		}
	}
}