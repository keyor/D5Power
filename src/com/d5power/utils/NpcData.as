package com.d5power.utils
{
	import flash.utils.ByteArray;

	public class NpcData
	{
		public var id:uint;
		public var npcname:String;
		protected var _in_map:Array;
		public function NpcData()
		{
			_in_map = new Array();
		}
		
		public function load(data:ByteArray):void
		{
			id = data.readUnsignedShort();
			npcname = data.readUTF();
			var c:uint = data.readUnsignedShort();
			for(var i:uint = 0;i<c;i++)
			{
				addInMap(data.readUnsignedShort());
			}
		}
		
		/**
		 * 增加NPC所在地图记录
		 */ 
		public function addInMap(v:uint):void
		{
			if(_in_map.indexOf(v)==-1) _in_map.push(v);
		}
		
		/**
		 * 确认NPC是否在某个地图
		 * @param	mapid	地图
		 * @return	Boolean  true-在mapid所指定的地图  false-没有在mapid所指定的地图
		 */ 
		public function isInMap(mapid:uint):Boolean
		{
			return _in_map.indexOf(mapid)!=-1;
		}
	}
}