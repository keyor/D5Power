package com.d5power.core.mission
{
	public interface IMissionDispatcher
	{
		/**
		 * 是否具备某个任务
		 */ 
		function hasMission(m:MissionData):Boolean
		/**
		 * 检查某物品数量
		 */ 
		function hasItemNum(itemid:uint):uint;
		/**
		 * 是否和某NPC对话过
		 */ 
		function hasTalkedWith(npcid:uint):uint;
		/**
		 * 杀死怪物数量
		 */ 
		function killMonseterNum(monsterid:uint):uint;
		
		/**
		 * 得到某物品
		 */ 
		function getItem(itemid:uint,num:int):Boolean;
		
		/**
		 * 获得经验
		 */ 
		function getExp(num:uint):void;
		
		/**
		 * 获得某个任务
		 */  
		function addMissionById(id:uint):void;
		/**
		 * 获得游戏币
		 */ 
		function getMoney(num:int):Boolean
		
//		/**
//		 * 可见某任务
//		 */ 
//		function getCanSeeMission(id:uint):void;
//		/**
//		 * 不可见某任务
//		 */ 
//		function lostCanSeeMission(id:uint):void; 
	}
}