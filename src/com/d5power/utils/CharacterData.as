package com.d5power.utils
{
	import com.d5power.D5Game;
	import com.d5power.controller.NCharacterControler;
	import com.d5power.core.D5ConfigCenter;
	import com.d5power.core.mission.IMissionDispatcher;
	import com.d5power.core.mission.MissionBlock;
	import com.d5power.core.mission.MissionData;
	import com.d5power.events.D5IOErrorEvent;
	import com.d5power.net.D5StepLoader;
	import com.d5power.ns.NSD5Power;
	import com.d5power.objects.NCharacterObject;
	import com.d5power.ui.IUserDataDisplayer;
	
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	use namespace NSD5Power;
	public class CharacterData extends RandData implements IMissionDispatcher
	{
		/**
		 * 新的任务列表  
		 */		
		NSD5Power var _missionList:Vector.<MissionData> = new Vector.<MissionData>();
		
		public var nickname:String='D5Power';
		/**
		 * 玩家阵营
		 */ 
		public var camp:uint = 0;
		
		/**
		 * 玩家用户ID
		 */ 
		public var uid:uint = 0;
		
		/**
		 * 系统配置的起始任务ID
		 */ 
		private var _startMission:uint;
		
		/**
		 * 玩家经验
		 */ 
		private var _exp:uint;
		
		/**
		 * 玩家游戏币
		 */ 
		private var _money:uint;
		
		/**
		 * 玩家背包
		 */ 
		private var _itemList:Vector.<ItemData>;
		
		/**
		 * 任务配置加载队列
		 */ 
		private var _missionLoadingList:Array;
		private var _missionIsLoading:Boolean;
		private var _urlLoader:URLLoader;
		
		private var _userdataDisplayer:IUserDataDisplayer;
		
		/**
		 *	@param		ispc	是否玩家 
		 */
		public function CharacterData(ispc:Boolean=true)
		{
			_missionLoadingList = new Array();
			_itemList = new Vector.<ItemData>;
			_urlLoader = new URLLoader();
			_urlLoader.addEventListener(Event.COMPLETE,onCompleteFunction);
			_urlLoader.addEventListener(IOErrorEvent.IO_ERROR,ioerror);
		}
		
		public function set userdataDisplayer(value:IUserDataDisplayer):void
		{
			_userdataDisplayer = value;
		}
		
		public function set startMission(v:uint):void
		{
			_startMission = v;
			addMissionById(_startMission);
		}
		
		public function get startMission():uint
		{
			return _startMission;
		}
		
		/**
		 * 给予游戏币
		 */ 
		public function getMoney(u:int):Boolean
		{
			if(u<0 && _money<-u) return false;
			_money+=u;
			if(_userdataDisplayer!=null) _userdataDisplayer.showMoney(_money);
			return true;
		}
		
		public function hasMission(m:MissionData):Boolean
		{
			return _missionList.indexOf(m)!=-1;
		}
		
		public function hasItemNum(itemid:uint):uint
		{
			var num:uint = 0;
			for each(var obj:ItemData in _itemList)
			{
				if(obj.id==itemid)
				{
					num+=obj.num;
				}
			}
			return num;
		}
		
		public function hasTalkedWith(npcid:uint):uint
		{
			return 0;
		}
		
		public function killMonseterNum(monsterid:uint):uint
		{
			return 0;
		}
		
		public function getItem(itemid:uint,num:int):Boolean
		{
			var item:ItemData = D5ConfigCenter.me.getItem(itemid);
			if(item==null)
			{
				return false;
			}
			
			if(num<0)
			{
				var hasNum:uint = hasItemNum(itemid);
				if(hasNum<-num) return false;
				
				
			}
			
			for each(var obj:ItemData in _itemList)
			{
				if(obj.id==itemid)
				{
					obj.num+=num;
					return true;
				}
			}
			
			item.num = num;
			_itemList.push(item);
			return true;
		}
		
		public function getExp(num:uint):void
		{
			_exp+=num;
			if(_userdataDisplayer!=null) _userdataDisplayer.showExp(_exp);
		}

		
		/**
		 * 获取任务数据 
		 * @param mission_id 任务ID
		 */		
		public function addMissionById(mission_id:uint):void
		{
			_missionLoadingList.push(mission_id);
			if(_missionLoadingList.length==1) loadMissionConfig();
			
		}
		
		private function loadMissionConfig():void
		{
			if(_missionLoadingList.length==0)
			{
				if(D5Game.me.scene) D5Game.me.scene.missionLoaded();
				return;
			}
			_urlLoader.load(new URLRequest("asset/data/mission/"+_missionLoadingList[0]+".xml"));
		}
		
		private function onCompleteFunction(evt:Event):void
		{
			var xml:XML = new XML(_urlLoader.data);
			var missionData:MissionData = new MissionData(xml.id);
			missionData.formatFromXML(xml);
			_missionList.push(missionData);
			_missionLoadingList.shift();
			loadMissionConfig();
		}
		
		private function ioerror(evt:IOErrorEvent):void
		{
			D5Game.me.dispatchEvent(new D5IOErrorEvent(D5IOErrorEvent.CONF_ERROR,D5IOErrorEvent._MISSION));
			_missionLoadingList.shift();
			loadMissionConfig();
		}
		
		public function get missionNum():uint
		{
			return _missionList.length;
		}
		
		public function getMissionByIndex(index:uint):MissionData
		{
			if(index>=_missionList.length) return null;
			return _missionList[index];
		}
		
		public function deleteMission(m:MissionData):void
		{
			_missionList.splice(_missionList.indexOf(m),1);
		}
	}
}