package com.d5power.events
{
	import flash.events.Event;
	
	public class D5IOErrorEvent extends Event
	{
		public static const CONF_ERROR:String = "d5_config_error";
		
		public static const _MAP:String = 'map_error';
		public static const _MISSION:String = 'mission_error';
		private var _data:String;
		
		public function D5IOErrorEvent(type:String, data:String,bubbles:Boolean=false, cancelable:Boolean=false)
		{
			_data = data;
			super(type, bubbles, cancelable);
		}
		
		public function get data():String
		{
			return _data;
		}
	}
}