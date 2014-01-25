package com.d5power.objects
{
	import flash.geom.Point;

	public interface IGO
	{
		function runPos():void;
		function renderMe():void;
		function set deleteing(b:Boolean):void;
		function get deleteing():Boolean;
		function dispose():void;
		function get _POS():Point;
		function set inScreen(v:Boolean):void;
		function get inScreen():Boolean;
		function get zOrder():int;
		function setPos(px:Number,py:Number):void;
	}
}