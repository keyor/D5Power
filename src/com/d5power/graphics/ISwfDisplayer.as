package com.d5power.graphics
{
	import flash.display.Bitmap;
	import flash.display.Shape;

	public interface ISwfDisplayer 
	{
		/**
		 * 设置素材加载完后的响应函数
		 */ 
		function set onReady(f:Function):void;
		/**
		 * 获取当前素材所在的目录
		 */ 
		function get swfDir():String;
		/**
		 * 所包含的最大帧
		 */ 
		function get maxFrame():uint;
		/**
		 * 获取当前播放的帧数
		 */ 
		function get nowFrame():uint;
		/**
		 * 获取当前的素材完整路径
		 */ 
		function get swfPath():String;
		/**
		 * 渲染接口
		 */ 
		function render():void;
		/**
		 * 更换SWF接口
		 */ 
		function changeSWF(f:String,inPool:Boolean=true):void;
		/**
		 * 直接设置SWF
		 */ 
		function setSWF(f:Object):void;
		/**
		 * 更换动作接口
		 */ 
		function set action(v:int):void;
		
		/**
		 * 更换方向接口
		 */ 
		function set direction(v:int):void;
		
		/**
		 * 获取当前的渲染方向
		 */ 
		function get renderDirection():int;
		
		/**
		 * 获取显示对象
		 */ 
		function get monitor():Bitmap;
		
		/**
		 * 读取影子
		 */ 
		function get shadow():Shape;
		
		/**
		 * 释放资源
		 */ 
		function dispose():void
	}
}