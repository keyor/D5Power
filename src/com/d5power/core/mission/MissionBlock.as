package com.d5power.core.mission
{
	/**
	 * 任务需求条件或给与奖励的专用存储数据
	 */ 
	public class MissionBlock
	{		
		/**
		 * 类型
		 */ 
		internal var type:uint;
		
		/**
		 * 值
		 */ 
		internal var value:String
		
		/**
		 * 数量
		 */ 
		internal var num:String;
		
		public function MissionBlock()
		{
		}
		
		public function get Type():uint
		{
			return type;
		}
		
		public function get Value():String
		{
			return value;
		}
		
		public function get Num():String
		{
			return num;
		}
		
		
		public function toString():String
		{
			return "类型："+type+"值："+value+"数量："+num;
		}
	}
}