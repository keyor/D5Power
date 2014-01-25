package com.d5power.utils
{
	import com.d5power.core.D5ConfigCenter;
	
	public class MissionNR
	{
		/**
		 * 系统保存的处理模式
		 */ 
		public static const SAVE_KEY:uint = 200;
		/**
		 * 需求与奖励分割线
		 */ 
		public static const N_R_LINE:uint = 100;
		
		/* !!! 以下内容为D5Rpg内部定义，非必要请不要修改，会影响较多代码 !!! */
		
		/**
		 * 杀死怪物
		 */ 
		public static const N_MONSTER_KILLED:uint = 0;
		/**
		 * 拥有物品（不扣除）
		 */ 
		public static const N_ITEM_TACKED:uint = 1;
		/**
		 * 拥有物品（扣除）
		 */ 
		public static const N_ITEM_NEED:uint = 2;
		/**
		 * 拥有任务
		 */ 
		public static const N_MISSION:uint = 3;
		/**
		 * 玩家属性
		 */ 
		public static const N_PLAYER_PROP:uint = 4;
		/**
		 * 与NPC对话
		 */ 
		public static const N_TALK_NPC:uint = 5;
		
		
		/**
		 * 奖励道具
		 */ 
		public static const R_ITEM:uint = 100;
		/**
		 * 奖励游戏币
		 */ 
		public static const R_MONEY:uint = 101;
		/**
		 * 奖励经验
		 */ 
		public static const R_EXP:uint = 102;
		/**
		 * 奖励任务
		 */ 
		public static const R_MISSION:uint = 103;
		
		/* !!! 以上内容为D5Rpg内部定义，非必要请不要修改，会影响较多代码 !!! */
		
		
		private static const COSTOM_DEFINE:Array = new Array();
		
		public function MissionNR()
		{
		}
		
		/**
		 * 增加用户处理配置
		 */ 
		public static function addCostomDefine(data:Array):String
		{
			if(data.length!=2)
			{
				return '无效的配置数据';
			}
			
			if(int(data[0])<=SAVE_KEY)
			{
				return SAVE_KEY+'以内为D5Rpg保留条件ID';
			}
			
			COSTOM_DEFINE.push(data);
			return 'TRUE';
		}
		
		public static function getChinese(id:uint):String
		{
			switch(id)
			{
				case N_MONSTER_KILLED:
					return '杀死怪物';
					break;
				case N_ITEM_NEED:
					return '拥有道具（扣除）';
					break;
				case N_ITEM_TACKED:
					return '拥有道具（不扣除）';
					break;
				case N_MISSION:
					return '拥有任务';
					break;
				case N_PLAYER_PROP:
					return '玩家属性达到';
					break;
				case N_TALK_NPC:
					return '与NPC对话';
					break;
				case R_ITEM:
					return '奖励道具';
					break;
				case R_MONEY:
					return '奖励游戏币';
					break;
				case R_EXP:
					return '奖励经验';
					break;
				case R_MISSION:
					return '奖励任务';
					break;
				default:
					for each(var data:Array in COSTOM_DEFINE)
					{
						if(data[0]==id) return data[1];
					}
					break;
			}
			
			return 'NULL';
		}
	}
}