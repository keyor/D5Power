package com.d5power.objects
{
	import com.d5power.controller.BaseControler;
	import com.d5power.core.mission.MissionData;
	import com.d5power.net.D5StepLoader;
	import com.d5power.ns.NSD5Power;
	
	import flash.display.Bitmap;
	import flash.filters.ColorMatrixFilter;
	
	use namespace NSD5Power;
	
	/**
	 * 由电脑控制的玩家对象
	 */
	
	public class NCharacterObject extends CharacterObject
	{
		/**
		 * 用户ID，如果为0则为NPC
		 */ 
		protected var _uid:uint=0;		
		/**
		 * NPC默认对话
		 */ 
		protected var _say:String;
		
		protected var _missionIndex:int=-1;
		
		protected var _missionIndexList:Array;
		
		private var _bmd:Bitmap;

		public function get enable():Boolean
		{
			return _enable;
		}
		
		NSD5Power function set $say(s:String):void
		{
			if(s==null || s=='null') s='';
			_say = s;
		}
		
		/**
		 * NPC默认对话
		 */ 
		public function get say():String
		{
			return _say;
		}

		public function set uid(val:uint):void
		{
			canBeAtk=val>0;
			_uid=val;
		}
		
		public function get uid():uint
		{
			return _uid;
		}
		
		public function NCharacterObject(ctrl:BaseControler=null)
		{
			super(ctrl);
			objectName = 'NCharacterObject';
			_missionIndexList = new Array();
		}
		
		public function close():void
		{
			deleteing=true;
			canBeAtk = false;
			_controler = null;
		}
		
		public function open(_controller:BaseControler):void
		{
			_controler = _controller;
			_controler.perception.Scene.addObject(this);
		}
		
		private var _enable:Boolean;
		public function set enable(flg:Boolean):void
		{
			_enable = flg;
			this.mouseEnabled = this.mouseChildren = flg;
			this.filters = flg?null:[new ColorMatrixFilter([0.3086, 0.6094, 0.0820, 0, 0, 0.3086, 0.6094, 0.0820, 0, 0, 0.3086, 0.6094, 0.0820, 0, 0, 0, 0, 0, 1, 0])];
		}
		
		public function get missionIndex():int
		{
			return _missionIndex;
		}
		
		/**
		 * 刷新当前和这个NPC相关的任务记录
		 */ 
		public function loadMission():void
		{
			var m:MissionData;
			var num:uint = Global.userdata.missionNum;
			
			_missionIndex = -1;
			_missionIndexList = [];
			for(var i:uint = 0;i<num;i++)
			{
				m = Global.userdata.getMissionByIndex(i);
				if(m.npc_id == uid)
				{
					
					if(m.type == MissionData.TYPE_COMPLATE && _missionIndex==-1) _missionIndex = i;
					_missionIndexList.push(i);
				}
			}
			
			if(_missionIndex==-1 && _missionIndexList.length>0)
			{
				_missionIndex = _missionIndexList[0];
			}
			
			updateMissionData();
		}
		
		public function get hasMission():Boolean
		{
			return _missionIndexList.length>0;
		}
		 
		/**
		 * 刷任务 
		 */		
		public function updateMissionData():void
		{
			if(_missionIndex==-1)
			{
				if(_bmd && contains(_bmd)) removeChild(_bmd);
				return;
			}
			
			if(!_bmd) _bmd = new Bitmap();
			
			var m:MissionData = Global.userdata.getMissionByIndex(_missionIndex);
			
			if(m)
			{
				var url:String
				if(m.type==MissionData.TYPE_COMPLATE && m.check(Global.userdata))
				{
					_bmd.bitmapData = Global.MissionOver.bitmapData;
				}else if(m.type==MissionData.TYPE_COMPLATE){
					_bmd.bitmapData = Global.MissionOver0.bitmapData;
				}else if(m.check(Global.userdata)){
					_bmd.bitmapData = Global.MissionStart.bitmapData;
				}else{
					_bmd.bitmapData = Global.MissionStart0.bitmapData;
				}
				build();
				if(!contains(_bmd)) addChild(_bmd);
			}
		}
		
		override protected function build():void
		{
			super.build();
			if(_bmd)
			{
				_bmd.y= -(_bmd.height+displayer.monitor.height);
				_bmd.x = displayer.monitor.x+((displayer.monitor.width-_bmd.width)>>1);
			}
		}
	}
}