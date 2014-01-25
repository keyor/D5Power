/**
 * D5Power Studio FPower 2D MMORPG Engine
 * 第五动力FPower 2D 多人在线角色扮演类网页游戏引擎
 * 
 * copyright [c] 2010 by D5Power.com Allrights Reserved.
 */ 
package com.d5power.objects
{
	
	import com.d5power.D5Game;
	import com.d5power.controller.BaseControler;
	import com.d5power.display.D5TextField;
	import com.d5power.graphics.ISwfDisplayer;
	import com.d5power.map.WorldMap;
	import com.d5power.net.D5StepLoader;
	import com.d5power.ns.NSGraphics;
	import com.d5power.stuff.HSpbar;
	import com.d5power.utils.CharEffectImplement;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;

	use namespace NSGraphics;
	
	/**
	 * 游戏角色类对象基类
	 * 游戏中全部角色类（包括NPC）的根类
	 */
	
	public class CharacterObject extends GameObject
	{
		/**
		 * HP最大值
		 */ 
		public var hpMax:uint;
		
		/**
		 * SP最大值
		 */ 
		public var spMax:uint;
		
		/**
		 * 角色名称
		 */ 
		protected var _nameBox:Bitmap;
		
		protected var _hpBar:HSpbar;
		
		/**
		 * HP值
		 */ 
		protected var _hp:uint;
		/**
		 * SP值
		 */ 
		protected var _sp:uint;
		
		NSGraphics var alphaCheck:Boolean=false;
		
		
		private var _text:D5TextField;
		
		// 特效相关
		private var _opened_eff_name:String;
		
		private var _all_implements:Array;
		
		private var _opend_implements:Array;
		
		private var _play_implements_id:int=-1;
		
		private var _has_eff_num:uint;
		
		private var _hasReset:Boolean;
		
		private var _changeSetFrame:uint;
		
		public function CharacterObject(ctrl:BaseControler=null)
		{
			//TODO: implement function
			super(ctrl);
			objectName = 'CharacterObject';
		}
		
		/**
		 * 打开特效方案<br>
		 * 启用一系列特效方案，并在角色发生动作变化时自动切换
		 * @param	eff_name	特效方案名
		 */ 
		public function openEffect(eff_name:String):void
		{
			_opened_eff_name = eff_name;
			
			if(_all_implements==null)
			{
				if(_displayer==null || _displayer.swfPath==null) return;
				_all_implements = new Array();
				D5StepLoader.me.addLoad(_displayer.swfDir+'/effect.xml',configEffect,false,D5StepLoader.TYPE_XML);
			}else{
				_opend_implements = [];
				for each(var obj:CharEffectImplement in _all_implements)
				{
					if(obj.name==_opened_eff_name && _displayer.swfPath==obj.actionRes)
					{
						_opend_implements.push(obj);
					}
				}
				
				_has_eff_num = _opend_implements.length;
			}
		}
		
		/**
		 * 立即播放某个特效
		 */ 
		public function playEffectNow(eff_id:uint):void
		{
			if(_play_implements_id!=-1 && eff_id!=_play_implements_id) return;
			_play_implements_id = eff_id;
			
			if(_all_implements==null)
			{
				if(_displayer==null || _displayer.swfPath==null) return;
				_all_implements = new Array();
				D5StepLoader.me.addLoad(_displayer.swfDir+'/effect.xml',configEffect,false,D5StepLoader.TYPE_XML);
			}else{
				_opend_implements = [];
				for each(var obj:CharEffectImplement in _all_implements)
				{
					if(obj.index==_play_implements_id)
					{
						_opend_implements.push(obj);
						break;
					}
				}
				
				_has_eff_num = 1;
			}
		}
		
		override public function set action(u:int):void
		{
			super.action = u;
			if(_opened_eff_name!=null) openEffect(_opened_eff_name);
		}
		
		public function set hp(val:int):void
		{
			_hp = val>0 ? val : 0;
			if(_hpBar!=null)
			{
				_hpBar.update();
			}
		}

		public function get hp():int
		{
			return _hp;
		}
		
		/**
		 * 设置名字
		 * @param	_name	角色名
		 * @param	color	字体颜色	，若为-1则自动根据Global的阵营设置进行判断
		 * @param	bordercolor	描边颜色
		 */ 
		public function setName(_name:String,color:int=-1,bordercolor:int=0,py:int=0):void
		{
			if(_text==null)
			{
				_text = new D5TextField('',0xFFFFFF);
			}
			
			
			_text.text = _name;
			_text.autoGrow();
			
			if(color==-1)
			{
				_text.textColor = Global.userdata.camp==camp ? 0x99ff00 : 0xff0000;
				_text.fontBorder = Global.userdata.camp==camp ? 0x003300 : 0x390000;
			}else{
				_text.textColor = color;
				_text.fontBorder = bordercolor;
			}
			_text.align=D5TextField.CENTER;
			
			if(_nameBox!=null)
			{
				_nameBox.bitmapData.dispose();
			}else{
				_nameBox = new Bitmap();
			}

			var bd:BitmapData = new BitmapData(_text.width,_text.height,true,0x00000000);
			bd.draw(_text);
			
			_nameBox.bitmapData = bd;
			_nameBox.y = py;
			
			flyName();
			addChild(_nameBox);
		}
		
		public function get chareacterName():String
		{
			return _text.text;
		}
		
		/**
		 * 设置HP条
		 */ 
		public function set hpBar(bar:HSpbar):void
		{
			_hpBar = bar;
			addChild(_hpBar);
		}
		
		protected function configEffect(data:XML):void
		{
			var impl:CharEffectImplement;
			for each(var obj:Object in data.implement)
			{
				impl = new CharEffectImplement();
				impl.format(obj);
				_all_implements.push(impl);
			}
			
			_play_implements_id!=-1 ? playEffectNow(_play_implements_id) : openEffect(_opened_eff_name);
		}
		
		/**
		 * 调整角色名称位置
		 */ 
		protected function flyName():void
		{
			_nameBox.x = -int(_nameBox.width/2);
		}
		
		override protected function renderAction():void
		{
			super.renderAction();
			if(_displayer)
			{
				alpha = WorldMap.me.isInAlphaArea(pos.x,pos.y) ? .5 : 1;
			}
			
			if(_has_eff_num)
			{
				var _implement:CharEffectImplement;
				for(var i:uint=0;i<_has_eff_num;i++)
				{
					_implement = _opend_implements[i];
					var f:uint = _displayer.nowFrame;
					if(f==_implement.startFrame && !_hasReset)
					{
						_changeSetFrame = f;
						_hasReset = true;
						
						var obj:EffectObject;
						if(_implement.sonAngleAdd)
						{
							var num:uint = _implement.sonAngleAddNum==0 ? int(360/_implement.sonAngleAdd) : _implement.sonAngleAddNum;
							var angle:Number = Global.PI_180*_implement.sonAngleAdd;
							
							for(var sonIndex:uint = 0;sonIndex<num;sonIndex++)
							{
								obj = EffectObject.getInstance();
								obj.updateSetting(_implement,_displayer.renderDirection,pos.x,pos.y);
								obj.updateSonCopy(sonIndex,angle);
								D5Game.me.scene.addObject(obj);
							}
						}else{
							obj = EffectObject.getInstance();
							obj.updateSetting(_implement,_displayer.renderDirection,pos.x,pos.y);
							D5Game.me.scene.addObject(obj);
						}
						
						if(_play_implements_id!=-1)
						{
							_play_implements_id = -1;
							_has_eff_num=0;
							_opend_implements = null;
						}
					}else if(f!=_changeSetFrame){
						_hasReset = false;
					}
				}
				
				
			}
		}
		
		override protected function build():void
		{
			super.build();
			if(_nameBox!=null) flyName(); // 重新调整名字坐标
		}

		
	}
	
}