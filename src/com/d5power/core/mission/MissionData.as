package com.d5power.core.mission
{
	import com.d5power.utils.MissionNR;

	/**
	 * 单个任务数据
	 */ 
	public class MissionData
	{
		/**
		 * 承接类任务 ！
		 */ 
		public static const TYPE_GET:uint = 0;
		
		/**
		 * 交付类任务 ？
		 */ 
		public static const TYPE_COMPLATE:uint = 1;
		
		internal var _type:uint;
		/**
		 * 任务ID
		 */ 
		internal var _id:uint;
		/**
		 * 任务名
		 */ 
		internal var _name:String;
		/**
		 * 任务内容
		 */ 
		internal var _info:String;
		/**
		 * NPC对话内容
		 */ 
		internal var _npc_said:String;
		/**
		 * 相关NPC
		 */ 
		internal var _npc_id:uint;
		/**
		 * 是否完成
		 */ 
		internal var _iscomplate:Boolean=false;
		/**
		 * 任务需求
		 */ 
		internal var _need:Vector.<MissionBlock>;
		/**
		 * 任务奖励
		 */ 
		internal var _give:Vector.<MissionBlock>;
		
		/**
		 * 领取类任务，直接可以完成，文字显示接受
		 */ 
		internal static const GIVE:uint = 0;
		/**
		 * 完成类任务，需要满足条件才能完成。
		 */ 
		internal static const MISS:uint = 1;

		public function MissionData(id:uint)
		{
			_id = id;
		}
		
		public function formatFromXML(xml:XML):void
		{
			_type = int(xml.type);
			_name = xml.name;
			_info = xml.info;
			_npc_said = xml.say;
			_npc_id = int(xml.npc);
			
			var block:MissionBlock;
			
			if(_need==null)
			{
				_need = new Vector.<MissionBlock>;
				_give = new Vector.<MissionBlock>;
			}
			
			for each(var obj:Object in xml.need)
			{
				block = new MissionBlock();
				block.type = int(obj.@type);
				block.value = obj.@value;
				block.num = obj.@num;
				_need.push(block);
			}
			
			for each(obj in xml.give)
			{
				block = new MissionBlock();
				block.type = int(obj.@type);
				block.value = obj.@value;
				block.num = obj.@num;
				_give.push(block);
			}
		}
		
		/**
		 * 任务类型 0-接 1-交
		 */ 
		public function get type():uint
		{
			return _type;
		}
		/**
		 * 任务名
		 */ 
		public function get name():String
		{
			return _name;
		}
		/**
		 * 任务ID
		 */ 
		public function get id():uint
		{
			return _id;
		}
		/**
		 * 任务信息
		 */ 
		public function get info():String
		{
			return _info;
		}
		/**
		 * NPC任务对话
		 */ 
		public function get npc_said():String
		{
			return _npc_said;
		}
		/**
		 * NPC关联
		 */ 
		public function get npc_id():uint
		{
			return _npc_id;
		}
		/**
		 * 任务条件
		 */ 
		public function get need():Vector.<MissionBlock>
		{
			return _need;
		}
		/**
		 * 任务奖励
		 */ 
		public function get give():Vector.<MissionBlock>
		{
			return _give;
		}
		
		public function get needString():String
		{
			var needstr:String = '';
			for each(var need:MissionBlock in _need)
			{
				needstr+=MissionNR.getChinese(need.type)+"()"
			}
			
			return needstr;
		}
		/**
		 * 任务是否完成
		 */ 
		public function get isComplate():Boolean
		{
			return _iscomplate;
		}
		
		/**
		 * 增加完成条件 
		 */ 
		internal function addNeed(need:MissionBlock):void
		{
			if(_need == null) _need = new Vector.<MissionBlock>;
			if(need.type==0 && need.value==null) return;
			_need.push(need);
		}
		/**
		 * 增加奖励内容
		 */ 
		internal function addGive(give:MissionBlock):void
		{
			if(_give == null) _give = new Vector.<MissionBlock>;
			if(give.type==0 && give.value==null) return;
			_give.push(give);
		}
		/**
		 * 检查当前任务是否完成
		 */ 
		public function check(checker:IMissionDispatcher):Boolean
		{
//			if(!checker.canSee(_id)) return false;
			if(_type==GIVE) return true;
			
			_iscomplate=true;
			if(_need!=null)
			{
				for each(var need:MissionBlock in _need)
				{
					switch(need.type)
					{
						case MissionNR.N_ITEM_NEED:
						case MissionNR.N_ITEM_TACKED:
							_iscomplate = _iscomplate && checker.hasItemNum(int(need.value))>=int(need.num);
							break;
						default:
							break;
					}
				}
			}
			return _iscomplate;
		}
		
		/**
		 * 完成任务
		 */ 
		public function complate(checker:IMissionDispatcher):Boolean
		{
			if(!check(checker)) return false;
			
			Global.userdata.deleteMission(this);
			if(_give!=null)
			{
				for each(var give:MissionBlock in _give)
				{
					switch(give.type)
					{
						case MissionNR.R_ITEM:
							checker.getItem(int(give.value),int(give.num));
							break;
						case MissionNR.R_MONEY:
							checker.getMoney(int(give.value));
							break;
						case MissionNR.R_EXP:
							
							checker.getExp(int(give.value));
							break;
						case MissionNR.R_MISSION:
							Global.userdata.addMissionById(int(give.Value));
							//checker.getCanSeeMission(int(give.value));
							//give.num > 0 ? checker.getCanSeeMission(give.value) : checker.lostCanSeeMission(give.value);
							break;
					}
				}
			}
			return true;
		}
		
		public function toString():String
		{
			return "任务名："+_name+"\n任务编号："+_id+"\n任务类型："+_type+"\n任务说明:"+_info;
		}
	}
}