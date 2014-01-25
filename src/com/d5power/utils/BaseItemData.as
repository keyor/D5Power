package com.d5power.utils
{

	use namespace NSConfig;
	
	public class BaseItemData
	{
		NSConfig var _id:uint;
		NSConfig var _name:String;
		NSConfig var _info:String;
		NSConfig var _buy_price:uint;
		NSConfig var _sell_price:uint;
		NSConfig var _num:uint;
		NSConfig var _img:String;
		
		
		public function BaseItemData()
		{
		}
		
		public function get id():uint
		{
			return _id;
		}
		
		public function get buy_price():uint
		{
			return _buy_price;
		}
		
		public function get sell_price():uint
		{
			return _sell_price;
		}
		
		public function get name():String
		{
			return _name;
		}
		
		public function get info():String
		{
			return _info;
		}
		
		public function get num():uint
		{
			return _num;
		}
		
		public function toString():String
		{
			return "道具["+_id+"]"+_name+" 说明："+_info;
		}
	}
}